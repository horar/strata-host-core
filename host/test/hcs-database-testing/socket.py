# Automated collateral download testing
#
# Python 3

import sys, json
try:
    import zmq
except ImportError:
    print("\nZeroMQ library for Python is required, visit https://zeromq.org/languages/python/ for instructions.\nExiting.\n")
    sys.exit(-1)

# Open socket and connect it to HCS
context = zmq.Context()
socket = context.socket(zmq.DEALER)
socket.connect("tcp://127.0.0.1:5563")
socket.RCVTIMEO = 2000 # HCS reply timeout (in milliseconds)

################################################################################

# Send register_client command to HCS

print("\nSending 1st notification (REGISTER CLIENT)")
socket.send_string('{"cmd":"register_client"}')

################################################################################

# Send connect_data_source command to HCS

print("\nSending 2nd notification (CONNECT DATA SOURCE)")
socket.send_string('{"db::cmd":"connect_data_source","db::payload":{"type":"document"}}')

################################################################################

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

################################################################################

# Start main loop over each platform
for platform in platform_list:
    print("\n################################################################################\n")
    print("Sending HCS notification for platform " + str(platform["class_id"]) + ".")
    msg_to_HCS = '{"cmd":"platform_select","payload":{"platform_uuid":"' + str(platform["class_id"]) + '","remote":"connected"}}'
    socket.send_string(msg_to_HCS)




    break



# print("\nSending 4th notification (201 connected)")
# socket.send(b'{"cmd":"platform_select","payload":{"platform_uuid":"201","remote":"connected"}}')
# message = socket.recv()
# if not message:
#     print("\nError: received empty response, exiting.")
#     sys.exit(-1)
# print("Received reply [ %s ]" % (message))