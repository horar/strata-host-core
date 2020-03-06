import sys
try:
    import zmq
except ImportError:
    sys.exit(-1)

context = zmq.Context()

#  Socket to talk to server
socket = context.socket(zmq.DEALER)

socket.connect("tcp://127.0.0.1:5563")

print("\nSending 1st notification (REGISTER CLIENT))")
socket.send(b'{"cmd":"register_client"}')

################################################################################

print("\nSending 2nd notification (CONNECT DATA SOURCE)")
socket.send(b'{"db::cmd":"connect_data_source","db::payload":{"type":"document"}}')

################################################################################

print("\nSending 3rd notification (DYNAMIC PLATFORM LIST)")
socket.send(b'{"hcs::cmd":"dynamic_platform_list","payload":{}}')
message = socket.recv()
if not message:
    print("\nPossible error: received empty response.")

################################################################################

print("\nSending 4th notification (201 connected)")
socket.send(b'{"cmd":"platform_select","payload":{"platform_uuid":"201","remote":"connected"}}')
message = socket.recv()
if not message:
    print("\nPossible error: received empty response.")
