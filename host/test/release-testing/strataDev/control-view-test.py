import json
import time
import os
import sys

import zmq

# Usage: control-view-test.py <zmq client address>

# Default zmq address
defZmqURL = "tcp://127.0.0.1:5563"

# Check commandline arguments
if len(sys.argv) != 2:
    print("Zmq client address was not provided. using the default address:" + defZmqURL)
    zmqClientURL = defZmqURL
else:
    zmqClientURL = sys.argv[1]

# Hardcoded uuid list from ---> spyglass/host/apps/DeveloperStudio/js/uuid_map.js
uuidList = ["101", "201", "202", "203", "204", "206", "207", "208", "209", "210", "211", "212", "213", "214", "215", "216", "217", "218", "219",
            "220", "221", "222", "225", "226", "227", "228", "229", "230", "231", "232", "233", "238", "239", "240", "243", "244", "245", "246", "265"]

# Sample commands
returnToPlatListResponse = b'{"hcs::notification":{"list":[],"type":"connected_platforms"}}'
emptyDynamicPlatformList = b'{"hcs::notification":{"list":[],"type":"all_platforms"}}'

# get the location of the script
scriptPath = os.path.dirname(os.path.realpath(__file__))

# Flag to to check if the json file exist or not.
DynamicPlatformListJsonFound = False

# Check if DynamicPlatformList.json then use it, otherwise send an empty list to SDS and use the hardcoded uuidList to cycle through the views.
print("Checking if DynamicPlatformList.json exist...")
if os.path.exists("%s/DynamicPlatformList.json" % scriptPath):
    print("DynamicPlatformList.json found.")
    # Open and parse dynamic platform list json file, the file was modified to not have hardcoded img paths
    # The file should be next to the script.
    # Open the file.
    with open("%s/DynamicPlatformList.json" % scriptPath) as f:
        dynamicPlatformList = json.load(f)
    DynamicPlatformListJsonFound = True
else:
    print("DynamicPlatformList.json is missing. Using hardcoded uuidList.")
    DynamicPlatformListJsonFound = False

# function to print line separator, to make the code more neat :)
def printLineSeparator(charSym='-'):
    print(80 * charSym)

# function to get the dynamic platform list from hcs, keep it for future reference
def getRealHcsResponse():
    tempContext = zmq.Context()
    printLineSeparator()
    print("Connecting to hcs...")
    tempSocket = tempContext.socket(zmq.DEALER)
    tempSocket.setsockopt(zmq.IDENTITY, b'pyscript')
    tempSocket.connect(defZmqURL)
    print("Connected to hcs...")

    tempSocket.send(b'{"cmd":"register_client"}')  # no response..
    print("Register client message sent...")

    tempSocket.send(b'{"hcs::cmd":"dynamic_platform_list","payload":{}}')
    print("Waiting for the dynamic platform list...")
    message = tempSocket.recv()
    print("Received reply [ %s ]" % (message))
    printLineSeparator()

# Utility function to send commands to the ui
def sendOpenPlatformCtrlView(classID):
    myEncodedStr = bytes(
        "{\"hcs::notification\":{\"list\":[{\"class_id\":\"%s\",\"connection\":\"connected\",\"verbose_name\":\"\"}],\"type\":\"connected_platforms\"}}" % classID, 'utf-8')

    print("sending:", myEncodedStr)
    client.send_multipart([strataId, myEncodedStr])
    print("Sent.")
    time.sleep(8)
    print("Returning to platform selector page...")
    client.send_multipart([strataId, returnToPlatListResponse])
    printLineSeparator()
    time.sleep(1)

# send commands to open the control views of the platforms from the hardcoded UUID list
def useHardcoddedUUIDList():
    for platform in uuidList:
        sendOpenPlatformCtrlView(platform)

# send commands to open the control views of the platforms from the dynamic platform list
def useDynamicPlatformList():
    # parse the dynamic platform list
    for platform in dynamicPlatformList["hcs::notification"]["list"]:
        sendOpenPlatformCtrlView(platform["class_id"])

# Create zmq router to connect to the UI
context = zmq.Context.instance()
client = context.socket(zmq.ROUTER)
client.RCVTIMEO = 10000  # 10s timeout.
client.setsockopt(zmq.IDENTITY, b'zmqRouterTest')
client.bind(zmqClientURL)

# get client id of strata UI
printLineSeparator()
printLineSeparator()
print("Waiting for Strata Developer Studio to connect...")

# Wait for 10s to get a message from Strata, otherwise fail.
try:
    strataId = client.recv()
except zmq.Again:
    print("No Response received from Strata. Exiting...")
    quit(-1)
if not strataId:
    print("received an empty response. Exiting...")
    quit(-1)

print("Strata id is [ %s ]" % (strataId))
printLineSeparator()
printLineSeparator()

# While loop until we close Strata..
while True:
    print("waiting for response..")

    # 10s timeout.
    try:
        message = client.recv()
    except zmq.Again:
        print("Response Timeout. Exiting...")
        quit(-1)
    if not message:
        print("received an empty response. Exiting...")
        quit(-1)

    print("Received reply [ %s ]" % (message))
    printLineSeparator()

    if (message == b'{"hcs::cmd":"dynamic_platform_list","payload":{}}'):
        # If the dynamicPlatformList.json file exist use it, otherwise, send the empty list and use
        # the hardcoded uuidList.
        # Send the platform list and wait
        if DynamicPlatformListJsonFound:
            client.send_multipart(
                [strataId, bytes(json.dumps(dynamicPlatformList), 'utf-8')])
            useDynamicPlatformList()
        else:
            client.send_multipart([strataId, emptyDynamicPlatformList])
            useHardcoddedUUIDList()
        time.sleep(1)
        print("Done.")
        quit(0)              # Exit as soon as you finish the control views
    elif (message == b'{"hcs::cmd":"unregister","payload":{}}'):
        printLineSeparator()
        print("Strata UI was closed. Exitting...")
        printLineSeparator()
        quit()
