<#
Code taken from here: https://gist.github.com/bilbothebaggins/efbbc2312ec72c4967622b340e4b26d6

Simplifies supplying arguments with internal quotes to other scripts.
#>


function Get-NeedsArgvQuote {
<#
    .DESCRIPTION Fix up our argument string for the insane CommandLineToArgvW rules
    .LINK https://docs.microsoft.com/en-us/archive/blogs/twistylittlepassagesallalike/everyone-quotes-command-line-arguments-the-wrong-way
#>    
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][AllowEmptyString()][string]$arg
    )
    if ([System.String]::IsNullOrEmpty($arg)) {
        # empty does NEED quotes
        return $True
    } elseif ($arg.IndexOfAny(@(" ", "`t", "`n", "`v", "`"")) -lt 0) {
        # no special characters
        # Note: If only backslashes are contained but no spaces or quotes, we do not need quoting or escaping
        return $False
    }
    return $True
}

function ConvertTo-ArgvQuoteInner
{
<#
    .DESCRIPTION Fix up our argument string for the insane CommandLineToArgvW rules
    .LINK https://docs.microsoft.com/en-us/archive/blogs/twistylittlepassagesallalike/everyone-quotes-command-line-arguments-the-wrong-way
#>    
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][AllowEmptyString()][string]$arg
    )
    if ([System.String]::IsNullOrEmpty($arg)) {
        # empty does not need any inner escaping
        return $arg
    }
    if (-not (Get-NeedsArgvQuote $arg)) {
        return $arg
    }
    # else: Escape *inner* characters (do not add enclosing double quotes here)
    $escaped = [System.Text.StringBuilder]::new()
    $carr = $arg.ToCharArray()
    for ($i=0; $i -lt $carr.Count; ++$i) {
        $c = $carr[$i]
        $numBackslashes = 0
        while (($i -lt $carr.Count) -and ($c -eq '\')) {
            $c = $carr[++$i]
            ++$numBackslashes
        }
        if ($i -ge $carr.Count) {
            # Argument ends with backslashes
            # Need to escape them, so that the *quoted* argument works with them (the quoted argument will end with a <"> after the last BS)
            $escaped.Append('\', 2 * $numBackslashes) | Out-Null
        } elseif($c -eq '"') {
            # Escape all backslashes and the following double quotation mark.
            $escaped.Append('\', 2 * $numBackslashes + 1) | Out-Null
            $escaped.Append($c) | Out-Null
        } else {
            # We possibly counted some backslashes, but as we are not at the end nor followed by a quote,
            # BS are not special here:
            $escaped.Append('\', $numBackslashes) | Out-Null
            $escaped.Append($c) | Out-Null
        }
    }
    return $escaped
}

function Get-PoShWillAddQuotes {
<#
    .DESCRIPTION Determine whether PoSh would add quotes to this string if passed to a native command
#>    
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][AllowEmptyString()][string]$arg
    )
    # Note: Add-Type is already caching the compiled results in memory and won't do anything
    #       when the same source is loaded again.
    #       However: If the type has changed, this throws an error. (But that's only an annoyance during development.)
    Add-Type -Path "$PSScriptRoot\xxxxPoshNativeCommandUtils.cs"
    return [xxxx.xxxxPoshNativeCommandUtils]::NeedQuotesPoshV5($arg)
}

function ConvertTo-ArgvQuoteForPoSh
{
<#
    .DESCRIPTION Fix up our argument string for the insane CommandLineToArgvW rules AND then handle the powershell arg quotiung rules!
#>    
    [CmdletBinding()]
    param(
        [Parameter(Position=0,Mandatory=1)][AllowEmptyString()][string]$arg,
        [Parameter(Position=1,Mandatory=0)][switch]$ForceLeadingSpaceForImpossibleArguments=$False
    )
    # First we fix up the argument:
    if (-not (Get-NeedsArgvQuote $arg)) {
        return $arg
    }
    $escapedArg = ConvertTo-ArgvQuoteInner $arg
    # Now the argument is escaped, but we need to decide
    # whether to add quotes ourselves or
    # whether powershell will auto-add quotes to the invoked command line:
    # As far as research goes, PoSh will basically auto-add quotes when the argument contains whitespace.
    #region  Extended Notes
    #    https://github.com/PowerShell/PowerShell
    #    ~  src/System.Management.Automation/engine/NativeCommandParameterBinder.cs
    #    ~ internal static bool NeedQuotes(string stringToCheck)
    #    ~ private void appendOneNativeArgument ...
    #    ~ // We need to add quotes if the argument has unquoted spaces. ...
    #    ~ // We need to check quotes that the win32 argument parser checks which is currently
    #      // just the normal double quotes, no other special quotes.  Also note that mismatched
    #    ~ // need to escape all trailing backslashes so the native command receives it correctly [[Github https://github.com/PowerShell/PowerShell/commit/59311d03e16688d336ecc8758d2167643406b06c ]]
    #endregion Extended Notes
    if (Get-PoShWillAddQuotes $escapedArg) {
        # Powershell will add the quotes
        return $escapedArg
    } else {
        # we add the quotes
        # Write-Host -ForegroundColor Magenta "Adding extra quotes to <$arg>"
        $escQuotArg = "`"$escapedArg`""
        if (Get-PoShWillAddQuotes $escQuotArg) {
            # PoSh would NOT add quotes to the $escapedArg, but WOULD add quotes to the $escQuotArg!
            # If Powershell would not add quotes to the unquoted arg, but WOULD add quotes
            # to the quoted arg, then we cannot pass this argument to the child process at all via normal
            # PoSh invocation!
            if ($ForceLeadingSpaceForImpossibleArguments) {
                # We can workaround the problem if we add a leading space to our argument.
                # Then PoSh will auto-quote it. 
                # Obviously, this only works if the receiving process can interpret the arg with the leading space.
                return " $escapedArg" # in this case PoSh will now add the quotes
            } else {
                throw "ConvertTo-ArgvQuoteForPoSh: Impossible argument value detected! Arg <$arg> (escaped: <$escapedArg>) cannot be passed through PowerShell without breaking it! (You can add the -ForceLeadingSpaceForImpossibleArguments switch to auto-add a leading space in this case)"
            }
        }
        return $escQuotArg
    }
}
