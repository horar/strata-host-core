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

# Define paths for Python scripts ran by this script
Set-Variable "Python_CollateralDownloadTest" "hcs/hcs-collateral-download-test.py"
Set-Variable "Python_ControlViewTest"        "strataDev/control-view-test.py"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

# Check if python and pyzmq are installed
function Test-PythonAndPyzmqExist {
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
                Write-Host "Error: ZeroMQ library for Python is required, visit https://zeromq.org/languages/python/ for instructions. Aborting." -ForegroundColor Red
                Return $false
            }
        } Else {
            Write-Host "Error: Python not found. Aborting." -ForegroundColor Red
            Return $false
        }
    } Catch [System.Management.Automation.CommandNotFoundException] {
        Write-Host "Error: Python not found. Aborting." -ForegroundColor Red
        Return $false
    }
    Return $true
}

# Check if both SDS and HCS are found where expected
function Test-StrataAndHCSExist {
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
}

# Check if both Python scripts are found where expected
function Test-PythonScriptsExist {
    If (!(Test-Path $Python_CollateralDownloadTest)) {
        Return $false
    }
    If (!(Test-Path $Python_ControlViewTest)) {
        Return $false
    }
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
        Write-Host "Test failed. Terminating..." $ScriptExitCode -ForegroundColor Red
    }
    Write-Host "================================================================================"
    Write-Host "================================================================================"
    Exit $ScriptExitCode
}

# Function to run the test for automated collateral download, it will return True if the test was successful
function Test-CollateralDownload {
    # Change directory to location of SDS executable
    Set-Location $SDS_root_dir

    # Run HCS standalone
    Write-Host "Running HCS...";
    Start-HCS

    # Return to previous directory
    Set-Location $PSScriptRoot

    # Run Python script
    & $PythonExec $Python_CollateralDownloadTest $AppData_HCS_dir $HCS_TCP_endpoint
}

# Function to run the test for Strata Control View, it will return True if the test was successful
function Test-StrataControlView {
    # Convert the path if using Unix env
    If ($Env:OS -Ne "Windows_NT" -And (($Python_ControlViewTest = Convert-Path $Python_ControlViewTest) -Eq $false)) {
        If (($Python_ControlViewTest = Convert-Path $Python_ControlViewTest) -Eq $false ) {
            Return $false
        }
    }

    write-host "Script Found" -ForegroundColor Green

    write-host "Starting Strata Developer Studio..."
    ($strataDev = Start-Process $StrataPath -PassThru) | Out-Null     # Hide output.

    write-host "Starting python test script..."
    Write-Host "================================================================================"
    $pythonScript = Start-Process $PythonExec $PythonScriptPath -NoNewWindow -PassThru -wait
    Write-Host "================================================================================"

    Write-Host "Python test script is done."

    Write-Host "Checking if Strata Developer Studio is still running."
    if ($strataDev.HasExited -eq $false) {
        Write-Host "Strata Developer Studio is running. Killing Strata Developer Studio..."
        stop-process $strataDev.id
    }
    else {
        # Strta is not running. it could bea crash!
        Write-Host "Strata developer Studio is not running. It might crashed during the test. Aborting..." -ForegroundColor Yellow
        return $false
    }


    if ($pythonScript.ExitCode -eq 0) {
        # Test Successful
        Write-Host "Test Successful." -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Test failed." -ForegroundColor Red
        Write-Host "Exit Code =" $pythonScript.ExitCode -ForegroundColor Red
        return $false
    }
}

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

# Run first Python script (HCS collateral download testing)
Test-CollateralDownload

# Run second Python script (SDS control view testing)
If ((Test-StrataControlView) -Eq $false) {
    Exit-TestScript -ScriptExitCode -1
}

Write-Host "`n`nTesting complete.`n`n"
