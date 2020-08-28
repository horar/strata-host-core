<#
.SYNOPSIS
Opens and tests Strata's GUI. Do not touch the mouse or keyboard while this test runs and make sure no application will open in front of Strata while the test is running.
.DESCRIPTION
This is part of the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist

This tests consists of:
* Logging in with a board connected
* Logging in with a board disconnected
* Sending user feedback
* Attempting to log in with invalid user information
* Attempting to create a new user with existing information
* Attempting to create a new user with new information
* Attempting to login/create a new user when the network is disconnected
* Attempting to reset the user's password, with invalid and valid usernames.
* Logging in, closing Strata, and reopening it.

.INPUTS
StrataPath: The path to the Strata executable.
.OUTPUTS

.NOTES
Version:        1.0
Creation Date:  07/10/2020
#>
function Test-Gui() {
    $SDSLoginInfoObj = $SDSLoginInfo | ConvertFrom-Json

    $Username = $SDSLoginInfoObj.username
    $Password = $SDSLoginInfoObj.password

    Write-Host "Starting GUI testing"

    Write-Host "Running basic tests..."

    #run basic tests
    Start-SDSAndWait

    Start-Process $PythonExec -ArgumentList $PythonGUIMain, $Username, $Password, $HCSTCPEndpoint -NoNewWindow -Wait

    Stop-Process -Name "Strata Developer Studio" -Force
    Stop-Process -Name "hcs" -Force

    Write-Host "Disabling network for Strata..."

    #Run tests without network
    #BLock Strata from making outbound requests
   (New-NetFirewallRule -DisplayName "TEMP_Disable_SDS_Network" -Direction Outbound -Program $SDSExecFile -Action Block) | Out-Null

    Start-SDSAndWait

    Write-Host "Testing Strata with no network connection..."
    Start-Process $PythonExec -ArgumentList $PythonGUIMainNoNetwork, $Username, $Password, $HCSTCPEndpoint -NoNewWindow -Wait

    Stop-Process -Name "Strata Developer Studio" -Force
    Stop-Process -Name "hcs" -Force

    Write-Host "Enabling network for Strata..."
    Remove-NetFirewallRule -DisplayName "TEMP_Disable_SDS_Network"


#    This test fails currently. Logginging in and restarting strata fails even when manually attempted.
#    Test logging in, closing strata, and reopening it
#    Login to strata
    Write-Host "Testing logging in, closing Strata, reopening Strata..."

    Start-SDSAndWait
    Start-Process $PythonExec -ArgumentList $PythonGUIMainLoginTestPre, $Username, $Password, $HCSTCPEndpoint -NoNewWindow -Wait

    Stop-Process -Name "Strata Developer Studio" -Force
    Stop-Process -Name "hcs" -Force

    #Test for Strata automatically going to the platform view
    Start-SDSAndWait

    Start-Process $PythonExec -ArgumentList $PythonGUIMainLoginTestPost, $Username, $Password, $HCSTCPEndpoint -NoNewWindow -Wait

    Stop-Process -Name "Strata Developer Studio" -Force
    Stop-Process -Name "hcs" -Force

    $result = (Get-Content "$TestRoot\gui-testing\results.txt") -split ','
    return $result

}
