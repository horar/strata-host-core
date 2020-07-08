import zmq
import time
DEFAULT_URL = "tcp://127.0.0.1:5563"
def connect(url):
    context = zmq.Context.instance()

    client = context.socket(zmq.DEALER)
    client.RCVTIMEO = 10000  # 10s timeout.
    client.connect(url)
    client.send(b'{"cmd":"register_client"}')

    strataId = client.recv()

    return (client, strataId)

def openPlatform(client, classId, strataId):
    myEncodedStr = bytes(
        "{\"hcs::notification\":{\"list\":[{\"class_id\":\"%s\",\"connection\":\"connected\",\"verbose_name\":\"\"}],\"type\":\"connected_platforms\"}}" % classId, 'utf-8')

    client.send_multipart([strataId, myEncodedStr])

def closePlatforms(client, strataId):
    myEncodedStr = bytes(
        "{\"hcs::notification\":{\"list\":[],\"type\":\"connected_platforms\"}}", 'utf-8')

    client.send_multipart([strataId, myEncodedStr])

if __name__ == "__main__":

    import TestCommon
    client, strataId = connect(DEFAULT_URL)
    openPlatform(client, TestCommon.LOGIC_GATE_CLASS_ID, strataId)
    #closePlatforms(client, strataId)