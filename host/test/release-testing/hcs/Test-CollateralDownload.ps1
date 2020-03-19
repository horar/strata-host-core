# Function to run the test for automated collateral download
# Invokes python script 
function Test-CollateralDownload {
    # Change directory to location of SDS executable
    Set-Location $SDSRootDir

    # Run HCS standalone
    Write-Host "Running HCS...";
    Start-HCS

    # Return to previous directory
    Set-Location $TestRoot

    # Run Python script
    & $PythonExec $Python_CollateralDownloadTest $AppDataHCSDir $HCS_TCP_endpoint

    # Stop HCS process after test is done
    Stop-HCS
}