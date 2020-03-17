<#
    Automated collateral download testing
#>

# Define HCS TCP endpoint to be used
Set-Variable "HCS_TCP_endpoint" "tcp://127.0.0.1:5563"

# Define paths
Set-Variable "SDS_root_dir"    "$Env:ProgramFiles\ON Semiconductor\Strata Developer Studio"
Set-Variable "AppData_HCS_dir" "$Env:AppData\ON Semiconductor\hcs"
Set-Variable "HCS_config_file" "$Env:ProgramData\ON Semiconductor\Strata Developer Studio\HCS\hcs.config"
Set-Variable "HCS_exec_file"   "$SDS_root_dir\HCS\hcs.exe"

#####
##### Automated section
#####

# Function definition "StartHCSAndWait"
# Start one instance of HCS and wait (to give time for DB replication)
function StartHCS {
    Start-Process -FilePath $HCS_exec_file -ArgumentList "-f `"$HCS_config_file`""
    Start-Sleep -Seconds 1
}

# Search for Python in local host machine
Try {
    $python_ver = python -V
    If ($null -Eq $python_ver) {
        ""; "Error: Python not found."; "";
        Exit
    }
    ""; "Found $python_ver installed."
} Catch [System.Management.Automation.CommandNotFoundException] {
    ""; "Error: Python not found."; "";
    Exit
}

# Search for Python script
If (!(Test-Path hcs-collateral-download-test.py)) {
    ""; 'Error: Python script "hcs-collateral-download-test.py" not found in current directory.'; "";
    Exit
}

# Search for "hcs" directory
If (!(Test-Path $AppData_HCS_dir -PathType Any)) {
    ""; "Error: Directory $AppData_HCS_dir not found."; "";
    Exit
}

# Change directory to location of SDS executable
Set-Location $SDS_root_dir

# Run HCS standalone
""; "Running HCS...";
StartHCS

# Run Python script
Set-Location $PSScriptRoot
""; "Running Python script...";
python hcs-collateral-download-test.py $AppData_HCS_dir $HCS_TCP_endpoint

""; "Testing complete."; ""; "";