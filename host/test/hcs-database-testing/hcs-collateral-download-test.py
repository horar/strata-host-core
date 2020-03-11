# Automated collateral download testing
#
# Python 3

import sys, json, os.path, hashlib
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

def sendToHcsAndWait(message_to_HCS):
    "Send notification to HCS through ZMQ and wait for response"
    # This function will quit the script if it fails
    socket.send_string(message_to_HCS)
    try:
        message_from_HCS = socket.recv()
    except zmq.Again:
        print("\nNo response received, is HCS running?\nExiting.\n")
        sys.exit(-1)
    if not message_from_HCS:
        print("\nError: received empty response, exiting.")
        sys.exit(-1)
    return json.loads(message_from_HCS)

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
message = sendToHcsAndWait('{"hcs::cmd":"dynamic_platform_list","payload":{}}')
platform_list = message["hcs::notification"]["list"]
print(", received reply with " + str(len(platform_list)) + " platforms.")

# Start main loop over each platform
total_failed_tests = 0
for platform in platform_list:
    platform_failed_tests = 0
    print("\n" + 80 * "#" + "\n\nSending HCS notification for platform " + str(platform["class_id"]), end = '')
    message_to_HCS = '{"cmd":"platform_select","payload":{"platform_uuid":"' + str(platform["class_id"]) + '"}}'
    message_from_HCS = sendToHcsAndWait(message_to_HCS)
    try:
        file_list = message_from_HCS["cloud::notification"]["documents"]
    except KeyError:
        print("\nError: received empty response from HCS, exiting.")
        sys.exit(-1)
    print(", received reply with " + str(len(file_list)) + " files to be automatically downloaded.")
    for file in file_list:
        if os.path.isfile(file["uri"]): # File found where expected - perform MD5 check
            with open(file["uri"], 'rb') as file_md5_check:
                calculated_md5 = hashlib.md5(file_md5_check.read()).hexdigest()
                if calculated_md5 != file["md5"]: # MD5 check failed
                    print("\nTest failed, MD5 check unsuccessful for file:\n" + file["uri"])
                    platform_failed_tests += 1
                    total_failed_tests += 1
        else: # File not found where expected
            print("\nTest failed, file not found:\n" + file["uri"])
            platform_failed_tests += 1
            total_failed_tests += 1
    if platform_failed_tests < 1:
        print("\nAll tests PASSED for platform " + str(platform["class_id"]) + ".")
    else:
        print("\nWARNING:\nA total of " + str(platform_failed_tests) + " unsuccessful test cases were found for this platform.")


    break
        # print("\nChecking for file " + file["uri"])
        # print("OK, FILE FOUND") if os.path.isfile(file["uri"]) else print("FAILED, FILE NOT FOUND")

print("\n\npython done -- total failed tests " + str(total_failed_tests))