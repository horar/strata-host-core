<#
.SYNOPSIS
Modular file that export Test-SDSControlViews function to test the cycle through the control views
of Strata Developer Studio.

.DESCRIPTION
This is part of the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist

.INPUTS
-PythonScriptPath   <Path to Strata executable>
-StrataPath         <Path to control-view-test.py>

.OUTPUTS
Boolean result of the test

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

# Function to run the test, it will Return True if the test was successful
# Usage: Test-SDSControlViews -PythonScriptPath <Path to Strata executable> -StrataPath <Path to control-view-test.py>
function Test-SDSControlViews {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$PythonScriptPath,    # Path to Strata executable
        [Parameter(Mandatory = $true)][string]$StrataPath,          # Path to control-view-test.py
        [Parameter(Mandatory = $true)][string]$ZmqEndpoint          # The address of zmq client
    )

    Write-Separator
    Write-Host "SDS Control view testing"
    Write-Separator

    # Set-Location $SDSRootDir isneeded to resolve the ddl issue when running
    # HCS seperetly so that Windows will look into this directory for dlls
    Set-Location $SDSRootDir
    Write-Host "`nStarting Strata Developer Studio..."
    ($StrataDev = Start-Process $StrataPath -PassThru) | Out-Null     # Hide output.
    Set-Location $TestRoot
    
    Write-Host "Starting Python test script..."
    Write-Host "################################################################################"
    $pythonScript = Start-Process $PythonExec -ArgumentList "$PythonScriptPath $ZmqEndpoint" -NoNewWindow -PassThru -Wait
    Write-Host "################################################################################"

    Write-Host "Python test script is done."

    Write-Host "Checking if Strata Developer Studio is still running."
    If ($StrataDev.HasExited -eq $false) {
        Write-Host "Strata Developer Studio is running. Killing Strata Developer Studio..."
        Stop-SDS
        Stop-HCS
    } Else {
        # Strata is not running. It could be a crash!
        Write-Error "Strata developer Studio is not running. It might have crashed during the test. Aborting..."
        Stop-HCS
        Return $false
    }

    If ($PythonScript.ExitCode -eq 0) {
        # Test Successful
        Write-Host "No errors found during execution, test requires visual inspection."
        Return $true
    } Else {
        Write-Error "Test failed."
        Write-Error "Exit Code = $($pythonScript.ExitCode)"
        Return $false
    }
}
