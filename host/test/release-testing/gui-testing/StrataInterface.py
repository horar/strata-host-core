'''
Singleton module for connecting and sending commands to strata.
'''
import json
import threading

import zmq

__client: zmq.Socket
__strataId: bytes


def __bind(url):
    '''
    Bind to the strata instance at url.
    :param url:
    :return:
    '''
    context = zmq.Context.instance()

    global __client
    global __strataId
    __client = context.socket(zmq.ROUTER)
    __client.RCVTIMEO = 10000
    __client.setsockopt(zmq.IDENTITY, b'zmqRouterTest')
    __client.bind(url)


def __init():
    global __strataId
    global __client

    __strataId = __client.recv()
    initPlatformList()


def initPlatformList():
    '''
    Wait until Strata requests a platform list and send an empty one.
    :return:
    '''
    global __client

    dynamicPlatformList = {
        "hcs::notification":{
            "list":[
                {
                    "class_id":"201"
                }
            ],
            "type": "all_platforms"
        }
    }

    __client.send_multipart([__strataId, bytes(json.dumps(dynamicPlatformList), 'utf-8')])


def bindToStrata(url):
    '''
    Bind to HCS port and start receiving data
    :param url:
    :return:
    '''

    __bind(url)

    # Must start attempting to recive data before strata is started
    initThread = threading.Thread(target=__init, daemon=True)
    initThread.start()


def openPlatform(classId):
    '''
    Command Strata to open a platform with the given classId.
    :param classId:
    :return:
    '''
    command = {
        "hcs::notification": {
            "type": "connected_platforms",
            "list": [
                {
                    "class_id": classId,
                    "device_id": -1089402724,
                    "firmware_version": "1.0.0"
                }
            ]
        }
    }
    global __client
    global __strataId

    __client.send_multipart([__strataId, bytes(json.dumps(command), 'utf-8')])


def cleanup():
    '''
    Cleanup open resources
    :return:
    '''
    zmq.Context().destroy()


def closePlatforms():
    '''
    Disconnect all connected platforms from strata.
    :return:
    '''
    notification = {
        "hcs::notification": {
            "list":[],
            "type":"connected_platforms"
        }
    }

    global __client
    global __strataId
    __client.send_multipart([__strataId, bytes(json.dumps(notification), 'utf-8')])
