# Function to run the test for Strata Control View, it will return True if the test was successful
function Test-StrataControlView {
    # Convert the path if using Unix env
    If ($Env:OS -Ne "Windows_NT" -And (($Python_ControlViewTest = Convert-Path $Python_ControlViewTest) -Eq $false)) {
        If (($Python_ControlViewTest = Convert-Path $Python_ControlViewTest) -Eq $false ) {
            Return $false
        }
    }
    write-host "Starting Strata Developer Studio..."
    ($strataDev = Start-Process $SDS_exec_file -PassThru) | Out-Null     # Hide output.

    write-host "Starting python test script..."
    Write-Host "================================================================================"
    $pythonScript = Start-Process $PythonExec $Python_ControlViewTest -NoNewWindow -PassThru -wait
    Write-Host "================================================================================"

    Write-Host "Python test script is done."

    Write-Host "Checking if Strata Developer Studio is still running."
    if ($strataDev.HasExited -eq $false) {
        Write-Host "Strata Developer Studio is running. Killing Strata Developer Studio..."
        stop-process $strataDev.id
    }
    else {
        # Strta is not running. it could bea crash!
        Write-Host "Strata developer Studio is not running. It might crashed during the test. Aborting..." -ForegroundColor Yellow
        return $false
    }


    if ($pythonScript.ExitCode -eq 0) {
        # Test Successful
        Write-Host "Test Successful." -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Test failed." -ForegroundColor Red
        Write-Host "Exit Code =" $pythonScript.ExitCode -ForegroundColor Red
        return $false
    }
}