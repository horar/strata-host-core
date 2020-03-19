<#
.SYNOPSIS
Main Strata Developer Studio / Host Controller Service / Installer script driver

.DESCRIPTION
This is the main driver for the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist#Installer

.INPUTS

.OUTPUTS
Result of the test

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

# Define HCS TCP endpoint to be used
Set-Variable "HCS_TCP_endpoint" "tcp://127.0.0.1:5563"

# Define paths
Set-Variable "SDS_root_dir"    "$Env:ProgramFiles\ON Semiconductor\Strata Developer Studio"
Set-Variable "AppData_HCS_dir" "$Env:AppData\ON Semiconductor\hcs"
Set-Variable "HCS_config_file" "$Env:ProgramData\ON Semiconductor\Strata Developer Studio\HCS\hcs.config"
Set-Variable "HCS_exec_file"   "$SDS_root_dir\HCS\hcs.exe"
Set-Variable "SDS_exec_file"   "$SDS_root_dir\Strata Developer Studio.exe"
Set-Variable "HCS_db_file"     "$AppData_HCS_dir\db\strata_db\db.sqlite3"
Set-Variable "Test_Root"       $PSScriptRoot

# Define paths for Python scripts ran by this script
Set-Variable "Python_CollateralDownloadTest" "hcs/hcs-collateral-download-test.py"
Set-Variable "Python_ControlViewTest"        "strataDev/control-view-test.py"

# Import common functions
. "$PSScriptRoot\Common-Functions.ps1"

# Import functions for test "Test-Database" 
. "$PSScriptRoot\hcs\Test-Database.ps1"

# Import functions for test "Test-CollateralDownload"
. "$PSScriptRoot\hcs\Test-CollateralDownload.ps1"

# Import functions for test "Test-SDSControlViews"
. "$PSScriptRoot\strataDev\Test-SDSControlViews.ps1"

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "`n`nStarting tests...`n"

# Search for Python tools
If ((Test-PythonAndPyzmqExist) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

# Search for SDS and HCS
If ((Test-StrataAndHCSExist) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

# Search for Python scripts
If ((Test-PythonScriptsExist) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

# Check for PSSQLite
# Tell user to manually install it & exit if not found
If (!(Get-Module -ListAvailable -Name PSSQLite)) {
    Write-Host "`n`nPSSQLite Powershell module not found: cannot proceed.`nInstall module PSSQLite by running as administrator:"
    Write-Host "   Install-Module PSSQLite`n`n"
    Exit-TestScript -ScriptExitCode -1
}

# Run Test-Database (HCS database testing)
Test-Database

# # Run Test-CollateralDownload (HCS collateral download testing)
Test-CollateralDownload

# # Run Test-SDSControlViews (SDS control view testing)
If ((Test-SDSControlViews -PythonScriptPath $Python_ControlViewTest -StrataPath $SDS_exec_file) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

Write-Host "`n`nTesting complete.`n`n"
