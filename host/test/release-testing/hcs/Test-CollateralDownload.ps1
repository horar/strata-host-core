# Function to run the test for automated collateral download
# Invokes python script 
function Test-CollateralDownload {
    # Change directory to location of SDS executable
    Set-Location $SDS_root_dir

    # Run HCS standalone
    Write-Host "Running HCS...";
    Start-HCS

    # Return to previous directory
    Set-Location $Test_Root

    # Run Python script
    & $PythonExec $Python_CollateralDownloadTest $AppData_HCS_dir $HCS_TCP_endpoint
}