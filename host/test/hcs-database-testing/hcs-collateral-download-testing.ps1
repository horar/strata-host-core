<#
    Automated collateral download testing
#>

# Search for Python in local host machine
Try {
    $python_ver = python -V
    ""; "Found $python_ver installed."
} Catch [System.Management.Automation.CommandNotFoundException] {
    ""; "Error: Python not found."
    Exit
}

#  Search for Python script
If (!(Test-Path socket.py)) {
    ""; 'Error: Python script "socket.py" not found in current directory.'; "";
    Exit
}

""; "Running Python script...";
python socket.py