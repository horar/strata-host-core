
<#
.SYNOPSIS
Strata Developer Studio installer test script

.DESCRIPTION
This is the automated installer test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist#Installer

.INPUTS SDSInstallerPath
Mandatory. If not being passed as an arugment to the secript you will be prompted to choose the path

.OUTPUTS
Result of the installer test

.NOTES
Version:        1.0
Creation Date:  03/10/2020

.PARAMETER SDSInstallerPath
 The path of Strata Developer Studio installer that will be tested
#>
function Test-SDSInstaller {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, Position=0)]
        [string]$SDSInstallerPath
    )

    $SDSInstallerLogFile = "$TestRoot\SDSInstallerLog.log"
    $SDSUninstallFile = "$SDSRootDir\unins"
    $SDSIniFile = "$env:AppData\ON Semiconductor\Strata Developer Studio.ini"
    $SDSControlViewsDir = "$SDSRootDir\views"

    $HCSIniFile = "$env:AppData\ON Semiconductor\hcs.ini"
    $HCSDbDir = "$HCSAppDataDir\db\strata_db\*"

    $VisualRedistDisplayName = "Microsoft Visual C++ 2017 X64 Additional Runtime - 14.16"
    $FTDIDriverDisplayName = "Windows Driver Package - FTDI CDM Driver Package - VCP Driver (08/16/2017 2.12.28)"

    $TestTotal = 21
    $global:SDSTestPass = 0

    #-----------------------------------------------------------[Functions]------------------------------------------------------------

    ## Remove Strata Developer Studio, Visual C++ 64x Tools, and FTDI Driver if already installed
    ## FTDI name: Windows Driver Package - FTDI CDM Driver Package
    ## Visual C++ name: Microsoft Visual C++ 2017 X64 Additional Runtime - 14.16.27033
    function Uninstall-SDSAndItsComponents {
        try {
            $SDSUninstallerPath =  Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | ForEach-Object { get-ItemProperty $_.PSPath } `
                                    | where-Object { $_ -match "strata*" } | Select-Object UninstallString
            if ($SDSUninstallerPath -match [regex]::Escape($SDSUninstallFile)) {
                $FTDIUininstallerPath =  Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | ForEach-Object { get-ItemProperty $_.PSPath } `
                                        | where-Object { $_ -match "ftdi*" } | Select-Object UninstallString
                $VisualRedistUninstallerPath = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | ForEach-Object { get-ItemProperty $_.PSPath } `
                                                | where-Object { $_ -match "strata*" } | Select-Object InstallLocation
                $SDSUninstallerPath = $SDSUninstallerPath.UninstallString -replace "/I","" -replace "`"",""
                $FTDIUininstallerPath = $FTDIUininstallerPath.UninstallString -replace "/I",""
                $VisualRedistUninstallerPath = $VisualRedistUninstallerPath.InstallLocation + "vc_redist.x64.exe" -replace "/I",""
                
                ## for ftdi driver you will get something like this in some cases 
                ## C:\PROGRA~1\DIFX\4A7292F75FEBBD3C\dpinst-amd64.exe /u C:\WINDOWS\System32\DriverStore\FileRepository\ftdiport.inf_amd64_90039b7dbf236588\ftdiport.inf
                ## C:\PROGRA~1\DIFX\4A7292F75FEBBD3C\dpinst-amd64.exe /u C:\WINDOWS\System32\DriverStore\FileRepository\ftdibus.inf_amd64_49b3e24305b20ada\ftdibus.inf
                ## and we need to remove both in oreder to remove ftdi driver compeletly
                if($FTDIUininstallerPath) {
                    Write-Indented "Uninstalling Windows Driver Package - FTDI CDM Driver Package"
                    $FTDIUininstallerPath = $FTDIUininstallerPath.split()
                    if ($FTDIUininstallerPath.Length -gt 3) {
                        $counter = 2
                        while ($counter -lt 6) {
                        Start-Process -FilePath "`"$($FTDIUininstallerPath[$counter-2])`"" -ArgumentList "$($FTDIUininstallerPath[$counter-1])", `
                                    "$($FTDIUininstallerPath[$counter])", "/q" -Wait
                        $counter = $counter + 3 
                        }
                        Write-Indented "Done"
                    } else {
                        Write-Indented "Uninstalling Windows Driver Package - FTDI CDM Driver Package"
                        Start-Process -FilePath "$($FTDIUininstallerPath[0])" -ArgumentList "$($FTDIUininstallerPath[1])", "$($FTDIUininstallerPath[2])", "/q" -Wait
                        Write-Indented "Done"
                    }
                } else {
                    Write-Indented "FTDI has not been installed using Strata installer"
                }
                if($VisualRedistUninstallerPath) {
                    Write-Indented "Uninstalling Microsoft Visual C++ 2017 X64"
                    Start-Process -FilePath "`"$VisualRedistUninstallerPath`"" -ArgumentList "/uninstall", "/quiet" -Wait
                    Write-Indented "Done"
                } else {
                    Write-Indented "Microsoft Visual C++ 2017 X64 is not installed"
                }
                Write-Indented "Uninstalling Strata Developer Studio"
                Start-Process -FilePath "`"$SDSUninstallerPath`"" -ArgumentList "/VERYSILENT" -Wait
                Write-Indented "Done"

            } else {
                Write-Indented "Strata Developer Studio is not installed"
            }
        }
        catch {
            Write-Indented "Error uninstalling Strata Developer Studio and its components failed. `n       $_"
            Exit-TestScript -1
        }
    }

    function Uninstall-SDS {
        Write-Indented "Uninstalling Strata Developer Studio"
        Try {
            $SDSUninstallerPath =  Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | ForEach-Object { get-ItemProperty $_.PSPath } `
                                | where-Object { $_ -match "strata*" } | Select-Object UninstallString
            if ($SDSUninstallerPath) {
                $SDSUninstallerPath = $SDSUninstallerPath.UninstallString -replace "/I","" -replace "`"",""
                $SDSUninstallation = Start-Process -FilePath "`"$SDSUninstallerPath`"" -ArgumentList "/VERYSILENT" -Wait -PassThru
                if ($SDSUninstallation.ExitCode -ne 0) {
                    write-Indented "Error: uninstalling Strata Developer Studio failed."
                    Exit-TestScript -1
                }
                Write-Indented "Done"
            } else {
                Write-Indented "Strata Developer Studio is not installed`n"
            } 
        }Catch {
                Write-Indented "Error: uninstalling Strata Developer Studio failed. `n        $_"
                Exit-TestScript -1
            }
    }
    function Install-SDS {
        Write-Indented "Installing Strata Developer Studio"
        Try {
            $SDSInstallation = Start-Process -FilePath "`"$SDSInstallerPath`"" -ArgumentList "/SP- /SUPPRESSMSGBOXES /LOG=$SDSInstallerLogFile /VERYSILENT /NORESTART /CLOSEAPPLICATIONS" -Wait -PassThru
                if ($SDSInstallation.ExitCode -ne 0) {
                    write-Indented "Error: installing Strata Developer Studio failed."
                    Exit-TestScript -1
                }
        } Catch {
                Write-Indented "Error: installing Strata Developer Studio failed. `n        $_"
                Exit-TestScript -1
            }
        Write-Indented "Done"
    }

    function Test-SDSInstallation {
        try {
            $VisualRedistInstalledDisplayName = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | ForEach-Object { get-ItemProperty $_.PSPath } `
                                                | Where-Object { $_ -match [regex]::Escape("Microsoft Visual C++ 2017 X64 Additional Runtime") } | Select-Object DisplayName
            $VisualRedistInstalledDisplayName = $VisualRedistInstalledDisplayName.DisplayName -replace "/I",""
            $FTDIDriverInstalledDisplayName = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | ForEach-Object { get-ItemProperty $_.PSPath } `
                                            | Where-Object { $_ -match "ftdi*" } | Select-Object DisplayName
            $FTDIDriverInstalledDisplayName = $FTDIDriverInstalledDisplayName.DisplayName -replace "/I", ""
            $SDSVersion = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" | ForEach-Object { get-ItemProperty $_.PSPath } `
                        | Where-Object { $_ -match ("Strata*") } | Select-Object DisplayName
            $SDSVersion = $SDSVersion.DisplayName -replace "/I","" -replace "Strata Developer Studio v",""
            $SDSInstallerVersion = Select-String -Path $SDSInstallerLogFile -Pattern "Installing Strata Developer Studio v(\d+)\.(\d+)\.(\d+)(.*)" | ForEach-Object {$_.Matches } `
                                | ForEach-Object {$_.Value}
            $SDSInstallerVersion = $SDSInstallerVersion -replace "Installing Strata Developer Studio v",""

            if ( $VisualRedistInstalledDisplayName -match [regex]::Escape($VisualRedistDisplayName) ) {
                Write-Indented "Pass: Microsoft Visual C++ 2017 X64 is installed"
                $global:SDSTestPass++
            } else {
                Write-Indented "Fail: Microsoft Visual C++ 2017 X64 is not installed" 
            }

            if ( $FTDIDriverInstalledDisplayName -eq $FTDIDriverDisplayName ) {
                Write-Indented "Pass: FTDI Driver is installed"
                $global:SDSTestPass++
            } else {
                Write-Indented "Warning: FTDI Driver is not installed by Strata installer, it probably got installed by Windows"
                $global:SDSTestPass++
            }

            if ( Test-path $SDSExecFile ) {
                Write-Indented "Pass: Strata Developer Studio executables is under the specified location by the installer"
                $global:SDSTestPass++
            } else {
                Write-Indented "Fail: Strata Developer Studio executables is not under the specified location by the installer." 
            }

            if ( Test-Path $SDSControlViewsDir -PathType Container ) {
                Write-Indented "Pass: Control Views are located on `"$SDSControlViewsDir`" which contains $(@(Get-ChildItem $SDSControlViewsDir).Count) platforms"
                $global:SDSTestPass++
            } else {
                Write-Indented "Fail: Control Views are not located in $SDSControlViewsDir" 
            }

            if ($SDSVersion -eq $SDSInstallerVersion) {
                Write-Indented  "Pass: Strata Developer Studio matches the installer version $SDSVersion"
                $global:SDSTestPass++
            } else {
                Write-Indented  "Fail: Strata Developer Studio does not match the installer version $SDSVersion"
            }
        }
        catch {
            Write-Indented "Error: Installation test failed. `n       $_"
            Return $global:SDSTestPass, $TestTotal
        }
    }

    function Test-SDSCleanUninstallation {
        Write-Host "`nStarting Clean Installation Test:"
        Uninstall-SDSAndItsComponents
        Install-SDS
        Test-SDSInstallation
    }
    function Test-SDSDirtyInstallationWithoutUninstallation {
        Write-Host "`nStarting Dirty Installation Test Rejecting Uninstall Prompt:"
        # necessary to generate hcs database
        Start-HCSAndWait(5)
        Stop-HCS
        Install-SDS
        Test-SDSInstallation
        try {
            if (! (Test-Path "$HCSDbDir") ) {
                Write-Indented  "Pass: HCS database has been deleted"
                $global:SDSTestPass++
            } else {
                Write-Indented  "Fail: HCS database has not been deleted"
            }
        }
        catch {
            Write-Indented "Error: Ditry installation without uninstallation failed. `n       $_"
            Return $global:SDSTestPass, $TestTotal
        }
    }

    function Test-SDSDirtyInstallationWithUninstallation {
        Write-Host "`nStarting Dirty Installation Test Accepting Uninstall Prompt:"
        Install-SDS
        Test-SDSInstallation
    }

    function Test-SDSUninstallation {
        Write-Host "`nStarting Uninstallation Test:"
        # necessary to generate Strata Developer Studio.ini file
        Start-SDSAndWait(5)
        Stop-SDS
        Stop-HCS
        Uninstall-SDS
        try {
            if (! (Test-Path $SDSExecFile) ) {
                Write-Indented  "Pass: Strata Developer Studio executables has been successfuly removed"
                $global:SDSTestPass++
            } else {
                Write-Indented  "Fail: Strata Developer Studio executables has not been successfuly removed"
            }  
            if (! (Test-Path $SDSControlViewsDir) ) {
                Write-Indented  "Pass: $SDSControlViewsDir has been successfuly removed"
                $global:SDSTestPass++
            } else {
                Write-Indented  "Fail: $SDSControlViewsDir has not been successfuly removed"
            }
            if (! (Test-Path $HCSAppDataDir) ) {
                Write-Indented  "Pass: $HCSAppDataDir has been successfuly removed"
                $global:SDSTestPass++
            } else {
                Write-Indented  "Fail: $HCSAppDataDir has not been successfuly removed"
            }
            if (! (Test-Path $HCSIniFile) ) {
                Write-Indented  "Pass: $HCSIniFile has been successfuly removed"
                $global:SDSTestPass++
            } else {
                Write-Indented  "Fail: $HCSIniFile has not been successfuly removed"
            }
            if (! (Test-Path $SDSIniFile) ) {
                Write-Indented  "Pass: $SDSIniFile has been successfuly removed"
                $global:SDSTestPass++
            } else {
                Write-Indented  "Fail: $SDSIniFile has not been successfuly removed"
            }
        }
        catch {
            Write-Indented "Error: Uninstallation test failed. `n       $_"
            Return $global:SDSTestPass, $TestTotal
        }
    }

    Write-Separator
    Write-Host "Strata installer testing"
    Write-Separator

    Stop-SDS
    Stop-HCS
    Test-SDSCleanUninstallation
    Test-SDSDirtyInstallationWithoutUninstallation
    Test-SDSUninstallation
    Test-SDSDirtyInstallationWithUninstallation


    # Return number of tests passed, number of tests existing
    Return $global:SDSTestPass, $TestTotal
}
