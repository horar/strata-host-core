<#
.SYNOPSIS
Modular file that exports the Test-Database function to test automated database replication performed by HCS

.DESCRIPTION
This is part of the automated test script for the master test plan
https://ons-sec.atlassian.net/wiki/spaces/SPYG/pages/775848204/Master+test+plan+checklist#Database

This test consists of deleting the HCS Couchbase database from the local machine (if it exists), running HCS,
and checking whether the DB file was properly downloaded and placed in the expected directory.

PSSQLite is used to partially read in the contents of DB and count how many documents exist in the DB.

.INPUTS
None

.OUTPUTS
Numerical test result (TODO)

.NOTES
Version:        1.0
Creation Date:  03/17/2020
#>

function Test-Database {

    # Keep track of tests
    Set-Variable "TestPass"  0
    Set-Variable "TestTotal" 3

    # Change directory to location of SDS executable
    Set-Location $SDSRootDir
    # Find location of 'strata_db' directory
    Set-Variable "SDSStrataDbDir" (Split-Path -Path $HCSDbFile)
    # Find location of 'db' directory
    Set-Variable "SDSDbDir" (Split-Path -Path $SDSStrataDbDir)

    # Import "PSSQLite" PS module
    Import-Module PSSQLite

    # Stop any previously running HCS processes
    Stop-HCS
    # Stop any previously running SDS processes
    Stop-SDS

    # Define query variable for PSSQLite
    $query = "SELECT * FROM kv_default"

    # Test 1: delete directory 'db', if it exists
    Write-Host "TEST 1: Deleting 'DB' directory ($SDSDbDir)"

    If (Test-Path $SDSDbDir -PathType Any) {
        Remove-Item -Path $SDSDbDir -Recurse -Force
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

    If (Test-Path $HCSDbFile -PathType Any) {
        Write-Host "        OK (DB files found in expected location)"

        # Verify contents of DB
        Write-Host "        Verifying contents of DB";
        $query_result = Invoke-SqliteQuery -Query $query -DataSource $HCSDbFile

        If ($query_result.Length -Lt 1) {
            Write-Host "        FAIL (DB is empty)"
        } Else {
            Write-Host "        PASS (non-empty DB with $($query_result.Length) documents)"
            $TestPass++
        }
    } Else {
        Write-Host "        FAIL (DB files not found in expected location)"
    }

    # Test 2: delete directory 'strata_db', if it exists
    Write-Host "`n`nTEST 2: Deleting 'STRATA_DB' directory ($SDSStrataDbDir)"

    If (Test-Path $SDSStrataDbDir -PathType Any) {
        Remove-Item -Path $SDSStrataDbDir -Recurse -Force
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

    If (Test-Path $HCSDbFile -PathType Any) {
        Write-Host "        OK (DB files found in expected location)"

        # Verify contents of DB
        Write-Host "        Verifying contents of DB"
        $query_result = Invoke-SqliteQuery -Query $query -DataSource $HCSDbFile

        If ($query_result.Length -Lt 1) {
            Write-Host "        FAIL (DB is empty)"
        } Else {
            Write-Host "        PASS (non-empty DB with $($query_result.Length) documents)"
            $TestPass++
        }
    } Else {
        Write-Host "        FAIL (DB files not found in expected location)"
    }

    # Test 3: delete DB file, if it exists
    Write-Host "`n`nTEST 3: Deleting DB file ($HCSDbFile)"

    If (Test-Path $SDSStrataDbDir -PathType Any) {
        Remove-Item -Path $SDSStrataDbDir -Recurse
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

    If (Test-Path $HCSDbFile -PathType Any) {
        Write-Host "        OK (DB files found in expected location)"

        # Verify contents of DB
        Write-Host "        Verifying contents of DB";
        $query_result = Invoke-SqliteQuery -Query $query -DataSource $HCSDbFile

        If ($query_result.Length -Lt 1) {
            Write-Host "        FAIL (DB is empty)"
        } Else {
            Write-Host "        PASS (non-empty DB with $($query_result.Length) documents)"
            $TestPass++
        }
    } Else {
        Write-Host "        FAIL (DB files not found in expected location)"
    }

    # Return to previous directory
    Set-Location $TestRoot

    # Return number of tests passed, number of tests existing
    return $TestPass, $TestTotal
}