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

python .\zmq-router.py 