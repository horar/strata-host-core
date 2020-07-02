function Start-SDSAndWait {
    Param (
        [Parameter(Mandatory = $false)][int]$seconds
    )
    # Set-Location $SDSRootDir isneeded to resolve the ddl issue when running
    # HCS seperetly so that Windows will look into this directory for dlls
    Set-Location "C:\Program Files\ON Semiconductor\Strata Developer Studio"
    Start-Process -FilePath "Strata Developer Studio" -WindowStyle Maximized
    if ($seconds) {
        Start-Sleep -Seconds 5
    }
    Set-Location "C:\Users\SEC\Dev2\spyglass\host\test\release-testing"
}
function Test-Gui() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$PythonScriptPath,    # Path to control-view-test.py
        [Parameter(Mandatory = $true)][string]$StrataPath           # Path to Strata executable
    )
    Start-SDSAndWait -seconds 5
    $pythonScript = Start-Process "python" -ArgumentList "C:\Users\SEC\Dev2\spyglass\host\test\release-testing\gui-testing\main.py" -NoNewWindow -PassThru -Wait

}
Test-Gui -PythonScriptPath="main.py" -StrataPath="C:\Program Files\ON Semiconductor\Strata Developer Studio"