<#
    Automated collateral download testing
#>

# Define HCS TCP endpoint to be used
Set-Variable "HCS_TCP_endpoint" "tcp://127.0.0.1:5563"

# Define path to AppData/Roaming/ON Semiconductor
Set-Variable "AppData_HCS_dir" "$Env:AppData\ON Semiconductor\hcs"

#####
##### Automated section
#####

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

""; "Running Python script...";
python hcs-collateral-download-test.py $AppData_HCS_dir $HCS_TCP_endpoint

""; "Testing complete."; ""; "";