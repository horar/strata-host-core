<#
.SYNOPSIS
Modular file that exports the Test-TokenAndViewsDownload function to test
automated HCS token / login / automated platform thumbnail download

.DESCRIPTION
This is part of the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist

This tests consists of:
1. Connect to the given server and obtain token for login with provided credentials
2. Use obtained token to login
3. Verify that the platform views are downloaded by HCS

.INPUTS
None

.OUTPUTS
Numerical test result (TODO)

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

function Test-TokenAndViewsDownload {

    # Keep track of tests
    Set-Variable "TestPass"  0
    Set-Variable "TestTotal" 2

    Write-Separator
    Write-Host "Login/Token and View Download testing"
    Write-Separator

    # Define some derived paths used in this script
    Set-Variable "PlatformSelector_dir" "$HCSAppDataDir\PROD\documents\platform_selector"

    # Attempt to acquire token information from server
    Write-Host "TEST 1: Token/authentication server testing (using endpoint $SDSLoginServer)"
    Write-Indented "Attempting to acquire token information from server...`n"
    Try {
        $server_response = Invoke-WebRequest -URI $SDSLoginServer -Body $SDSLoginInfo -Method 'POST' -ContentType 'application/json' -ErrorAction 'Stop' -UseBasicParsing
    } Catch {
        Write-Indented "FAILED: Unable to obtain login token from server '$SDSLoginServer' with provided account, try again.`n"
        Return $TestPass, $TestTotal
    }

    Write-Indented "HTTP $($server_response.StatusCode): $($server_response.StatusDescription)"

    If (!($server_response.Content) -Or $server_response.StatusCode -Ne 200) {
        Write-Indented "FAILED: Invalid server token response, try again.`n"
        Return $TestPass, $TestTotal
    } Else {
        Write-Indented "PASS: Successfully acquired token information from server."
        $TestPass++
    }

   
    Backup-Strata_INI

    # Format new token string using obtained token
    $server_response_Json = ConvertFrom-Json $server_response.Content
    $token_string = "[Login]`nrememberMe=true`ntoken=$($server_response_Json.token)`nfirst_name=$($server_response_Json.firstname)`nlast_name=$($server_response_Json.lastname)`nuser=$($server_response_Json.user)`nauthentication_server=$SDSServer"

    # Write to "Strata Developer Studio.ini"
    Set-Content "$StrataDeveloperStudioIniDir\Strata Developer Studio.ini" $token_string

    # Delete AppData/Roaming/hcs/documents/platform_selector directory if it exists
    If (Test-Path $PlatformSelector_dir -PathType Any) {
        Write-Indented "Deleting directory $PlatformSelector_dir"
        Remove-Item -Path $PlatformSelector_dir -Recurse -Force
        Write-Indented "OK"
    }

    # Run Strata Developer Studio and wait 10 s
    Write-Host "`nTEST 2: Running Strata Developer Studio and waiting for 10 seconds..."
    Start-SDSAndWait(10)

    # Kill Strata Developer Studio and HCS processes
    Stop-SDS
    Stop-HCS

    # Check whether AppData/Roaming/hcs/documents/platform_selector directory was re-populated by HCS
    If (Test-Path $PlatformSelector_dir -PathType Any) {
        If (@(Get-ChildItem $PlatformSelector_dir).Count -Gt 0) {
            Write-Indented "PASS: directory with $(@(Get-ChildItem $PlatformSelector_dir).Count) elements."
            $TestPass++
        } Else {
            Write-Indented "FAIL: empty directory created."
        }
    } Else {
        Write-Indented "FAIL: directory not created."
    }


    # Return number of tests passed, number of tests existing
    Return $TestPass, $TestTotal
}