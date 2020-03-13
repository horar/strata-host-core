# This test is semi automated as it requires someone to look at the UI for proper rendering

# squence of test:
#   1. Run Strata Dev Studio.
#   2. Start the python script `zmq-client.py`. 
#   3. Close every thing.

# Optional -StrataPath command line argument
[CmdletBinding()]
param (
    [string]$StrataPath = "C:\Users\zbjmpd\spyglass\host\Debug\bin\Strata Developer Studio.exe"
)

function ExitTheScript {
    param (
        [Parameter(Mandatory=$true)][int]$ScriptExitCode
    )
    if($ScriptExitCode -eq 0) {
        write-host "Test finished Successfully. Existting..." -ForegroundColor Green
    }
    else {
        write-host "Test failed. Terminating" $ScriptExitCode -ForegroundColor red
    }
    write-host "============================================================================================================================================"
    write-host "============================================================================================================================================"
    exit $ScriptExitCode
}

# function to check if python and pyzmq are installed, if both were found it will return True,
function CheckPythonExist {
    Try {
        Write-Host "Looking for python..."
        If ((Start-Process python --version -Wait -WindowStyle Hidden -PassThru).ExitCode -Eq 0) {
            Write-Host "Python found." -ForegroundColor Green
            Write-Host "Looking for pyzmq..."
            If((Start-Process python '-c "import zmq"' -WindowStyle Hidden -Wait -PassThru).ExitCode -Eq 0) {
                Write-Host "pyzmq found." -ForegroundColor Green
            }
            Else {
                Write-Host "pyzmq not found. aborting..." -ForegroundColor red
                Return $false
            }
        } 
        Else {           
            Write-Host "Python not found. aborting..." -ForegroundColor red
            Return $false
        }  
    } Catch [System.InvalidOperationException] {
        Write-Host "Python not found. aborting..." -ForegroundColor red
        Return $false
    }
    Return $true
}

# This functin is to check if Strata Develoiper studio Exist
function CheckStrataExist {
    Write-Host "Looking for Strata Developer Studio in" $StrataPath
    if(Test-Path -Path $StrataPath) {
        Write-Host "Strata Developer Studio found." -ForegroundColor Green
        Return $true
    }
    else {
        Write-Host "Strta Developer Studio not found. aborting..." -ForegroundColor red
        Return $false 
    }
}

# Function to run the test, it will return True if the test was successful 
function ExecuteTheTest {
    # check if the python script exesit.
    Write-Host "Looking for the test script in" $PSScriptRoot
    if(Test-Path -Path "$($PSScriptRoot)\zmq-router.py") {
        write-host "Script Found" -ForegroundColor Green
        
        write-host "Starting Strata Developer Studio..."
        $strataDev = Start-Process $StrataPath -PassThru
        
        write-host "Starting python test script..."
        write-host "############################################################################################################################################"
        $pythonScript = Start-Process python "$($PSScriptRoot)\zmq-router.py" -NoNewWindow -PassThru -wait
        write-host "############################################################################################################################################"
        
        Write-Host "Test is done."
        Write-Host "Killing Strata Developer Studio..."
        stop-process $strataDev.id

        if($pythonScript.ExitCode -eq 0) { # Test Successful
            Write-Host "Test Successful." -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Test failed." -ForegroundColor red
            Write-Host "Exit Code =" $pythonScript.ExitCode -ForegroundColor red
            return $false
        }
    }
    else {
        return $false
    }
}

# check python tools.
if( (CheckPythonExist) -eq $false ) {
    ExitTheScript -ScriptExitCode -1
}

# verify Strata path.
if( (CheckStrataExist) -Eq $false) {
    ExitTheScript -ScriptExitCode -1
}

# verify Strata path.
if( (ExecuteTheTest) -Eq $false) {
    ExitTheScript -ScriptExitCode -1
}

# Test successfull!
ExitTheScript -ScriptExitCode 0
