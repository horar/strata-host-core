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
$PATH_TO_STRATA="C:\Users\zbjmpd\spyglass\host\Debug\bin\Strata Developer Studio.exe"

$strataDev = Start-Process $PATH_TO_STRATA -PassThru
$pythonScript = Start-Process python .\zmq-router.py -NoNewWindow -PassThru -wait

echo $pythonScript.ExitCode
echo "Test is done."
echo "Killing Strata Developer Studio..."
stop-process $strataDev.id
echo "Exitting..."