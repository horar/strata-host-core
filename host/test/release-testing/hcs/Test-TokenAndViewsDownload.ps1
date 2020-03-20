<#
.SYNOPSIS
Modular file that exports the Test-TokenAndViewsDownload function to test
automated HCS token / login / automated platform thumbnail download

.DESCRIPTION
This is part of the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist

.INPUTS
-PythonScriptPath   <Path to Strata executable>
-StrataPath         <Path to control-view-test.py>

.OUTPUTS
Bolean result of the test

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

function Test-TokenAndViewsDownload {
    # Define some derived paths used in this script
    Set-Variable "AppData_OnSemi_dir" (Split-Path -Path $AppDataHCSDir)
    Set-Variable "PlatformSelector_dir" "$AppDataHCSDir\documents\platform_selector"

    If ($TestRequestToken) {
        # Attempt to acquire token information from server
        Write-Host "        Token/authentication server testing (using endpoint $SDSLoginServer)"
        Write-Host "        Attempting to acquire token information from server...`n"
        Try {
            $server_response = Invoke-WebRequest -URI $SDSLoginServer -Body $SDSLoginInfo -Method 'POST' -ContentType 'application/json' -ErrorAction 'Stop' -UseBasicParsing
        } Catch {
            Write-Host "        FAILED: Unable to obtain login token from server '$SDSLoginServer' with provided account, try again.`n"
            Exit
        }

        Write-Host "        HTTP $($server_response.StatusCode): $($server_response.StatusDescription)"

        If (!($server_response.Content) -Or $server_response.StatusCode -Ne 200) {
            Write-Host "        FAILED: Invalid server token response, try again.`n"
            Exit
        } Else {
            Write-Host "        Successfully acquired token information from server."
        }

        # If it exists, delete "Strata Developer Studio_BACKUP.ini"
        If (Test-Path "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini" -PathType Leaf) {
            Remove-Item -Path "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini" -Force
        }

        # If it exists, rename current "Strata Developer Studio.ini"
        If (Test-Path "$AppData_OnSemi_dir\Strata Developer Studio.ini" -PathType Leaf) {
            Rename-Item "$AppData_OnSemi_dir\Strata Developer Studio.ini" "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini"
        }

        # Format new token string using obtained token
        $server_response_Json = ConvertFrom-Json $server_response.Content
        $token_string = "[Login]`ntoken=$($server_response_Json.token)`nfirst_name=$($server_response_Json.firstname)`nlast_name=$($server_response_Json.lastname)`nuser=$($server_response_Json.user)`nauthentication_server=$SDSServer"

        # Write to "Strata Developer Studio.ini"
        Set-Content "$AppData_OnSemi_dir\Strata Developer Studio.ini" $token_string

        # Mark for clean up
        $global:NeedCleanUp = $true
    }

    # Delete AppData/Roaming/hcs/documents/platform_selector directory if it exists
    If (Test-Path $PlatformSelector_dir -PathType Any) {
        Write-Host "        Deleting directory $PlatformSelector_dir"
        Remove-Item -Path $PlatformSelector_dir -Recurse -Force
        Write-Host "        OK"
    }

    # Change directory to location of SDS executable
    Set-Location $SDSRootDir

    # Run Strata Developer Studio and wait 10 s
    Write-Host "        Running Strata Developer Studio and waiting for 10 seconds..."
    Start-Process -FilePath "$SDSRootDir\Strata Developer Studio.exe"
    Start-Sleep -Seconds 10

    # Kill Strata Developer Studio and HCS processes
    Stop-SDS
    Stop-HCS

    # Check whether AppData/Roaming/hcs/documents/platform_selector directory was re-populated by HCS
    If (Test-Path $PlatformSelector_dir -PathType Any) {
        If (@(Get-ChildItem $PlatformSelector_dir).Count -Gt 0) {
            Write-Host "        PASS: directory with $(@(Get-ChildItem $PlatformSelector_dir).Count) elements."
        } Else {
            Write-Host "        FAIL: empty directory created."
        }
    } Else {
        Write-Host "        FAIL: directory not created."
    }

    # Return to previous directory
    Set-Location $TestRoot
}