<#
    Automated HCS database testing
#>

# Define path for Strata Developer Studio executable and HCS Couchbase database file
Set-Variable -Name "SDS_exec_directory" -Value "C:\Program Files\ON Semiconductor\Strata Developer Studio"
Set-Variable -Name "SDS_db_file" -Value "C:\Users\zbh8jv\AppData\Roaming\ON Semiconductor\hcs\db\strata_db\db.sqlite3"

#####
##### Automated section
#####

# Function definition
function KillAllHCS {
    # Stop all running HCS processes
    If (Get-Process -Name "hcs" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "hcs" -Force
        Start-Sleep -Seconds 2
    }
}

# Change directory to location of SDS executable
Set-Location $SDS_exec_directory
# Find location of 'strata_db' directory
Set-Variable -Name "SDS_strata_db_dir" -Value (Split-Path -Path $SDS_db_file)
# Find location of 'db' directory
Set-Variable -Name "SDS_db_dir" -Value (Split-Path -Path $SDS_strata_db_dir)
# Check that 'db' directory is found where expected
If (!(Test-Path $SDS_db_dir -PathType Any)) {
    ""; "ERROR: Cannot find DB directory at $SDS_db_dir"
    "Exiting test script"; "";
    exit
}
# Stop any running HCS processes
KillAllHCS

""; "Starting tests..."; "";

# Test 1: delete directory 'db', if it exists
"TEST 1: Deleting 'DB' directory ($SDS_db_dir)";

If (Test-Path $SDS_db_dir -PathType Any) {
    Remove-Item -Path $SDS_db_dir -Recurse -Force
    "        OK"
} Else {
    "        OK (directory did not exist)"
}

# Run HCS standalone and wait 20 s
""; "        Running HCS and waiting for 20 seconds...";
Start-Process -FilePath "$SDS_exec_directory\HCS\hcs.exe" -ArgumentList "-f `"C:/ProgramData/ON Semiconductor/Strata Developer Studio/HCS/hcs.config`"" -NoNewWindow -PassThru
Start-Sleep -Seconds 20
""; "        Killing HCS process"
KillAllHCS

# Verify if DB folders and files were re-created in the right locations
"        Verifying if DB folders and files were re-created in the right locations";

If (Test-Path $SDS_db_file -PathType Any) {
    "        PASS (DB files found in expected location)"
} Else {
    "        FAIL (DB files not found in expected location)"
}

# Test 2: delete directory 'strata_db', if it exists
""; ""; "TEST 2: Deleting 'STRATA_DB' directory ($SDS_strata_db_dir)";

If (Test-Path $SDS_strata_db_dir -PathType Any) {
    Remove-Item -Path $SDS_strata_db_dir -Recurse -Force
    "        OK"
} Else {
    "        OK (directory did not exist)"
}

# Run HCS standalone and wait 20 s
""; "        Running HCS and waiting for 20 seconds...";
Start-Process -FilePath "$SDS_exec_directory\HCS\hcs.exe" -ArgumentList "-f `"C:/ProgramData/ON Semiconductor/Strata Developer Studio/HCS/hcs.config`"" -NoNewWindow -PassThru
Start-Sleep -Seconds 20
""; "        Killing HCS process"
KillAllHCS

# Verify if DB folders and files were re-created in the right locations
"        Verifying if DB folders and files were re-created in the right locations"; "";

If (Test-Path $SDS_db_file -PathType Any) {
    "        PASS (DB files found in expected location)"
} Else {
    "        FAIL (DB files not found in expected location)"
}

# Test 3: delete DB file, if it exists
""; ""; "TEST 3: Deleting DB file ($SDS_db_file)";

If (Test-Path $SDS_strata_db_dir -PathType Any) {
    Remove-Item -Path $SDS_strata_db_dir -Recurse
    "        OK"
} Else {
    "        OK (file did not exist)"
}

# Run HCS standalone and wait 20 s
""; "        Running HCS and waiting for 20 seconds...";
Start-Process -FilePath "$SDS_exec_directory\HCS\hcs.exe" -ArgumentList "-f `"C:/ProgramData/ON Semiconductor/Strata Developer Studio/HCS/hcs.config`"" -NoNewWindow -PassThru
Start-Sleep -Seconds 20
""; "        Killing HCS process"
KillAllHCS

# Verify if DB folders and files were re-created in the right locations
"        Verifying if DB folders and files were re-created in the right locations"; "";

If (Test-Path $SDS_db_file -PathType Any) {
    "        PASS (DB files found in expected location)"
} Else {
    "        FAIL (DB files not found in expected location)"
}

""; "Testing complete."; ""; "";