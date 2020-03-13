# This test is semi automated as it requires someone to absove the ui for 
# prober rendering.

# squence of test:
#   1. Start the python script `zmq-client.py` 
#   2. Run Strata Dev Studio.
#   3. Close every thing.

# Script outline:
# start the script in the background
# start Strata
# bring the script back to the foreground again
# wait until everything is done...

# verify that the tools exits:
    # python, pyzmq         -------> Done
    # correct Strata path
    # script exists


$PATH_TO_STRATA="C:\Users\zbjmpd\spyglass\host\Debug\bin\Strata Developer Studio.exe"

# function to check if python and pyzmq are installed, if both were found it will return True,
function CheckPythonExist {
    param (
        # OptionalParameters
    )
    Try {
        Write-Host "Looking for python..."
        If ((Start-Process python --version -Wait -WindowStyle Hidden -PassThru).ExitCode -Eq 0) {
            Write-Host "Python found."
            Write-Host "Looking for pyzmq..."
            If((Start-Process python '-c "import zmq"' -WindowStyle Hidden -Wait -PassThru).ExitCode -Eq 0) {
                Write-Host "pyzmq found."
            }
            Else {
                Write-Host "pyzmq not found. aborting..."
                Return $false
            }
        } 
        Else {           
            Write-Host "Python not found. aborting..."
            Return $false
        }  
    } Catch [System.InvalidOperationException] {
        Write-Host "Python not found. aborting..."
        Return $false
    }
    Return $true
}

# This functin is to check if Strata Develoiper studio Exist
function CheckStrataExist {
    Write-Host "Looking for Strata Developer Studio in" $PATH_TO_STRATA
    if(Test-Path -Path $PATH_TO_STRATA) {
        Write-Host "Strata Developer Studio found."
        Return $true
    }
    else {
        Write-Host "Strta Developer Studio not found. aborting..."
        Return $false 
    }
}

# Function to run the test, it will return True if the test was successful 
function ExecuteTheTest {
    # check if the python script exesit.
    Write-Host "Looking for the test script in" $PSScriptRoot
    if(Test-Path -Path "$($PSScriptRoot)\zmq-router.py") {
        write-host "Script Found"
        $strataDev = Start-Process $PATH_TO_STRATA -PassThru
        $pythonScript = Start-Process python "$($PSScriptRoot)\zmq-router.py" -NoNewWindow -PassThru -wait
        Write-Host "Test is done."
        Write-Host "Killing Strata Developer Studio..."
        stop-process $strataDev.id

        if($pythonScript.ExitCode -eq 0) { # Test Successful
            Write-Host "Test Successful."
            return $true
        }
        else {
            Write-Host "Test failed."
            Write-Host "Exit Code =" $pythonScript.ExitCode
            return $false
        }
    }
    else {
        return $false
    }
}

# check python tools.
if( (CheckPythonExist) -eq $false ) {
    exit -1
}

# verify Strata path.
if( (CheckStrataExist) -Eq $false) {
    exit -1
}

# verify Strata path.
if( (ExecuteTheTest) -Eq $false) {
    exit -1
}

write-host "============================================================================================================================================"
write-host "============================================================================================================================================"
exit 0


# $strataDev = Start-Process $PATH_TO_STRATA -PassThru
# $pythonScript = Start-Process python .\zmq-router.py -NoNewWindow -PassThru -wait

# Write-Host $pythonScript.ExitCode
# Write-Host "Test is done."
# Write-Host "Killing Strata Developer Studio..."
# stop-process $strataDev.id
# Write-Host "Exitting..."