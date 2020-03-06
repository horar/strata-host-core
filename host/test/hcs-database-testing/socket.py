#
#   Hello World client in Python
#   Connects REQ socket to tcp://localhost:5555
#   Sends "Hello" to server, expects "World" back
#

import zmq

context = zmq.Context()

#  Socket to talk to server
socket = context.socket(zmq.DEALER)

socket.connect("tcp://127.0.0.1:5563")

print("\nSending 1st notif (Register_Client)\n")
socket.send(b'{"cmd":"register_client"}')

################################################################################

print("\nSending 2nd notif (Connect data source)\n")
socket.send(b'{"db::cmd":"connect_data_source","db::payload":{"type":"document"}}')

################################################################################

print("\nSending 3rd notif (Dyn plat list)\n")
socket.send(b'{"hcs::cmd":"dynamic_platform_list","payload":{}}')
message = socket.recv()
print("Received reply [ %s ]" % (message))

################################################################################

print("\nSending 4th notif (201 connected)\n")
socket.send(b'{"cmd":"platform_select","payload":{"platform_uuid":"201","remote":"connected"}}')
message = socket.recv()
print("Received reply [ %s ]" % (message))