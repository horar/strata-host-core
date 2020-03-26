<#
.SYNOPSIS
Modular file that exports several common functions used by the testing scripts in this directory

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

# Check if python and pyzmq are installed
function Assert-PythonAndPyzmq {
    # Determine the python command based on OS. OSX will execute Python 2 by default and here we need to use Python 3.
    # on Win, Python 3 is not in the path by default, as a result we'll need to use 'python3' for OSX and 'python' for Win
    If ($Env:OS -Eq "Windows_NT") {
        $Global:PythonExec = 'python'
    } Else {
        $Global:PythonExec = 'python3'
    }

    # Attempt to run Python and import PyZMQ, display error if operation fails
    Try {
        If ((Start-Process $PythonExec --version -Wait -WindowStyle Hidden -PassThru).ExitCode -Eq 0) {
            If (!(Start-Process $PythonExec '-c "import zmq"' -WindowStyle Hidden -Wait -PassThru).ExitCode -Eq 0) {
                Write-Host -ForegroundColor Red "Error: ZeroMQ library for Python is required, visit https://zeromq.org/languages/python/ for instructions.`nAborting."
                Exit-TestScript -1
            }
        } Else {
            Exit-TestScript -1 "Error: Python not found.`nAborting."
        }
    } Catch [System.Management.Automation.CommandNotFoundException] {
        Exit-TestScript -1 "Error: Python not found.`nAborting."
    }

    # Verify Python being run is Python 3
    $PythonVersion = Invoke-Expression "${PythonExec} -c 'import sys; print(sys.version_info[0])'"
    If ($PythonVersion -Ne 3) {
        Exit-TestScript -1 "Error: Python 3 is required.`nAborting."
    }
}

# Check if both SDS and HCS are found where expected
function Assert-StrataAndHCS {
    # Convert the path if using Unix env, then check for SDS executable
    If ($Env:OS -Ne "Windows_NT" -And (($SDSExecFile = Convert-Path $SDSExecFile) -Eq $false)) {
        Exit-TestScript -1 "Error: cannot find Strata Developer Studio executable at $SDSExecFile.`nAborting."
    }
    # Check for SDS executable
    If (!(Test-Path $SDSExecFile)) {
        Exit-TestScript -1 "Error: cannot find Strata Developer Studio executable at $SDSExecFile.`nAborting."
    }
    # Check for HCS directory
    If (!(Test-Path $HCSAppDataDir)) {
        Exit-TestScript -1 "Error: cannot find Host Controller Service directory at $HCSAppDataDir.`nAborting."
    }
}

# Check if both Python scripts are found where expected
function Assert-PythonScripts {
    If (!(Test-Path $PythonCollateralDownloadTest)) {
        Exit-TestScript -1 "Error: cannot find Python script at $PythonCollateralDownloadTest.`nAborting."
    }
    If (!(Test-Path $PythonControlViewTest)) {
        Exit-TestScript -1 "Error: cannot find Python script at $PythonControlViewTest.`nAborting."
    }
}

# Check if PS module 'PSSQLite' is installed
# Tell user to manually install it if not found & exit
function Assert-PSSQLite {
    If (!(Get-Module -ListAvailable -Name PSSQLite)) {
        Write-Host -ForegroundColor Red "`nError: PSSQLite module for Powershell not found.`nInstall PSSQLite by running as administrator:`n   Install-Module PSSQLite`nAborting.`n"
        Exit-TestScript -1
    }
}

# Start one instance of HCS
function Start-HCS {
    Start-Process -FilePath $HCSExecFile -ArgumentList "-f `"$HCSConfigFile`""
    Start-Sleep -Seconds 1
}

# Utility function to print the exit code and a pattern for the end of the script
function Exit-TestScript {
    Param (
        [Parameter(Mandatory = $true)][int]$ScriptExitCode,
        [Parameter(Mandatory = $false)][string]$ScriptExitText
    )

    If ($ScriptExitCode -Eq 0) {
        Write-Host "Test finished successfully. Exiting..." -ForegroundColor Green
    } Else {
        If ($ScriptExitText) {
            Write-Error "Test failed: $($ScriptExitText) Terminating... $($ScriptExitCode)"
        } Else {
            Write-Error "Test failed. Terminating... $($ScriptExitCode)"
        }
    }
    Exit $ScriptExitCode
}

# Stops all processes by the name of "hcs" running in the local machine
function Stop-HCS {
    If (Get-Process -Name "hcs" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "hcs" -Force
        Start-Sleep -Seconds 1
    }
}

# Stops all processes by the name of "Strata Developer Studio" running in the local machine
function Stop-SDS {
    If (Get-Process -Name "Strata Developer Studio" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "Strata Developer Studio" -Force
        Start-Sleep -Seconds 1
    }
}
# Start one instance of Strata and wait (to give time for DB replication)
# waiting time parameter is optional
function Start-SDSAndWait {
    Param (
        [Parameter(Mandatory = $false)][int]$seconds
    )
    Start-Process -FilePath $SDSExecFile
    if ($seconds) {
        Start-Sleep -Seconds 5
    }
}

# Start one instance of HCS and wait (to give time for DB replication)
function Start-HCSAndWait {
    Param (
        [Parameter(Mandatory = $false)][int]$seconds
    )

    Start-Process -FilePath $HCSExecFile -ArgumentList "-f `"$HCSConfigFile`""
    If ($seconds) {
        Start-Sleep -Seconds $seconds
    }
}

