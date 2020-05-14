<#
.SYNOPSIS
Host Controller Service

.DESCRIPTION
This test flashes a platform with given list of binaries and verify that HCS is able to identify the platform.

.INPUTS  
-PythonScriptPath   Path to Strata executable
-$PathToBinaries    Path to *.bin files
-ZmqEndpoint        The address of zmq client
.OUTPUTS

.NOTES
Version:        1.0
Creation Date:  04/28/2020
Requires: PowerShell version 5, Python 3, Jlink.exe, connected JLink device, and a connected platform
#>

# Function to search in hcs directory in AppData to look for bin files. These files are downloaded by Test-CollateralDownload,
# as a result if this test fail, this test might fail too.
function Copy-AllBinariesFromAppData {
    Param (
        [Parameter(Mandatory = $true)][string]$DestinationDirectory
    )
    # Check if there are binaries in $HCSAppDataDir
    Write-Host "Looking for .bin files in $HCSAppDataDir\documents\views\..."
    $BinaryFileList = Get-ChildItem -Path "$HCSAppDataDir\documents\views\" -Recurse -Filter *.bin
    write-Indented "$($BinaryFileList.Count) .bin files were found."

    $BinaryFilesDir = "$TestRoot\PlatformIdentification\BinaryFiles"
    If ($($BinaryFileList.Count) -ne 0) {
        write-Indented "Copying the .bin files to $DestinationDirectory"
        
        # Create a new directory, Don't fail if it does exist.
        New-Item -Path $DestinationDirectory -ItemType "directory" -Force
        
        # Copy the .bin files to the destination.
        foreach( $filename in $BinaryFileList) {
            write-Indented "Copying $($filename.FullName)"
            Copy-Item -Path $filename.FullName -Destination "$DestinationDirectory\$($filename.name)" -Recurse
        }
        return $true
    }
    Else {
        write-Indented "ERROR: No Binary files were found in $HCSAppDataDir\documents\views\. Aborting..."
        return $false
    }
}

# function to flash a binary file to the platform using JLinkExe
function Flash-JLinkFunction {
    Param (
        [Parameter(Mandatory = $true)]$PathToBinaryFile
    )

    # The script file content to flash the given .bin file to the platform
    $JLinkScriptContent = "device EFM32GG380F1024
                            if SWD
                            speed 4000
                            erase
                            loadbin $PathToBinaryFile, 0
                            r
                            q"

    # Create a temporary file to store the JLink scrip to flash the given binary
    $JLinkScriptTempFile = New-TemporaryFile

    # Add the script to the temporary file 
    Set-Content $JLinkScriptTempFile $JLinkScriptContent

    # run JLinkExe 
    Write-Host "Flashing $PathToBinaryFile..."
    $JLinkProcess = Start-Process -FilePath $JLinkExePath -ArgumentList "-ExitOnError -CommanderScript $($JLinkScriptTempFile.FullName)" -NoNewWindow -PassThru -Wait 

    # Check the exit code of JLinkExe
    If($JLinkProcess.ExitCode -ne 0) {
        write-Indented "ERROR: JLinkExe failed during platform flashing."
        return $false
    }
    Else {
        write-Indented "PASS: The platform was flashed successfully."
        return $true
    }
}

