<#
.SYNOPSIS
Modular file that exports the Test-CollateralDownload function to test
automated HCS token / login / automated platform thumbnail download

.DESCRIPTION
This is part of the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist#Automated-collateral-download

This function runs HCS and invokes the Python script.

.INPUTS
None

.OUTPUTS
Numerical test result (TODO)

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

function Test-CollateralDownload {
    # Change directory to location of SDS executable
    Set-Location $SDSRootDir

    Write-Separator
    Write-Host "Collateral download testing"
    Write-Separator

    # Run HCS standalone
    Write-Host "Running HCS...";
    Start-HCS

    # Return to previous directory
    Set-Location $TestRoot

    # Run Python script
    $PythonScript = Start-Process $PythonExec -ArgumentList "$PythonCollateralDownloadTest `"$HCSAppDataDir`" $HCSTCPEndpoint" -NoNewWindow -PassThru -Wait

    # Stop HCS process after test is done
    Stop-HCS

    # Read test results from generated text file
    If (Test-Path "$TestRoot\hcs\CollateralDownloadResults.txt") {
        $results = (Get-Content "$TestRoot\hcs\CollateralDownloadResults.txt") -split ' '
        Return $results
    }
    Else {
        Write-Host -ForegroundColor Red "Error: Collateral download test failed, no result text file found."
        Return -1, -1
    }
}