function Restore-Strata_INI {
    # Delete temporary .ini file and restore original
    Set-Variable "AppData_OnSemi_dir" (Split-Path -Path $HCSAppDataDir)
    If (Test-Path "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini") {
        Remove-Item -Path "$AppData_OnSemi_dir\Strata Developer Studio.ini"
        Rename-Item "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini" "$AppData_OnSemi_dir\Strata Developer Studio.ini"
    }
}

function Remove-TemporaryFiles {
    # Delete strataDev/DynamicPlatformList.json
    If (Test-Path "$TestRoot\strataDev\DynamicPlatformList.json") {
        Remove-Item "$TestRoot\strataDev\DynamicPlatformList.json"
    }
    Else {
        Write-Host "$TestRoot\strataDev\DynamicPlatformList.json not found."
    }

    # Delete hcs/CollateralDownloadResults.txt
    If (Test-Path "$TestRoot\hcs\CollateralDownloadResults.txt") {
        Remove-Item "$TestRoot\hcs\CollateralDownloadResults.txt"
    }
    Else {
        Write-Host "$TestRoot\hcs\CollateralDownloadResults.txt not found."
    }
}

# Show a summary of the test results
function Show-TestSummary {
    Write-Separator
    Write-Host "Test Summary"
    Write-Separator

    Show-TestResult -TestName "Test-Database" -TestResults $DatabaseResults

    Show-TestResult -TestName "Test-TokenAndViewsDownload" -TestResults $TokenAndViewsDownloadResults

    Show-TestResult -TestName "Test-CollateralDownload" -TestResults $CollateralDownloadResults

    If ($SDSControlViewsResults) {
        If ($SDSControlViewsResults -Eq $true) {
            Write-Host -ForegroundColor Green "`nResult for Test-SDSControlViews: No errors found during execution, test requires visual inspection."
        } Else {
            Write-Host -ForegroundColor Red "`nResult for Test-SDSControlViews: One or more errors found during execution."
        }
    }
}

function Show-TestResult {
    Param (
        [Parameter(Mandatory = $true)][string]$TestName,
        [Parameter(Mandatory = $true)]$TestResults
    )

    If ($TestResults) {
        If ($TestResults[0] -Eq -1) {
            Write-Host -ForegroundColor Red "`nError found with test $TestName."
        } Elseif ($TestResults[0] -Eq $TestResults[1]) {
            Write-Host -ForegroundColor Green "`nResult for ${TestName}: $($TestResults[0]) passed out of $($TestResults[1])."
        } Else {
            Write-Host -ForegroundColor Red "`nResult for ${TestName}: $($TestResults[0]) passed out of $($TestResults[1])."
        }
    }
}

# Print a ***** the width of the console
function Write-Separator {
    $Line = "*" * $Host.UI.RawUI.WindowSize.Width
    Write-Host `n$Line`n
}

# Print indent string with different colors for fail and pass massages
# Checking for FAIL and PASS is not case sensitive
function Write-Indented {
    Param (
        [Parameter(Mandatory = $true)][string]$string
    )
    $FirstWord = ($string -split ' ')[0]
    if (($FirstWord -eq "FAIL") -OR ($FirstWord -eq "FAIL:")) {
        Write-Host -ForegroundColor Red "        $string"
    } elseif (($FirstWord -eq "PASS") -OR ($FirstWord -eq "PASS:")) {
        Write-Host -ForegroundColor Green "        $string"
    } elseif (($FirstWord -eq "WARNING") -OR ($FirstWord -eq "WARNING:")) {
        Write-Host -ForegroundColor Yellow "        $string"
    } else {
        Write-Host "        $string"  
    }
}