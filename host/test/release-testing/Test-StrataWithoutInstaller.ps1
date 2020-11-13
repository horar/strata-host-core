<#
.SYNOPSIS
This script does everything that Test-StrataRelease.ps1 does, but without the installer. It takes a pre-installed Developer Studio executable

.DESCRIPTION
This is the main driver for the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist

.INPUTS  
-SDSExecPath Mandatory. If not being passed as an argument to the script you will be prompted to choose the path
-TestsToRun Mandatory Comma-separated list of tests to run
-DPEnv Mandatory The Deployment Portal environment. (PROD, OTA, or DEV)
-IncludeOTA Optional switch to enable testing of OTA

.OUTPUTS
Result of the test

.NOTES
Version:        1.0
Creation Date:  11/06/2020
Requires: PowerShell version 5, and Python 3
in case of a problem with executing the script run:
Set-ExecutionPolicy -Scope CurrentUser Unrestricted

platform Identification test requires JLink device and a platform connected.

.Example
Test-StrataRelease.ps1 -SDSExecPath "<PATH_TO_STRATA_EXE>" -Tests hcs,gui,platformIdentification

.Example
Test-StrataRelease.ps1
#>

[CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0, HelpMessage="Please enter a path for Strata Installer")]
        [string]$SDSExecPath,

        [Parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, ValueFromRemainingArguments=$True)]
        [ValidateSet("gui", "database", "collateral", "controlViews", "hcs", "platformIdentification", "tokenAndViews", "all")]
        [string[]]
        [Alias("t")]
        $TestsToRun,

        [Parameter(Mandatory=$True, HelpMessage="Please specify either DEV or QA for your DPEnv")]
        [ValidateSet("DEV", "QA")]
        [string]$DPEnv,

        [switch]$IncludeOTA,
        [switch]$EnablePlatformIdentificationTest
    )

# Define HCS TCP endpoint to be used
Set-Variable "HCSTCPEndpoint" "tcp://127.0.0.1:5563"

# Define paths
Set-Variable "SDSRootDir"    "$SDSExecPath\.."
Set-Variable "HCSAppDataDir" "$Env:AppData\ON Semiconductor\Host Controller Service"
Set-Variable "StrataDeveloperStudioIniDir" "$Env:AppData\ON Semiconductor\"
Set-Variable "HCSConfigFile" "$SDSRootDir\hcs.config"
Set-Variable "HCSExecFile"   "$SDSRootDir\hcs.exe"
Set-Variable "HCSEnv"        "$DPEnv"
Set-Variable "SDSExecFile"   "$SDSExecPath"
Set-Variable "HCSDbFile"     "$HCSAppDataDir\$HCSEnv\db\strata_db\db.sqlite3"
Set-Variable "TestRoot"      $PSScriptRoot
Set-Variable "JLinkExePath"  "${Env:ProgramFiles(x86)}\SEGGER\JLink\JLink.exe"
Set-Variable "RequirementsFile" "$TestRoot\requirements.txt"

# Define variables for server authentication credentials needed to acquire login token
Set-Variable "SDSServer"      "http://18.191.108.5/"      # "https://strata.onsemi.com"
Set-Variable "SDSLoginServer" "http://18.191.108.5/login" # "https://strata.onsemi.com/login"
Set-Variable "SDSLoginInfo"   '{"username":"test@test.com","password":"Strata12345"}'

# Define paths for Python scripts ran by this script
Set-Variable "PythonCollateralDownloadTest"     "$PSScriptRoot/hcs/hcs-collateral-download-test.py"
Set-Variable "PythonControlViewTest"            "$PSScriptRoot/strataDev/control-view-test.py"
Set-Variable "PythonPlatformIdentificationTest" "$PSScriptRoot/PlatformIdentification/platform-identification-test.py"
Set-Variable "PythonGUIMain"                    "$PSScriptRoot/gui-testing/runtest.py"
Set-Variable "PythonGUIMainLoginTestPre"        "$PSScriptRoot/gui-testing/main_login_test_pre.py"

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

# Import functions for test "Test-SDSInstaller"
. "$PSScriptRoot\installer\Test-SDSInstaller.ps1"

