<#
.SYNOPSIS
Main Strata Developer Studio / Host Controller Service / Installer script driver

.DESCRIPTION


.INPUTS  

.OUTPUTS

.NOTES
Version:        1.0
Creation Date:  04/28/2020
Requires: PowerShell version 5, and Python 3

.Example

#>

# Import the common functions.
. ..\Common-Functions.ps1

# function to flash a binaries using JLinkExe
function Flash-JLinkFunction {
    Param (
        [Parameter(Mandatory = $true)]$PathToBinaryFile
    )

    Write-Host "Flashing $PathToBinaryFile..."

    # Build the flashing command
    $JLinkCommand = @"
device EFM32GG380F1024
if SWD
speed 4000
erase
loadbin $PathToBinaryFile, 0
r
q
"@

    # Find a way to get the exit code of JLinkExe
    $JLinkCommand | &'C:\Program Files (x86)\SEGGER\JLink\JLink.exe'
}

function Test-PlatformIdentifciation {
    [CmdletBinding()]
    param (
        # [Parameter]$PathToPythonScript,
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
        Flash-JLinkFunction("$PathToBinaries\$BinaryFile")

        # Start hcs & python script.

        Write-Host "Starting HCS..."
        #Start-HCS
        C:\Users\zbjmpd\spyglass\host\debug5128\bin\hcs.exe -f C:\Users\zbjmpd\spyglass\host\apps\hcs3\files\conf\hcs.config
        
        # Start the python script
        Write-Host "Startting the python Script" # Maybe print the file name? Check what we have in other tests.
        $pythonScript = Start-Process python -ArgumentList ".\zmq-example-dealer.py" -NoNewWindow -PassThru -Wait
        
        # check the exit status of the python Script.
        # Write-Host "Python Exit Code = $($pythonScript.ExitCode)"
        If ($PythonScript.ExitCode -eq 0) {
            # Test Successful
            Write-Host "Test passed" # print a better output! add the file name and change the color of output 
            # Return $true
        } Else {
            # TODO: Add the name of the failed test to the summary.
            $FailedTestsList += $BinaryFile

            Write-Host "Test failed." # print a better output! add the file name and change the color of output 
            Write-Host "Exit Code = $($pythonScript.ExitCode)"
            # Return $false
        }

        # Kill all hcs..
        Write-Host "Stopping HCS..."
        Stop-HCS
        Write-Separator
    }

    # Print test Summary
    Write-Separator
    Write-Host "$($BinaryFileList.Count - $FailedTestsList.Count) tests passed out of $($BinaryFileList.Count)"
    # print failed tests
    if ($FailedTestsList.Count -ne 0) {
        Write-Host "List of failed tests:"
        foreach ($TestName in $FailedTestsList) {
            Write-Host "`t$TestName"
        }
    }
    Write-Separator

    # return the summary to be printed with the other tests

}

Test-PlatformIdentifciation -PathToBinaries "C:\Users\zbjmpd\release-bin\smaller_test"
