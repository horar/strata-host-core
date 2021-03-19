'''
Singleton module for connecting and sending commands to strata.
'''
import json
import threading

import time
import zmq
from shutil import copy2
from Common import TestLogger
import os

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
    initPlatformList([
        {
            "filters": [
                "automotive",
                "industrial"
            ],
            "available": {
                "control":True,
                "documents":False,
                "order":False,
                "unlisted":False
            },
            "class_id":"201",
            "description":"Test Platform",
            "image":"",
            "opn":"STR-TEST-PLATFORM",
            "verbose_name":"Test Platform",
            "version":"1.0.0"
        }
    ])


def initPlatformList(platforms = [{"class_id": "201"}]):
    '''
    Wait until Strata requests a platform list and send an empty one.
    :return:
    '''
    global __client

    dynamicPlatformList = {
        "hcs::notification":{
            "list": platforms,
            "type": "all_platforms"
        }
    }

    __client.send_multipart([__strataId, bytes(json.dumps(dynamicPlatformList), 'utf-8')])


def platformDocumentsMessage(classId, datasheets, documents, firmwares, controlViews):
    '''
    Spoofed notification for a platform's documents
    :param classId:
    :param datasheets:
    :param documents:
    :param firmwares:
    :param controlViews:
    '''
    global __client
    global __strataId

    command = {
        "cloud::notification": {
            "type": "document",
            "class_id": classId,
            "datasheets": datasheets,
            "documents": documents,
            "firmwares": firmwares,
            "control_views": controlViews
        }
    }

    print("Sending 'document' notification")
    __client.send_multipart([__strataId, bytes(json.dumps(command), 'utf-8')])


def controlViewDownloadProgressMessage(classId, url, filepath, inputRccPath):
    '''
    Spoofed notification for download progress
    :param classId:
    :param url:
    :param filepath:
    :param inputRccPath:
    '''
    global __client
    global __strataId

    bytesReceived = 0

    command = {
        "hcs::notification": {
            "type": "control_view_download_progress",
            "url": url,
            "filepath": filepath,
            "bytes_received": 0,
            "bytes_total": 1000
        }
    }

    # Below should take 3 seconds to run
    while bytesReceived <= 1000: 
        time.sleep(1)
        bytesReceived += 334
        command["hcs::notification"]["bytes_received"] = bytesReceived
        with TestLogger() as logger:
            logger.info("Sending bytes received: {}/{}".format(bytesReceived, 1000))
        __client.send_multipart([__strataId, bytes(json.dumps(command), 'utf-8')])

    command = {
        "hcs::notification": {
            "type": "download_view_finished",
            "url": url,
            "filepath": filepath,
            "error_string": ""
        }
    }

    dirPath = os.path.dirname(filepath)
    os.makedirs(dirPath, exist_ok=True)
    with TestLogger() as logger:
        logger.info("Copying {} to {}".format(inputRccPath, filepath))
        copy2(inputRccPath, filepath)
        logger.info("Sending 'download_view_finished' notification")
    __client.send_multipart([__strataId, bytes(json.dumps(command), 'utf-8')])


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
                    "controller_type": 1,
                    "firmware_version": "1.0.0",
                    "bootloader_version": "1.0.0"
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
