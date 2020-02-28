<#
    Automated HCS token / login / automated download testing
#>

# Define URI of server to be used
Set-Variable -Name "SDS_login_server" -Value "https://strata.onsemi.com/login"
Set-Variable -Name "SDS_login_info" -Value '{"username":"zbh8jv@onsemi.com","password":"Strata12345"}'

#####
##### Automated section
#####

# Attempt to acquire token information from server
Try {
    $server_response = Invoke-WebRequest -URI $SDS_login_server -Body $SDS_login_info -Method 'POST' -ContentType 'application/json' -ErrorAction 'Stop'
} Catch {
    "ERROR: Unable to connect to server '$SDS_login_server' to obtain login token, try again."; "";
    Exit
}

If ()


" CONTENTS: "

$server_response