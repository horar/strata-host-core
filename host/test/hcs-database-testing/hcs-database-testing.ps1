<#
    Automated HCS database testing
#>

# Define path for Strata Developer Studio executable and HCS Couchbase database file
Set-Variable -Name "SDS_exec_directory" -Value "C:\Program Files\ON Semiconductor\Strata Developer Studio"
Set-Variable -Name "SDS_db_file" -Value "C:\Users\zbh8jv\AppData\Roaming\ON Semiconductor\hcs\db\strata_db\db.sqlite3"

##### Automated section

# Change directory to location of SDS executable
Set-Location $SDS_exec_directory
# Find location of 'strata_db' directory
Set-Variable -Name "SDS_strata_db_dir" -Value (Split-Path -Path $SDS_db_file)
# Find location of 'db' directory
Set-Variable -Name "SDS_db_dir" -Value (Split-Path -Path $SDS_strata_db_dir)

""; ""; "Starting tests..."; "";

# Test 1: delete directory 'db', if it exists
"TEST 1: Deleting 'DB' directory ($SDS_db_dir)..."; "";

If(Test-Path $SDS_db_dir -PathType Any) {
    "Path exists"
} Else {
    "path bad"
}

# Remove-Item -Path $SDS_db_dir -Recurse

# # Run HCS standalone
# "        Running HCS and waiting for 60 seconds..."; "";
# Start-Process -FilePath "$SDS_exec_directory\HCS\hcs.exe" -ArgumentList "-f `"C:/ProgramData/ON Semiconductor/Strata Developer Studio/HCS/hcs.config`"" -NoNewWindow -PassThru -Wait
# Start-Sleep -Seconds 60
# "        Verifying if DB folders and files were re-created in the right locations..."; "";



