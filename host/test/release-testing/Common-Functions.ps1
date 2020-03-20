<#
.SYNOPSIS
Modular file that exports several common functions used by the testing scripts in this directory

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

# Check if python and pyzmq are installed
function Assert-PythonAndPyzmq {
    # Determine the python command based on OS. OSX will execute Python 2 by default and here we need to use Python 3.
    # on Win, Python 3 is not in the path by default, as a result we'll need to use 'python3' for OSX and 'python' for Win
    If ($Env:OS -Eq "Windows_NT") {
        $global:PythonExec = 'python'
    } Else {
        $global:PythonExec = 'python3'
    }

    Try {
        If ((Start-Process $PythonExec --version -Wait -WindowStyle Hidden -PassThru).ExitCode -Eq 0) {
            If (!(Start-Process $PythonExec '-c "import zmq"' -WindowStyle Hidden -Wait -PassThru).ExitCode -Eq 0) {
                Exit-TestScript -1 "Error: ZeroMQ library for Python is required, visit https://zeromq.org/languages/python/ for instructions.`nAborting."
            }
        } Else {
            Exit-TestScript -1 "Error: Python not found.`nAborting."
        }
    } Catch [System.Management.Automation.CommandNotFoundException] {
        Exit-TestScript -1 "Error: Python not found.`nAborting."
    }
}

# Check if both SDS and HCS are found where expected
function Assert-StrataAndHCS {
    # Convert the path if using Unix env, then check for SDS executable
    If ($Env:OS -Ne "Windows_NT" -And (($SDSExecFile = Convert-Path $SDSExecFile) -Eq $false)) {
        Exit-TestScript -1 "Error: cannot find Strata Developer Studio executable at $SDSExecFile.`nAborting."
    }
    # Check for SDS executable
    If (!(Test-Path $SDSExecFile)) {
        Exit-TestScript -1 "Error: cannot find Strata Developer Studio executable at $SDSExecFile.`nAborting."
    }
    # Check for HCS directory
    If (!(Test-Path $AppDataHCSDir)) {
        Exit-TestScript -1 "Error: cannot find Host Controller Service directory at $AppDataHCSDir.`nAborting."
    }
}

# Check if both Python scripts are found where expected
function Assert-PythonScripts {
    If (!(Test-Path $PythonCollateralDownloadTest)) {
        Exit-TestScript -1 "Error: cannot find Python script at $PythonCollateralDownloadTest.`nAborting."
    }
    If (!(Test-Path $PythonControlViewTest)) {
        Exit-TestScript -1 "Error: cannot find Python script at $PythonControlViewTest.`nAborting."
    }
}

# Check if PS module 'PSSQLite' is installed
# Tell user to manually install it if not found & exit
function Assert-PSSQLite {
    If (!(Get-Module -ListAvailable -Name PSSQLite)) {
        Write-Warning "`n`nPSSQLite Powershell module not found: cannot proceed.`nInstall module PSSQLite by running as administrator:"
        Write-Warning "   Install-Module PSSQLite`nAborting.`n"
        Exit-TestScript -1
    }
}

# Start one instance of HCS
function Start-HCS {
    Start-Process -FilePath $HCSExecFile -ArgumentList "-f `"$HCSConfigFile`""
    Start-Sleep -Seconds 1
}

# Utility function to print the exit code and a pattern for the end of the script
function Exit-TestScript {
    Param (
        [Parameter(Mandatory = $true)][int]$ScriptExitCode,
        [Parameter(Mandatory = $false)][string]$ScriptExitText
    )

    If ($ScriptExitCode -Eq 0) {
        Write-Host "Test finished successfully. Exiting..." -ForegroundColor Green
    } Else {
        If ($ScriptExitText) {
            Write-Error "Test failed: $($ScriptExitText) Terminating... $($ScriptExitCode)"
        } Else {
            Write-Error "Test failed. Terminating... $($ScriptExitCode)"
        }
    }
    Write-Host "================================================================================"
    Write-Host "================================================================================"
    Exit $ScriptExitCode
}

# Stops all processes by the name of "hcs" running in the local machine
function Stop-HCS {
    If (Get-Process -Name "hcs" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "hcs" -Force
        Start-Sleep -Seconds 1
    }
}

# Stops all processes by the name of "Strata Developer Studio" running in the local machine
function Stop-SDS {
    If (Get-Process -Name "Strata Developer Studio" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "Strata Developer Studio" -Force
        Start-Sleep -Seconds 1
    }
}

# Start one instance of HCS and wait (to give time for DB replication)
function Start-HCSAndWait {
    Param (
        [Parameter(Mandatory = $false)][int]$seconds
    )

    Start-Process -FilePath $HCSExecFile -ArgumentList "-f `"$HCSConfigFile`""
    If ($seconds) {
        Start-Sleep -Seconds $seconds
    }
}

function Restore-Strata_INI {
    # Delete temporary .ini file and restore original
    Set-Variable "AppData_OnSemi_dir" (Split-Path -Path $AppDataHCSDir)
    If (Test-Path "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini" -PathType Leaf) {
        Remove-Item -Path "$AppData_OnSemi_dir\Strata Developer Studio.ini"
        Rename-Item "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini" "$AppData_OnSemi_dir\Strata Developer Studio.ini"
    }
}
