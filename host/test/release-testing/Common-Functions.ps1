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
                Write-Error "Error: ZeroMQ library for Python is required, visit https://zeromq.org/languages/python/ for instructions.`nAborting."
                Return $false
            }
        } Else {
            Write-Error "Error: Python not found.`nAborting."
            Return $false
        }
    } Catch [System.Management.Automation.CommandNotFoundException] {
        Write-Error "Error: Python not found.`nAborting."
        Return $false
    }
    Return $true
}

# Check if both SDS and HCS are found where expected
function Assert-StrataAndHCS {
    # Convert the path if using Unix env
    If ($Env:OS -Ne "Windows_NT" -And (($SDS_exec_file = Convert-Path $SDS_exec_file) -Eq $false)) {
        Return $false
    }
    # Check for SDS executable
    If (!(Test-Path $SDS_exec_file)) {
        Return $false
    }
    # Check for HCS directory
    If (!(Test-Path $AppData_HCS_dir)) {
        Return $false
    }
    Return $true
}

# Check if both Python scripts are found where expected
function Assert-PythonScripts {
    If (!(Test-Path $Python_CollateralDownloadTest)) {
        Return $false
    }
    If (!(Test-Path $Python_ControlViewTest)) {
        Return $false
    }
    Return $true
}

# Check if PS module 'PSSQLite' is installed
# Tell user to manually install it if not found & exit
function Assert-PSSQLite {
    If (!(Get-Module -ListAvailable -Name PSSQLite)) {
        Write-Warning "`n`nPSSQLite Powershell module not found: cannot proceed.`nInstall module PSSQLite by running as administrator:"
        Write-Warning "   Install-Module PSSQLite`nAborting.`n"
        Return $false
    }
    Return $true
}

# Start one instance of HCS
function Start-HCS {
    Start-Process -FilePath $HCS_exec_file -ArgumentList "-f `"$HCS_config_file`""
    Start-Sleep -Seconds 1
}

# Utility function to print the exit code and a pattern for the end of the script
function Exit-TestScript {
    Param (
        [Parameter(Mandatory = $true)][int]$ScriptExitCode
    )

    If ($ScriptExitCode -eq 0) {
        Write-Host "Test finished successfully. Exiting..." -ForegroundColor Green
    } Else {
        Write-Error "Test failed. Terminating..." $ScriptExitCode
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
    param($seconds)
    Start-Process -FilePath $HCS_exec_file -ArgumentList "-f `"$HCS_config_file`""
    If ($seconds) {
        Start-Sleep -Seconds $seconds
    }
}

function Restore-Strata_INI {
    # Delete temporary .ini file and restore original
    Set-Variable "AppData_OnSemi_dir" (Split-Path -Path $AppData_HCS_dir)
    If (Test-Path "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini" -PathType Leaf) {
        Remove-Item -Path "$AppData_OnSemi_dir\Strata Developer Studio.ini"
        Rename-Item "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini" "$AppData_OnSemi_dir\Strata Developer Studio.ini"
    }
}
