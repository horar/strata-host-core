<#
    Automated HCS database testing
#>

# Define paths
Set-Variable "SDS_root_dir"    "$Env:ProgramFiles\ON Semiconductor\Strata Developer Studio"
Set-Variable "HCS_db_file"     "$Env:AppData\ON Semiconductor\hcs\db\strata_db\db.sqlite3"
Set-Variable "HCS_config_file" "$Env:ProgramData\ON Semiconductor\Strata Developer Studio\HCS\hcs.config"
Set-Variable "HCS_exec_file"   "$SDS_root_dir\HCS\hcs.exe"

#####
##### Automated section
#####

# Function definition "KillAllHCS"
# Kills all processes by the name of "hcs" running in the local machine
function KillAllHCS {
    If (Get-Process -Name "hcs" -ErrorAction SilentlyContinue) {
        Stop-Process -Name "hcs" -Force
        Start-Sleep -Seconds 2
    }
}

# Function definition "StartHCSAndWait"
# Start one instance of HCS and wait (to give time for DB replication)
function StartHCSAndWait {
    Start-Process -FilePath $HCS_exec_file -ArgumentList "-f `"$HCS_config_file`""
    Start-Sleep -Seconds 10
}

# Check for SDS executable
# Notify & exit if not found
If (!(Test-Path "$SDS_root_dir\Strata Developer Studio.exe" -PathType Leaf)) {
    ""; "ERROR: Cannot find Strata Developer Studio executable at `"$SDS_root_dir\Strata Developer Studio.exe`".";
    "Correct the 'SDS_root_dir' variable in the script and try again."; "";
    Exit
}

# Check for PSSQLite
# Tell user to manually install it & exit if not found
# If (!(Get-Module -Name "PSSQLite")) {
If (!(Get-Module -ListAvailable -Name PSSQLite)) {
    ""; ""; "PSSQLite Powershell module not found: cannot proceed."
    "Install module PSSQLite by running as administrator:"
    "   Install-Module PSSQLite"; ""; "";
    Exit
}

# Change directory to location of SDS executable
Set-Location $SDS_root_dir
# Find location of 'strata_db' directory
Set-Variable "SDS_strata_db_dir" (Split-Path -Path $HCS_db_file)
# Find location of 'db' directory
Set-Variable "SDS_db_dir" (Split-Path -Path $SDS_strata_db_dir)

# Import "PSSQLite" PS module
Import-Module PSSQLite

# Stop any previously running HCS processes
KillAllHCS

# Define query variable for PSSQLite
$query = "SELECT * FROM kv_default"

""; "Starting tests..."; "";

# Test 1: delete directory 'db', if it exists
"TEST 1: Deleting 'DB' directory ($SDS_db_dir)";

If (Test-Path $SDS_db_dir -PathType Any) {
    Remove-Item -Path $SDS_db_dir -Recurse -Force
    "        OK"
} Else {
    "        OK (directory did not exist)"
}

# Run HCS standalone and wait 10 s
""; "        Running HCS and waiting for 10 seconds...";
StartHCSAndWait
""; "        Killing HCS process"
KillAllHCS

# Verify if DB folders and files were re-created in the expected locations
"        Verifying if DB folders and files were re-created in the expected locations";

If (Test-Path $HCS_db_file -PathType Any) {
    "        PASS (DB files found in expected location)"

    # Verify contents of DB
    "        Verifying contents of DB";
    $query_result = Invoke-SqliteQuery -Query $query -DataSource $HCS_db_file

    If ($query_result.Length -Lt 1) {
        "        FAIL (DB is empty)"
    } Else {
        "        PASS (non-empty DB with $($query_result.Length) documents)"
    }
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

# Run HCS standalone and wait 10 s
""; "        Running HCS and waiting for 10 seconds...";
StartHCSAndWait
""; "        Killing HCS process"
KillAllHCS

# Verify if DB folders and files were re-created in the expected locations
"        Verifying if DB folders and files were re-created in the expected locations";

If (Test-Path $HCS_db_file -PathType Any) {
    "        PASS (DB files found in expected location)"

    # Verify contents of DB
    "        Verifying contents of DB";
    $query_result = Invoke-SqliteQuery -Query $query -DataSource $HCS_db_file

    If ($query_result.Length -Lt 1) {
        "        FAIL (DB is empty)"
    } Else {
        "        PASS (non-empty DB with $($query_result.Length) documents)"
    }
} Else {
    "        FAIL (DB files not found in expected location)"
}

# Test 3: delete DB file, if it exists
""; ""; "TEST 3: Deleting DB file ($HCS_db_file)";

If (Test-Path $SDS_strata_db_dir -PathType Any) {
    Remove-Item -Path $SDS_strata_db_dir -Recurse
    "        OK"
} Else {
    "        OK (file did not exist)"
}

# Run HCS standalone and wait 10 s
""; "        Running HCS and waiting for 10 seconds...";
StartHCSAndWait
""; "        Killing HCS process"
KillAllHCS

# Verify if DB folders and files were re-created in the expected locations
"        Verifying if DB folders and files were re-created in the expected locations";

If (Test-Path $HCS_db_file -PathType Any) {
    "        PASS (DB files found in expected location)"

    # Verify contents of DB
    "        Verifying contents of DB";
    $query_result = Invoke-SqliteQuery -Query $query -DataSource $HCS_db_file

    If ($query_result.Length -Lt 1) {
        "        FAIL (DB is empty)"
    } Else {
        "        PASS (non-empty DB with $($query_result.Length) documents)"
    }
} Else {
    "        FAIL (DB files not found in expected location)"
}

""; "Testing complete."; ""; "";