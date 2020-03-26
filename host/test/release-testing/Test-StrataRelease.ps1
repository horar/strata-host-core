<#
.SYNOPSIS
Main Strata Developer Studio / Host Controller Service / Installer script driver

.DESCRIPTION
This is the main driver for the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist

.INPUTS
None

.OUTPUTS
Result of the test

.NOTES
Version:        1.0
Creation Date:  03/17/2020

Powershell 5, Python 3
#>

# Define HCS TCP endpoint to be used
Set-Variable "HCSTCPEndpoint" "tcp://127.0.0.1:5563"

# Define paths
Set-Variable "SDSRootDir"    "$Env:ProgramFiles\ON Semiconductor\Strata Developer Studio"
Set-Variable "AppDataHCSDir" "$Env:AppData\ON Semiconductor\hcs"
Set-Variable "HCSConfigFile" "$Env:ProgramData\ON Semiconductor\Strata Developer Studio\HCS\hcs.config"
Set-Variable "HCSExecFile"   "$SDSRootDir\HCS\hcs.exe"
Set-Variable "SDSExecFile"   "$SDSRootDir\Strata Developer Studio.exe"
Set-Variable "HCSDbFile"     "$AppDataHCSDir\db\strata_db\db.sqlite3"
Set-Variable "TestRoot"      $PSScriptRoot

# Define variables for server authentication credentials needed to acquire login token
Set-Variable "SDSServer"      "http://18.191.108.5/"      # "https://strata.onsemi.com"
Set-Variable "SDSLoginServer" "http://18.191.108.5/login" # "https://strata.onsemi.com/login"
Set-Variable "SDSLoginInfo"   '{"username":"test@test.com","password":"Strata12345"}'

# Define paths for Python scripts ran by this script
Set-Variable "PythonCollateralDownloadTest" "$TestRoot/hcs/hcs-collateral-download-test.py"
Set-Variable "PythonControlViewTest"        "$TestRoot/strataDev/control-view-test.py"

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
Assert-PythonAndPyzmq

# Search for SDS and HCS
Assert-StrataAndHCS

# Search for Python scripts
Assert-PythonScripts

# Search for PSSQLite
Assert-PSSQLite

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting tests...`n"

# Run Test-Database (HCS database testing)
$DatabaseResults = Test-Database

# Run Test-TokenAndViewsDownload
$TokenAndViewsDownloadResults = Test-TokenAndViewsDownload

# Run Test-CollateralDownload (HCS collateral download testing)
$CollateralDownloadResults = Test-CollateralDownload

# Run Test-SDSControlViews (SDS control view testing)
$SDSControlViewsResults = Test-SDSControlViews -PythonScriptPath $PythonControlViewTest -StrataPath $SDSExecFile -ZmqEndpoint $HCSTCPEndpoint

Show-TestSummary

#------------------------------------------------------------[Clean up]-------------------------------------------------------------

Restore-Strata_INI

Remove-TemporaryFiles

Set-Location $PSScriptRoot

Write-Host "`n`nTesting complete!`n`n"