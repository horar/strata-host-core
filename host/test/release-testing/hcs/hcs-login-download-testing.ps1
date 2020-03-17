<#
    Automated HCS token / login / automated platform thumbnail download testing
#>

# Define tests to be executed
Set-Variable "TEST_request_token" $true

# Define paths
Set-Variable "SDS_root_dir"         "$Env:ProgramFiles\ON Semiconductor\Strata Developer Studio"
Set-Variable "AppData_OnSemi_dir"   "$Env:AppData\ON Semiconductor"
Set-Variable "PlatformSelector_dir" "$AppData_OnSemi_dir\hcs\documents\platform_selector"

# Define URI of server to be used - only applicable if TEST_request_token is enabled
Set-Variable "SDS_server"       "http://18.191.108.5" # "https://strata.onsemi.com/"
Set-Variable "SDS_login_server" "$SDS_server/login"   # "https://strata.onsemi.com/login"
Set-Variable "SDS_login_info"   '{"username":"test@test.com","password":"Strata12345"}'

#####
##### Automated section
#####

""; "Starting tests..."; "";

If ($TEST_request_token) {
    # Attempt to acquire token information from server
    "        Token/authentication server testing (using endpoint $SDS_login_server)"
    "        Attempting to acquire token information from server..."; "";
    Try {
        $server_response = Invoke-WebRequest -URI $SDS_login_server -Body $SDS_login_info -Method 'POST' -ContentType 'application/json' -ErrorAction 'Stop'
    } Catch {
        "        FAILED: Unable to obtain login token from server '$SDS_login_server' with provided account, try again."; "";
        Exit
    }

    "        HTTP $($server_response.StatusCode): $($server_response.StatusDescription)"

    If (!($server_response.Content) -Or $server_response.StatusCode -Ne 200) {
        "        FAILED: Invalid server token response, try again."; "";
        Exit
    }

    # If it exists, rename current "Strata Developer Studio.ini"
    If (Test-Path "$AppData_OnSemi_dir\Strata Developer Studio.ini" -PathType Leaf) {
        Rename-Item "$AppData_OnSemi_dir\Strata Developer Studio.ini" "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini"
    }

    # Format new token string using obtained token
    $server_response_Json = ConvertFrom-Json $server_response.Content
    $token_string = "[Login]`ntoken=$($server_response_Json.token)`nfirst_name=$($server_response_Json.firstname)`nlast_name=$($server_response_Json.lastname)`nuser=$($server_response_Json.user)`nauthentication_server=$SDS_server"

    # Write to "Strata Developer Studio.ini"
    Set-Content "$AppData_OnSemi_dir\Strata Developer Studio.ini" $token_string
    ""; "";
}

# Delete AppData/Roaming/hcs/documents/platform_selector directory if it exists
If (Test-Path $PlatformSelector_dir -PathType Any) {
    "        Deleting directory $PlatformSelector_dir"
    Remove-Item -Path $PlatformSelector_dir -Recurse -Force
    "        OK"
}

# Change directory to location of SDS executable
Set-Location $SDS_root_dir

# Run Strata Developer Studio and wait 10 s
"        Running Strata Developer Studio and waiting for 10 seconds..."
Start-Process -FilePath "$SDS_root_dir\Strata Developer Studio.exe"
Start-Sleep -Seconds 10

# Kill Strata Developer Studio and HCS processes
If (Get-Process -Name "Strata Developer Studio" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "Strata Developer Studio" -Force
}
If (Get-Process -Name "hcs" -ErrorAction SilentlyContinue) {
    Stop-Process -Name "hcs" -Force
}

# Check whether AppData/Roaming/hcs/documents/platform_selector directory was re-populated by HCS
If (Test-Path $PlatformSelector_dir -PathType Any) {
    If (@(Get-ChildItem $PlatformSelector_dir).Count -Gt 0) {
        "        PASS: directory with $(@(Get-ChildItem $PlatformSelector_dir).Count) elements."
    } Else {
        "        FAIL: empty directory created."
    }
} Else {
    "        FAIL: directory not created."
}

If ($TEST_request_token) {
    # Delete temporary .ini file and restore original
    Remove-Item -Path "$AppData_OnSemi_dir\Strata Developer Studio.ini"
    If (Test-Path "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini" -PathType Leaf) {
        Rename-Item "$AppData_OnSemi_dir\Strata Developer Studio_BACKUP.ini" "$AppData_OnSemi_dir\Strata Developer Studio.ini"
    }
}

""; "Testing complete."; ""; "";