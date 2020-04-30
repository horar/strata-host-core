<#
.SYNOPSIS

.DESCRIPTION

.INPUTS  

.OUTPUTS

.NOTES
Version:        1.0
Creation Date:  04/28/2020
Requires: PowerShell version 5, and Python 3

.Example

#>

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

    # TODO: remove the hardcoded path for JLinkExe
    # run JLinkExe 
    Write-Host "Flashing $PathToBinaryFile..."
    $JLinkProcess = Start-Process -FilePath 'C:\Program Files (x86)\SEGGER\JLink\JLink.exe' -ArgumentList "-ExitOnError -CommanderScript $($JLinkScriptTempFile.FullName)" -NoNewWindow -PassThru -Wait 

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

function Test-PlatformIdentifciation {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$PathToPythonScript,
        [Parameter(Mandatory = $true)][string]$PathToBinaries
    )
    
    # List to store the names of the failed tests.
    $FailedTestsList = New-Object System.Collections.ArrayList

    # Look for a connected JLink device. Only works with windows
    If (Get-PnpDevice -Status OK -Class USB -FriendlyName "J-Link driver") {
        Write-Host "JLink Device was found."
    }
    Else {
        Write-Host "No JLink Device is connected. Aborting..."
        return $false
    }

    # Look for a connected platform. Only works with windows
    If (Get-PnpDevice -Status OK -Class Ports -InstanceId "FTDIBUS*") {
        Write-Host "Platform Connected."
    }
    Else {
        Write-Host "No Platform is connected. Aborting..."
        return $false
    }

    # get the list of binaries
    $BinaryFileList = Get-ChildItem -Path $PathToBinaries -name *.bin
    
    #print how many files we found and their names.
    Write-Host "We found $($BinaryFileList.Count) Files."
    Write-Host "Binary File List:"
    Write-Host $BinaryFileList

    # Loop through the files
    foreach ($BinaryFile in $BinaryFileList) {
        Write-Separator
        Write-Host "Testing the file $BinaryFile..."

        # Flash the thing
        If($(Flash-JLinkFunction("$PathToBinaries\$BinaryFile")) -eq $false) {
            Write-Host "JLinkExe failed. Aborting the test."
            return $false
        }

        # Start hcs & python script.

        Write-Host "Starting HCS..."
        Start-HCS
        # C:\Users\zbjmpd\spyglass\host\debug5128\bin\hcs.exe -f C:\Users\zbjmpd\spyglass\host\apps\hcs3\files\conf\hcs.config
        
        # Start the python script
        Write-Host "Startting the python Script" # Maybe print the file name? Check what we have in other tests.
        $pythonScript =  Start-Process $PythonExec -ArgumentList "$PythonScriptPath $ZmqEndpoint" -NoNewWindow -PassThru -Wait
        
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
    
    if ($FailedTestsList.Count -ne 0) {         # If there are any failed test, list them.
        Write-Host "List of failed tests:"
        foreach ($TestName in $FailedTestsList) {
            Write-Host "`t$TestName"
        }
    }

    Write-Separator
    # return the summary to be printed with the other tests
    return {$FailedTestsList.Count, $BinaryFileList.Count}
}
