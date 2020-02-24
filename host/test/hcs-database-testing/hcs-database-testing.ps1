<#
    Automated HCS database testing
#>

# Path for SDS executable
Set-Variable -Name "SDS_exec_directory" -Value "C:\Program Files\ON Semiconductor\Strata Developer Studio"

# Change directory to location of SDS executable
Set-Location $SDS_exec_directory

# Run Strata Developer Studio
Start-Process -FilePath "$SDS_exec_directory\Strata Developer Studio.exe"