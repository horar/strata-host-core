<#
.SYNOPSIS
Modular file that exports the Test-Database function to test automated database replication performed by HCS

.DESCRIPTION
Modular file that exports the Test-Database function to test automated database replication performed by HCS
This is part of the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist#Installer

.INPUTS
-PythonScriptPath   <Path to Strata executable>
-StrataPath         <Path to control-view-test.py>

.OUTPUTS
Bolean result of the test

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

# Function to run the test, it will return True if the test was successful
# Usage: Test-SDSControlViews -PythonScriptPath <Path to Strata executable> -StrataPath <Path to control-view-test.py>
function Test-Database {
    # Change directory to location of SDS executable
    Set-Location $SDS_root_dir
    # Find location of 'strata_db' directory
    Set-Variable "SDS_strata_db_dir" (Split-Path -Path $HCS_db_file)
    # Find location of 'db' directory
    Set-Variable "SDS_db_dir" (Split-Path -Path $SDS_strata_db_dir)

    # Import "PSSQLite" PS module
    Import-Module PSSQLite

    # Stop any previously running HCS processes
    Stop-HCS

    # Define query variable for PSSQLite
    $query = "SELECT * FROM kv_default"

    # Test 1: delete directory 'db', if it exists
    Write-Host "TEST 1: Deleting 'DB' directory ($SDS_db_dir)"

    If (Test-Path $SDS_db_dir -PathType Any) {
        Remove-Item -Path $SDS_db_dir -Recurse -Force
        Write-Host "        OK"
    } Else {
        Write-Host "        OK (directory did not exist)"
    }

    # Run HCS standalone and wait 5 s
    Write-Host "`n        Running HCS and waiting for 5 seconds..."
    Start-HCSAndWait 5
    Write-Host "`n        Killing HCS process"
    Stop-HCS

    # Verify if DB folders and files were re-created in the expected locations
    Write-Host "        Verifying if DB folders and files were re-created in the expected locations"

    If (Test-Path $HCS_db_file -PathType Any) {
        Write-Host "        PASS (DB files found in expected location)"

        # Verify contents of DB
        Write-Host "        Verifying contents of DB";
        $query_result = Invoke-SqliteQuery -Query $query -DataSource $HCS_db_file

        If ($query_result.Length -Lt 1) {
            Write-Host "        FAIL (DB is empty)"
        } Else {
            Write-Host "        PASS (non-empty DB with $($query_result.Length) documents)"
        }
    } Else {
        Write-Host "        FAIL (DB files not found in expected location)"
    }

    # Test 2: delete directory 'strata_db', if it exists
    Write-Host "`n`nTEST 2: Deleting 'STRATA_DB' directory ($SDS_strata_db_dir)"

    If (Test-Path $SDS_strata_db_dir -PathType Any) {
        Remove-Item -Path $SDS_strata_db_dir -Recurse -Force
        Write-Host "        OK"
    } Else {
        Write-Host "        OK (directory did not exist)"
    }

    # Run HCS standalone and wait 5 s
    Write-Host "`n        Running HCS and waiting for 5 seconds..."
    Start-HCSAndWait 5
    Write-Host "`n        Killing HCS process"
    Stop-HCS

    # Verify if DB folders and files were re-created in the expected locations
    Write-Host "        Verifying if DB folders and files were re-created in the expected locations"

    If (Test-Path $HCS_db_file -PathType Any) {
        Write-Host "        PASS (DB files found in expected location)"

        # Verify contents of DB
        Write-Host "        Verifying contents of DB"
        $query_result = Invoke-SqliteQuery -Query $query -DataSource $HCS_db_file

        If ($query_result.Length -Lt 1) {
            Write-Host "        FAIL (DB is empty)"
        } Else {
            Write-Host "        PASS (non-empty DB with $($query_result.Length) documents)"
        }
    } Else {
        Write-Host "        FAIL (DB files not found in expected location)"
    }

    # Test 3: delete DB file, if it exists
    Write-Host "`n`nTEST 3: Deleting DB file ($HCS_db_file)"

    If (Test-Path $SDS_strata_db_dir -PathType Any) {
        Remove-Item -Path $SDS_strata_db_dir -Recurse
        Write-Host "        OK"
    } Else {
        Write-Host "        OK (file did not exist)"
    }

    # Run HCS standalone and wait 5 s
    Write-Host "`n        Running HCS and waiting for 5 seconds..."
    Start-HCSAndWait 5
    Write-Host "`n        Killing HCS process"
    Stop-HCS

    # Verify if DB folders and files were re-created in the expected locations
    Write-Host "        Verifying if DB folders and files were re-created in the expected locations";

    If (Test-Path $HCS_db_file -PathType Any) {
        Write-Host "        PASS (DB files found in expected location)"

        # Verify contents of DB
        Write-Host "        Verifying contents of DB";
        $query_result = Invoke-SqliteQuery -Query $query -DataSource $HCS_db_file

        If ($query_result.Length -Lt 1) {
            Write-Host "        FAIL (DB is empty)"
        } Else {
            Write-Host "        PASS (non-empty DB with $($query_result.Length) documents)"
        }
    } Else {
        Write-Host "        FAIL (DB files not found in expected location)"
    }

    # Return to previous directory
    Set-Location $Test_Root
}