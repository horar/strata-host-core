<#
.SYNOPSIS
Main Strata Developer Studio / Host Controller Service / Installer script driver

.DESCRIPTION
This is the main driver for the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist

.INPUTS  SDSInstallerPath
Optional. If not being passed as an argument to the script you will be prompted to choose the path
-SDSExecPath Optional. If not being passed as an argument to the script you will be prompted to choose the path
-TestsToRun Optional Comma-separated list of tests to run
-DPEnv Optional The Deployment Portal environment. (PROD, OTA, or DEV)
-EnablePlatformIdentificationTest Optional switch to enable the platform Identification test.
-IncludeOTA Optional switch to enable OTA testing

.OUTPUTS
Result of the test

.NOTES
Version:        1.0
Creation Date:  03/17/2020
Requires: PowerShell version 5, and Python 3
in case of a problem with executing the script run:
Set-ExecutionPolicy -Scope CurrentUser Unrestricted

platform Identification test requires JLink device and a platform connected.

.Example
Test-StrataRelease.ps1 -SDSInstallerPath "<PATH_TO_STRATA_INSTALLER>"

.Example
Test-StrataRelease.ps1

.Example
Test-StrataRelease.ps1 -SDSInstallerPath "<PATH_TO_STRATA_INSTALLER>" -EnablePlatformIdentificationTest -IncludeOTA

.Example
Test-StrataRelease.ps1 -SDSExecPath "<PATH_TO_STRATA_EXE>" -Tests hcs,gui,platformIdentification

#>

[CmdletBinding()]
    param(
        [Parameter(Mandatory=$False, Position=0, HelpMessage="Please enter a path for Strata Installer")]
        [string]$SDSInstallerPath,

        [Parameter(Mandatory=$False, HelpMessage="Please enter the path to a SDS executable.")]
        [string]$SDSExecPath,

        [Parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, ValueFromRemainingArguments=$True)]
        [ValidateSet("gui", "database", "collateral", "controlViews", "hcs", "platformIdentification", "tokenAndViews", "all")]
        [string[]]
        [Alias("t")]
        $TestsToRun = ("all"),

        [Parameter(Mandatory=$False, HelpMessage="Please specify either DEV or QA for your DPEnv")]
        [ValidateSet("DEV", "QA")]
        [string]$DPEnv = "QA",

        [switch]$EnablePlatformIdentificationTest,
        [switch]$IncludeOTA
    )

# Define HCS TCP endpoint to be used
Set-Variable "HCSTCPEndpoint" "tcp://127.0.0.1:5563"

Set-Variable "TestingExecutable" $PSBoundParameters.ContainsKey('SDSExecPath')

# Define paths
if ($TestingExecutable -eq $True) {
    Set-Variable "SDSRootDir"    "$SDSExecPath\.."
} else {
    Set-Variable "SDSRootDir"    "$Env:ProgramFiles\ON Semiconductor\Strata Developer Studio"
}

Set-Variable "HCSAppDataDir" "$Env:AppData\ON Semiconductor\Host Controller Service"
Set-Variable "StrataDeveloperStudioIniDir" "$Env:AppData\ON Semiconductor\"

if ($TestingExecutable -eq $True) {
    Set-Variable "HCSConfigFile" "$SDSRootDir\hcs.config"
} else {
    Set-Variable "HCSConfigFile" "$Env:ProgramData\ON Semiconductor\Strata Developer Studio\HCS\hcs.config"
}

Set-Variable "HCSExecFile"   "$SDSRootDir\hcs.exe"
Set-Variable "SDSExecFile"   "$SDSRootDir\Strata Developer Studio.exe"

if ($TestingExecutable -eq $True) {
    Set-Variable "HCSEnv"        "$DPEnv"
} else {
    Set-Variable "HCSEnv"        "PROD"
}

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

# Validate Strata installer path
if ($TestingExectuable -eq $False) {
    Assert-SDSInstallerPath
}

# Search for PSSQLite
Assert-PSSQLite

# Search for Python tools
Assert-PythonAndRequirements

# Search for Python scripts
Assert-PythonScripts

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "`nStarting tests...`n"

# Run Test-SDSInstaller
if ($TestingExecutable -eq $False) {
    $SDSInstallerResults = Test-SDSInstaller -SDSInstallerPath $SDSInstallerPath
}

# Search for SDS and HCS
Assert-StrataAndHCS

# Run Test-Database (HCS database testing)
if ($TestingExecutable -eq $False -or $TestsToRun -contains "all" -or $TestsToRun -contains "database") {
    $DatabaseResults = Test-Database
}
# Run Test-TokenAndViewsDownload
if ($TestingExecutable -eq $False -or $TestsToRun -contains "all" -or $TestsToRun -contains "tokenAndViews") {
    $TokenAndViewsDownloadResults = Test-TokenAndViewsDownload
}

#Run Test-GUI
if ($TestingExecutable -eq $False -or $TestsToRun -contains "all" -or $TestsToRun -contains "gui") {
    $GUIResults = Test-GUI
}

#Run Test-CollateralDownload (HCS collateral download testing)
if ($TestingExectuable -eq $False -or $TestsToRun -contains "all" -or $TestsToRun -contains "collateral") {
    $CollateralDownloadResults = Test-CollateralDownload
}

#Run Test-PlatformIdentification
# The test is disabled by default, The reason is that it requires having a platform and a JLink connected to the test machine.
# To enable the test, pass this flag -EnablePlatformIdentificationTest when running Test-StrataRelease.ps script
if (($EnablePlatformIdentificationTest -and ($TestingExectuable -eq $False -or $TestsToRun -contains "all")) -or $TestsToRun -contains "platformIndentification") {
    $PlatformIdentificationResults = Test-PlatformIdentification -PythonScriptPath $PythonPlatformIdentificationTest -ZmqEndpoint $HCSTCPEndpoint
}

# Run Test-SDSControlViews (SDS control view testing)
# Because the recent changes in the Navigation of Strata Developer Studio, this test is not working as expected.
# These issues will be resolved in CS-626
if ($TestingExecutable -eq $False -or $TestsToRun -contains "all" -or $TestsToRun -contains "controlViews") {
    #$SDSControlViewsResults = Test-SDSControlViews -PythonScriptPath $PythonControlViewTest -StrataPath $SDSExecFile -ZmqEndpoint $HCSTCPEndpoint
}
Show-TestSummary

#------------------------------------------------------------[Clean up]-------------------------------------------------------------

Restore-Strata_INI
Remove-TemporaryFiles

Write-Host "`n`nTesting complete!`n`n"