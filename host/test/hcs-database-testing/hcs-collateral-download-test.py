# Automated collateral download testing
#
# Python 3

import sys, json, os.path
try:
    import zmq
except ImportError:
    print("\nZeroMQ library for Python is required, visit https://zeromq.org/languages/python/ for instructions.\nExiting.\n")
    sys.exit(-1)
if len(sys.argv) < 2:
    print("\nError: no argument provided.\nInvoke as:\n'python hcs-collateral-download-test.py <HCS ENDPOINT>'.")
    print("Example:\n'python hcs-collateral-download-test.py tcp://127.0.0.1:5563'.\nExiting.\n")
    sys.exit(-1)
hcs_endpoint = sys.argv[1]    

# Open socket and connect it to HCS
context = zmq.Context()
socket = context.socket(zmq.DEALER)
socket.connect(hcs_endpoint)
socket.RCVTIMEO = 10000 # HCS reply timeout (in milliseconds)

# Send register_client command to HCS
print("\nSending 1st notification (REGISTER CLIENT)")
socket.send_string('{"cmd":"register_client"}')

# Send connect_data_source command to HCS
print("\nSending 2nd notification (CONNECT DATA SOURCE)")
socket.send_string('{"db::cmd":"connect_data_source","db::payload":{"type":"document"}}')

# Send dynamic_platform_list command to HCS, retrieve reply
print("\nSending 3rd notification (DYNAMIC PLATFORM LIST)", end = '')
socket.send_string('{"hcs::cmd":"dynamic_platform_list","payload":{}}')
try:
    message = socket.recv()
except zmq.Again:
    print("\nNo response received, is HCS running?\nExiting.\n")
    sys.exit(-1)
if not message:
    print("\nError: received empty response, exiting.")
    sys.exit(-1)
message = json.loads(message)
platform_list = message["hcs::notification"]["list"]
print(", received reply with " + str(len(platform_list)) + " platforms.")

# Start main loop over each platform
for platform in platform_list:
    print("\n" + 80 * "#" + "\n\nSending HCS notification for platform " + str(platform["class_id"]), end = '')
    msg_to_HCS = '{"cmd":"platform_select","payload":{"platform_uuid":"' + str(platform["class_id"]) + '","remote":"connected"}}'
    socket.send_string(msg_to_HCS)
    try:
        message = socket.recv()
    except zmq.Again:
        print("\nNo response received, is HCS running?\nExiting.\n")
        sys.exit(-1)
    if not message:
        print("\nError: received empty response from HCS, exiting.")
        sys.exit(-1)
    message = json.loads(message)
    try:
        file_list = message["cloud::notification"]["documents"]
    except KeyError:
        print("\nError: received empty response from HCS, exiting.")
        sys.exit(-1)
    file_list = [file for file in file_list if file["category"] == "view"]
    print(", received reply with " + str(len(file_list)) + " files to be automatically downloaded.")
    for file in file_list:
        print("\nChecking for file " + file["uri"])
        print("OK, FILE FOUND") if os.path.isfile(file["uri"]) else print("FAILED, FILE NOT FOUND")