<#
    Automated HCS token / login / automated download testing
#>

# Define paths
Set-Variable "SDS_root_dir"    "$Env:ProgramFiles\ON Semiconductor\Strata Developer Studio"
Set-Variable "AppData_OnSemi"  "$Env:AppData\ON Semiconductor"

# Define URI of server to be used
Set-Variable "SDS_login_server" "http://18.191.165.117/login" # "https://strata.onsemi.com/login"
Set-Variable "SDS_login_info"   '{"username":"test@test.com","password":"Strata12345"}'

#####
##### Automated section
#####

""; "Starting tests..."; "";

# Attempt to acquire token information from server
"Attempting to acquire token information from server..."; "";
Try {
    $server_response = Invoke-WebRequest -URI $SDS_login_server -Body $SDS_login_info -Method 'POST' -ContentType 'application/json' -ErrorAction 'Stop'
} Catch {
    "FAILED: Unable to connect to server '$SDS_login_server' to obtain login token, try again."; "";
    Exit
}

"HTTP $($server_response.StatusCode): $($server_response.StatusDescription)"

If (!($server_response.Content) -Or $server_response.StatusCode -Ne 200) {
    "FAILED: Invalid server token response, try again."; "";
    Exit
}

# If it exists, rename current "Strata Developer Studio.ini"
If (Test-Path "$AppData_OnSemi\Strata Developer Studio.ini" -PathType Leaf) {
    Rename-Item "$AppData_OnSemi\Strata Developer Studio.ini" "$AppData_OnSemi\Strata Developer Studio_BACKUP.ini"
}

# Format new token string using obtained token
$server_response_Json = ConvertFrom-Json $server_response.Content

$token_string = @"
[Login]
token=$($server_response_Json.token)
first_name=$($server_response_Json.firstname)
last_name=$($server_response_Json.lastname)
user=$($server_response_Json.user)
"@

# Write to "Strata Developer Studio.ini"
Set-Content "$AppData_OnSemi\Strata Developer Studio.ini" $token_string

# Run Strata Developer Studio
"Running Strata Developer Studio"
# Start-Process -FilePath "$SDS_root_dir\Strata Developer Studio.exe"

# Delete temporary .ini file and restore original
# Remove-Item -Path "$AppData_OnSemi\Strata Developer Studio.ini"
# If (Test-Path "$AppData_OnSemi\Strata Developer Studio_BACKUP.ini" -PathType Leaf) {
#     Remove-Item -Path "$AppData_OnSemi\Strata Developer Studio_BACKUP.ini"
# }