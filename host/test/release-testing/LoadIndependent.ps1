Write-Host $PSScriptRoot
Set-Variable "PythonExec" "python"
# Define HCS TCP endpoint to be used
Set-Variable "HCSTCPEndpoint" "tcp://127.0.0.1:5563"

# Define paths
Set-Variable "SDSRootDir"    "C:\Users\SEC\Dev2\spyglass\host\Debug\bin"
Set-Variable "HCSAppDataDir" "$Env:AppData\ON Semiconductor\hcs"
Set-Variable "HCSConfigFile" "$Env:ProgramData\ON Semiconductor\Strata Developer Studio\HCS\hcs.config"
Set-Variable "HCSExecFile"   "$SDSRootDir\hcs.exe"
Set-Variable "SDSExecFile"   "$SDSRootDir\Strata Developer Studio.exe"
Set-Variable "HCSDbFile"     "$HCSAppDataDir\db\strata_db\db.sqlite3"
Set-Variable "TestRoot"      $PSScriptRoot
Set-Variable "JLinkExePath"  "${Env:ProgramFiles(x86)}\SEGGER\JLink\JLink.exe"

# Define variables for server authentication credentials needed to acquire login token
Set-Variable "SDSServer"      "http://18.191.108.5/"      # "https://strata.onsemi.com"
Set-Variable "SDSLoginServer" "http://18.191.108.5/login" # "https://strata.onsemi.com/login"
Set-Variable "SDSLoginInfo"   '{"username":"test@test.com","password":"Strata12345"}'

Set-Variable "PythonRoot" "C:/Users/SEC/Dev2/spyglass/host/test/release-testing/gui-testing"
# Define paths for Python scripts ran by this script
Set-Variable "PythonGUIMain"                    "$PythonRoot/main.py"
Set-Variable "PythonGUIMainLoginTestPre"        "$PythonRoot/main_login_test_pre.py"
Set-Variable "PythonGUIMainLoginTestPost"       "$PythonRoot/main_login_test_post.py"
Set-Variable "PythonGUIMainNoNetwork"           "$PythonRoot/main_no_network.py"

# Import common functions
. "$PSScriptRoot\Common-Functions.ps1"

# Import functions for test "Test-Database"
. "$PSScriptRoot\hcs\Test-Database.ps1"

# Import functions for test "Test-TokenAndViewsDownload"
. "$PSScriptRoot\hcs\Test-TokenAndViewsDownload.ps1"

# Import functions for test "Test-CollateralDownload"
. "$PSScriptRoot\hcs\Test-CollateralDownload.ps1"

# Import functions for test "Test-SDSControlViews"
. "$PSScriptRoot\strataDev\Test-SDSControlViews.ps1"

# Import functions for test "Test-SDSInstaller"
. "$PSScriptRoot\installer\Test-SDSInstaller.ps1"

# Import functions for test "Test-PlatformIdentification"
. "$PSScriptRoot\PlatformIdentification\Test-PlatformIdentification.ps1"

