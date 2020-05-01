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
    $BinaryFileList = Get-ChildItem -Path "$HCSAppDataDir\documents\views\" -Recurse -Filter *.bin
    write-host "$($BinaryFileList.Count) .bin files were found."

    $BinaryFilesDir = "$TestRoot\PlatformIdentification\BinaryFiles"
    If ($($BinaryFileList.Count) -ne 0) {
        Write-Host "Copying the .bin files to $DestinationDirectory"
        
        # Create a new directory, Don't fail if it does exist.
        New-Item -Path $DestinationDirectory -ItemType "directory" -Force
        
        # Copy the .bin files to the destination.
        foreach( $filename in $BinaryFileList) {
            write-host "Copying $($filename.FullName)"
            Copy-Item -Path $filename.FullName -Destination "$DestinationDirectory\$($filename.name)" -Recurse
        }
        return $true
    }
    Else {
        Write-Host "No Binary files were found in $HCSAppDataDir\documents\views\. Aborting..."
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
        write-host "JLinkExe faild during platform flashing."
        return $false
    }
    Else {
        Write-host "The platform was flashed successfully."
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
        Write-Host "JLink.exe is missing. Aborting..."
        return -1, -1
    }

    # Look for a connected JLink device. Only works with windows
    If (Get-PnpDevice -Status OK -Class USB -FriendlyName "J-Link driver") {
        Write-Host "JLink Device was found."
    }
    Else {
        Write-Host "No JLink Device is connected. Aborting..."
        return -1, -1
    }

    # Look for a connected platform. Only works with windows
    If (Get-PnpDevice -Status OK -Class Ports -InstanceId "FTDIBUS*") {
        Write-Host "Platform Connected."
    }
    Else {
        Write-Host "No Platform is connected. Aborting..."
        return -1, -1
    }

    # Check if Binaries path was passed as an argument, if not create a new directory and copy the bins to it.
    If($PathToBinaries) {
        $BinariesPath = $PathToBinaries
    }
    Else {
        $DefualtBinDirectory = "$TestRoot\PlatformIdentification\BinaryFiles"
        Write-Host "Binary files location was not supplied, the binary files will be copied to $DefualtBinDirectory"
        If ( $(Copy-AllBinariesFromAppData -DestinationDirectory $DefualtBinDirectory) -eq $true ) {
            $BinariesPath = $DefualtBinDirectory
        }
        Else {
            Write-Host "Failed to get the binary files. Aborting..."
            return -1, -1
        }
    }

    # get the list of binaries
    Write-Host "Looking for .bin files in $BinariesPath"
    $BinaryFileList = Get-ChildItem -Path $BinariesPath -name *.bin
    
    # Check if .bin files were found in the given path
    if($($BinaryFileList.count) -gt 0) {
        #print how many files we found and their names.
        Write-Host "$($BinaryFileList.Count) .bin files were found."
        Write-Host "Binary File List:"
        Write-Host $BinaryFileList
    }
    Else {
        Write-Host "No .bin files were found in $BinariesPath. Aborting..."
        return -1, -1
    }

    # Loop through the files
    Foreach ($BinaryFile in $BinaryFileList) {
        Write-Separator
        Write-Host "Testing the file $BinaryFile..."

        # Flash the platform
        If($(Flash-JLinkFunction("$BinariesPath\$BinaryFile")) -eq $false) {
            Write-Host "JLinkExe failed. Aborting the test."
            return -1, -1
        }

        # Start hcs
        Write-Host "Starting HCS..."
        Start-HCS
        
        # Start the python script
        Write-Host "Startting the python Script"
        $PythonScript =  Start-Process $PythonExec -ArgumentList "$PythonScriptPath $ZmqEndpoint" -NoNewWindow -PassThru -Wait
        
        # check the exit status of the python Script.
        If ($PythonScript.ExitCode -eq 0) {
            # Test Successful
            Write-Host "Test passed" # print a better output! add the file name and change the color of output 
            # Return $true
        } Else {
            $FailedTestsList += $BinaryFile     # Add the name of the binary to a list to be printed in the test summary.
            Write-Host "Test failed." # print a better output! add the file name and change the color of output 
        }

        # Kill all hcs..
        Write-Host "Stopping HCS..."
        Stop-HCS
        Write-Separator
    }

    # Print test Summary
    Write-Separator
    Write-Host "$($BinaryFileList.Count - $FailedTestsList.Count) tests passed out of $($BinaryFileList.Count)"
    
    If ($FailedTestsList.Count -ne 0) {         # If there are any failed test, list them.
        Write-Host "List of failed tests:"
        Foreach ($TestName in $FailedTestsList) {
            Write-Host "`t$TestName"
        }
    }

    Write-Separator
    # return the summary to be printed with the other tests
    return $($BinaryFileList.Count - $FailedTestsList.Count), $BinaryFileList.Count
}