# Import functions for test "Test-PlatformIdentification"
. "$PSScriptRoot\PlatformIdentification\Test-PlatformIdentification.ps1"

#Import functions for test "Test-GUI"
. "$PSScriptRoot\gui-testing\Test-GUI.ps1"

#------------------------------------------------------[Pre-requisite checks]------------------------------------------------------

Write-Host "`n`nPerforming initial checks...`n"

# Validate UAC and administration privileges
Assert-UACAndAdmin

# Search for PSSQLite
Assert-PSSQLite

# Search for Python tools
Assert-PythonAndRequirements

# Search for Python scripts
Assert-PythonScripts

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "`nStarting tests...`n"

# Search for SDS and HCS
Assert-StrataAndHCS

# Run Test-Database (HCS database testing)
if ($TestsToRun -contains "all" -or $TestsToRun -contains "database") {
    $DatabaseResults = Test-Database
}

# Run Test-TokenAndViewsDownload
if ($TestsToRun -contains "all" -or $TestsToRun -contains "tokenAndViews") {
    $TokenAndViewsDownloadResults = Test-TokenAndViewsDownload
}

#Run Test-GUI
if ($TestsToRun -contains "all" -or $TestsToRun -contains "gui") {
    $GUIResults = Test-GUI
}

#Run Test-CollateralDownload (HCS collateral download testing)
if ($TestsToRun -contains "all" -or $TestsToRun -contains "collateral") {
    $CollateralDownloadResults = Test-CollateralDownload
}

#Run Test-PlatformIdentification
# The test is disabled by default, The reason is that it requires having a platform and a JLink connected to the test machine.
# To enable the test, pass this flag -EnablePlatformIdentificationTest when running Test-StrataRelease.ps script
if (($TestsToRun -contains "all" -and $EnablePlatformIdentificationTest -eq $True) -or $TestsToRun -contains "platformIndentification") {
    $PlatformIdentificationResults = Test-PlatformIdentification -PythonScriptPath $PythonPlatformIdentificationTest -ZmqEndpoint $HCSTCPEndpoint
}

# Run Test-SDSControlViews (SDS control view testing)
# Because the recent changes in the Navigation of Strata Developer Studio, this test is not working as expected.
# These issues will be resolved in CS-626
if ($TestsToRun -contains "all" -or $TestsToRun -contains "controlViews") {
    #$SDSControlViewsResults = Test-SDSControlViews -PythonScriptPath $PythonControlViewTest -StrataPath $SDSExecFile -ZmqEndpoint $HCSTCPEndpoint
}

Write-Separator
Write-Host "Test Summary"
Write-Separator

if ($TestsToRun -contains "all" -or $TestsToRun -contains "database") {
    Show-TestResult -TestName "Test-Database" -TestResults $DatabaseResults
}

if ($TestsToRun -contains "all" -or $TestsToRun -contains "tokenAndViews") {
    Show-TestResult -TestName "Test-TokenAndViewsDownload" -TestResults $TokenAndViewsDownloadResults
}

if ($TestsToRun -contains "all" -or $TestsToRun -contains "collateral") {
    Show-TestResult -TestName "Test-CollateralDownload" -TestResults $CollateralDownloadResults
}

if ($TestsToRun -contains "all" -or $TestsToRun -contains "gui") {
    Show-TestResult -TestName "Test-GUI" -TestResults $GUIResults
}

if ($TestsToRun -contains "platformIndentification") {
    Show-TestResult -TestName "Test-PlatformIdentification" -TestResults $PlatformIdentificationResults
}

If ($SDSControlViewsResults) {
    If ($SDSControlViewsResults -Eq $true) {
        Write-Host -ForegroundColor Green "`nResult for Test-SDSControlViews: No errors found during execution, test requires visual inspection."
    } Else {
        Write-Host -ForegroundColor Red "`nResult for Test-SDSControlViews: One or more errors found during execution."
    }
}
#------------------------------------------------------------[Clean up]-------------------------------------------------------------

# Restore-Strata_INI
# Remove-TemporaryFiles

Write-Host "`n`nTesting complete!`n`n"