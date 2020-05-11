import zmq, sys, json

# Usage: <TestFileName>.py <zmq client address>

# Default zmq address
defZmqURL = "tcp://127.0.0.1:5563"

# Check commandline arguments
if len(sys.argv) != 2:
    print("Zmq client address was not provided. using the default address:" + defZmqURL)
    zmqClientURL = defZmqURL
else:
    zmqClientURL = sys.argv[1]

def checkIfPlatformConnected(hcsMessage):
    # Check if the message is for a valid connected platform. 
    #     "hcs::notification": {
    #         "list": [
    #             {
    #                 "class_id": "XXXX"
    #             }
    #         ],
    #         "type": "connected_platforms"
    #     }
    jsonResponse = json.loads(message)

    if ( "hcs::notification" in jsonResponse
            and "type" in jsonResponse["hcs::notification"]
            and jsonResponse["hcs::notification"]["type"] == "connected_platforms"
            and "list" in jsonResponse["hcs::notification"]
            and len(jsonResponse["hcs::notification"]["list"]) > 0):

        print("Valid connected platform notification.")
        return True
    
    print("Invalid connected platform notification.")
    return False

# Zmq set up
context = zmq.Context()
socket = context.socket(zmq.DEALER)
socket.RCVTIMEO = 2000
socket.connect(zmqClientURL)

# register the client with hcs. 
print("Connecting to hcs...")
socket.send(b'{"cmd":"register_client","payload":{}}')

# Wait for hcs notification of connected platforms
# if the notification was not received the test will fail due to a timeout
# if the connected platforms list is empty or the command is not expected, the test will fail.
while True:
    print ("waiting for hcs response...")
    try:
        message = socket.recv()
        print("Received reply [ %s ]" % (message))
        if checkIfPlatformConnected(message):
            print("Platform connected.")
            quit(0)
        else:
            print("Invalid hcs response. Aborting...")
            quit(-1)
        
    except zmq.Again:
        print("Response Timeout. Aborting...")
        quit(-1)