function Test-PlatformIdentification {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$PythonScriptPath,    # Path to Strata executable
        [Parameter][string]$PathToBinaries,                         # Path to *.bin files
        [Parameter(Mandatory = $true)][string]$ZmqEndpoint          # The address of zmq client
    )

    # List to store the names of the failed tests.
    $FailedTestsList = New-Object System.Collections.ArrayList

    # Check if JLink is installed, using the default path for Windows
    Write-Host "Checking if JLink.exe exist..."
    IF( $(Test-Path $JLinkExePath) -eq $false) {
        write-Indented "ERROR: JLink.exe is missing. Aborting..."
        return -1, -1
    }

    # Look for a connected JLink device. Only works with windows
    Write-Host "Checking if a JLink device is connected..."
    If (Get-PnpDevice -Status OK -Class USB -FriendlyName "J-Link driver") {
        write-Indented "JLink Device was found."
    }
    Else {
        write-Indented "ERROR: No JLink Device is connected. Aborting..."
        return -1, -1
    }

    # Look for a connected platform. Only works with windows
    Write-Host "Checking if a platform is connected..."
    If (Get-PnpDevice -Status OK -Class Ports -InstanceId "FTDIBUS*") {
        write-Indented "Platform Connected."
    }
    Else {
        write-Indented "ERROR: No Platform is connected. Aborting..."
        return -1, -1
    }

    # Check if Binaries path was passed as an argument, if not create a new directory and copy the bins to it.
    If($PathToBinaries) {
        $BinariesPath = $PathToBinaries
    }
    Else {
        $DefaultBinDirectory = "$TestRoot\PlatformIdentification\BinaryFiles"
        Write-Host "Binary files location was not supplied, the binary files will be copied to $DefaultBinDirectory"
        If ( $(Copy-AllBinariesFromAppData -DestinationDirectory $DefaultBinDirectory) -eq $true ) {
            $BinariesPath = $DefaultBinDirectory
        }
        Else {
            write-Indented "ERROR: Failed to get the binary files. Aborting..."
            return -1, -1
        }
    }

    # get the list of binaries
    Write-Host "Looking for .bin files in $BinariesPath"
    $BinaryFileList = Get-ChildItem -Path $BinariesPath -name *.bin
    
    # Check if .bin files were found in the given path
    if($($BinaryFileList.count) -gt 0) {
        #print how many files we found and their names.
        write-Indented "$($BinaryFileList.Count) .bin files were found."
        write-Indented "Binary File List:"
        ForEach ($BinaryFileName in $BinaryFileList) {
            write-Indented $BinaryFileName
        }
    }
    Else {
        write-Indented "ERROR: No .bin files were found in $BinariesPath. Aborting..."
        return -1, -1
    }

    # Stop All hcs, This is needed before starting the test to make sure that there is only one hcs instance running 
    Stop-HCS

    # Loop through the binary files. (i.e. the test cases)
    Foreach ($BinaryFile in $BinaryFileList) {
        Write-Separator
        Write-Host "Testing the file $BinaryFile..."

        # Flash the platform
        If($(Flash-JLinkFunction("$BinariesPath\$BinaryFile")) -eq $false) {
            write-Indented "ERROR: JLinkExe failed. Aborting the test."
            return -1, -1
        }

        # HCS need to be restarted with each iteration to reconnect to the platform.
        Write-Host "`nStarting HCS...`n"
        Start-HCS
        
        # Start the python script
        Write-Host "Starting the python Script..."
        $PythonScript =  Start-Process $PythonExec -ArgumentList "$PythonScriptPath $ZmqEndpoint" -NoNewWindow -PassThru -Wait
        
        # check the exit status of the python Script.
        If ($PythonScript.ExitCode -eq 0) {
            # Test Successful
            write-Indented "PASS: Test successful."
        } Else {
            $FailedTestsList += $BinaryFile     # Add the name of the binary to a list to be printed in the test summary.
            write-Indented "ERROR: Test Failed."
        }

        # Kill all hcs..
        Write-Host "`nStopping HCS...`n"
        Stop-HCS
    }

    # Print test Summary
    Write-Separator
    Write-Host "$($BinaryFileList.Count - $FailedTestsList.Count) tests passed out of $($BinaryFileList.Count)"
    
    If ($FailedTestsList.Count -ne 0) {         # If there are any failed test, list them.
        Write-Host "List of failed tests:"
        Foreach ($TestName in $FailedTestsList) {
            write-Indented "$TestName"
        }
    }

    Write-Separator
    # return the summary to be printed with the other tests
    return $($BinaryFileList.Count - $FailedTestsList.Count), $BinaryFileList.Count
}
