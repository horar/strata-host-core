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

# Define variables for server/token credentials (only applicable if TEST_request_token is $true)
Set-Variable "TEST_request_token" $true
Set-Variable "SDS_server"         "http://18.191.108.5/"      # "https://strata.onsemi.com"
Set-Variable "SDS_login_server"   "http://18.191.108.5/login" # "https://strata.onsemi.com/login"
Set-Variable "SDS_login_info"     '{"username":"test@test.com","password":"Strata12345"}'

# Define paths for Python scripts ran by this script
Set-Variable "Python_CollateralDownloadTest" "hcs/hcs-collateral-download-test.py"
Set-Variable "Python_ControlViewTest"        "strataDev/control-view-test.py"

# Import common functions
. "$PSScriptRoot\Common-Functions.ps1"

# Import functions for test "Test-Database" 
. "$PSScriptRoot\hcs\Test-Database.ps1"

# Import functions for test "Test-TokenAndViewsDownload"
. "$PSScriptRoot\hcs\Test-TokenAndViewsDownload.ps1"

# Import functions for test "Test-CollateralDownload"
. "$PSScriptRoot\hcs\Test-CollateralDownload.ps1"

# Import functions for test "Test-SDSControlViews"
. "$PSScriptRoot\strataDev\Test-SDSControlViews.ps1"

#------------------------------------------------------[Pre-requisite checks]------------------------------------------------------

Write-Host "`n`nPerforming initial checks...`n"

# Search for Python tools 
If ((Assert-PythonAndPyzmq) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

# Search for SDS and HCS
If ((Assert-StrataAndHCS) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

# Search for Python scripts
If ((Assert-PythonScripts) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

# Search for PSSQLite
If ((Assert-PSSQLite) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting tests...`n"

# Run Test-Database (HCS database testing)
Test-Database

# Run Test-TokenAndViewsDownload
Test-TokenAndViewsDownload

# Run Test-CollateralDownload (HCS collateral download testing)
Test-CollateralDownload

# Run Test-SDSControlViews (SDS control view testing)
If ((Test-SDSControlViews -PythonScriptPath $Python_ControlViewTest -StrataPath $SDS_exec_file) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

#------------------------------------------------------------[Clean up]-------------------------------------------------------------

Restore-Strata_INI

Write-Host "`n`nTesting complete!`n`n"