import json
import time
import os

import zmq

# Default zmq address
defZmqURL = "tcp://127.0.0.1:5563"

# Hardcoded uuid list from ---> spyglass/host/apps/DeveloperStudio/js/uuid_map.js
uuidList = ["101", "201", "202", "203", "204", "206", "207", "208", "209", "210", "211", "212", "213", "214", "215", "216", "217", "218", "219",
            "220", "221", "222", "225", "226", "227", "228", "229", "230", "231", "232", "233", "238", "239", "240", "243", "244", "245", "246", "265"]

# Sample commands
returnToPlatListRes = b'{"hcs::notification":{"list":[],"type":"connected_platforms"}}'
emptyDynamicPlatformList = b'{"hcs::notification":{"list":[],"type":"all_platforms"}}'

# Open and parse dynamic platform list json file, the file was modified to not have hardcoded img paths
# The file should be next to the script.
# get the location of the script 
scriptPath = os.path.dirname(os.path.realpath(__file__))
# Open the file.
with open("%s/DynamicPlatformList.json" % scriptPath) as f:
    dynamicPlatformList = json.load(f)

# function to print line seperator, to make the code more neat :)
def printLineSep(charSym='-'):
    for i in range(140):
        print(charSym, end='')
    print()

# function to get the dynamic platform list from hcs, keep it for future refrence
def getRealHcsRes():
    tempContext = zmq.Context()
    printLineSep()
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
    printLineSep()

# Utility function to send commands to the ui
def sendOpenPlatformCtrlView(classID):
    myEncodedStr = bytes(
        "{\"hcs::notification\":{\"list\":[{\"class_id\":\"%s\",\"connection\":\"connected\",\"verbose_name\":\"\"}],\"type\":\"connected_platforms\"}}" % classID, 'utf-8')
    
    print("sending:", myEncodedStr, "...")
    client.send_multipart([strataId, myEncodedStr])
    print("Sent.")
    time.sleep(8)
    print("Returning to platform selector page...")
    client.send_multipart([strataId, returnToPlatListRes])
    printLineSep()
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
client.RCVTIMEO = 10000 # 10s timeout.
client.setsockopt(zmq.IDENTITY, b'zmqRouterTest')
client.bind(defZmqURL)

# get client id of starta UI
printLineSep()
printLineSep()
print("Waiting for Strata Developer Studio to connect...")

# Wait for 10s to get a message from Strata, otherwise fail.
try:
    strataId = client.recv()
except zmq.Again:
    print("No Response recived from Strata. Exiting...")
    quit(-1)
if not strataId:
    print("Recived an empty response. Exiting...")
    quit(-1)

print("Strata id is [ %s ]" % (strataId))
printLineSep()
printLineSep()

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
        print("Recived an empty response. Exiting...")
        quit(-1)

    print("Received reply [ %s ]" % (message))
    printLineSep()

    if (message == b'{"hcs::cmd":"dynamic_platform_list","payload":{}}'):
        # send the platform list and wait
        # client.send_multipart([strataId, emptyDynamicPlatformList])
        client.send_multipart(
            [strataId, bytes(json.dumps(dynamicPlatformList), 'utf-8')])
        time.sleep(1)
        # useDynamicPlatformList()
        useHardcoddedUUIDList()
        print("Done.")
        quit(0)              # Exit as soon as you finish the control views
    elif (message == b'{"cmd":"unregister","payload":{}}'):
        printLineSep()
        print("Strata UI was closed. Exitting...")
        printLineSep()
        quit()
