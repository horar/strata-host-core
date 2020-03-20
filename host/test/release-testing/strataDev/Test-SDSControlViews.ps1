<#
.SYNOPSIS
Modular file that export Test-SDSControlViews function to test the cycle through the control views
of Strata Developer Studio.

.DESCRIPTION
Modular file that export Test-SDSControlViews function to test the cycle through the control views
of Strata Developer Studio. This is part of the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist#Installer

.INPUTS
-PythonScriptPath   <Path to Strata executable>
-StrataPath         <Path to control-view-test.py>

.OUTPUTS
Bolean result of the test

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

# Function to run the test, it will return True if the test was successful
# Usage: Test-SDSControlViews -PythonScriptPath <Path to Strata executable> -StrataPath <Path to control-view-test.py>
function Test-SDSControlViews {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$PythonScriptPath,    # Path to Strata executable
        [Parameter(Mandatory = $true)][string]$StrataPath,          # Path to control-view-test.py
        [Parameter(Mandatory = $true)][string]$ZmqEndpoint          # The address of zmq client 
    )

    Write-Host "Looking for the test script " $PythonScriptPath
    if (Test-Path -Path $PythonScriptPath) {
        write-host "Script Found" -ForegroundColor Green
        
        write-host "Starting Strata Developer Studio..."
        ($strataDev = Start-Process $StrataPath -PassThru) | Out-Null     # Hide output.
        
        write-host "Starting python test script..."
        write-host "################################################################################"
        $pythonScript = Start-Process $PythonExec -ArgumentList "$PythonScriptPath $ZmqEndpoint" -NoNewWindow -PassThru -wait
        write-host "################################################################################"
        
        Write-Host "Python test script is done."

        Write-Host "Checking if Strata Developer Studio is still running."
        if ($strataDev.HasExited -eq $false) {
            Write-Host "Strata Developer Studio is running. Killing Strata Developer Studio..."
            stop-process $strataDev.id
        }
        else {
            # Strata is not running. it could be crash!
            Write-Error "Strata developer Studio is not running. It might have crashed during the test. Aborting..."
            return $false
        }
        

        if ($pythonScript.ExitCode -eq 0) {
            # Test Successful
            Write-Host "Test Successful." -ForegroundColor Green
            return $true
        }
        else {
            Write-Error "Test failed."
            Write-Error "Exit Code = $($pythonScript.ExitCode)"
            return $false
        }
    }
    else {
        return $false
    }
}
