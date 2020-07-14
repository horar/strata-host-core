'''
Singleton modlue for connecting and sending commands to strata.
'''
import zmq
import json
import threading
DEFAULT_URL = "tcp://127.0.0.1:5563"

__client:zmq.Socket
__strataId:bytes
__proc = None


def bind(url = DEFAULT_URL):
    '''
    Bind to the strata instance at url.
    :param url:
    :return:
    '''
    context = zmq.Context.instance()

    global __client
    global __strataId
    __client = context.socket(zmq.ROUTER)
    __client.RCVTIMEO = 10000  # no timeout
    __client.setsockopt(zmq.IDENTITY, b'zmqRouterTest')
    __client.bind(url)


def __init():
    global __strataId
    global __client

    __strataId = __client.recv()
    initPlatformList()

def initPlatformList():
    '''
    Wait untill Strata requests a platform list and send an empty one.
    :return:
    '''
    global __client
    while __client.recv() != b'{"hcs::cmd":"dynamic_platform_list","payload":{}}':
        pass
    emptyDynamicPlatformList = b'{"hcs::notification":{"list":[{"class_id":"201"}],"type":"all_platforms"}}'
    __client.send_multipart([__strataId, emptyDynamicPlatformList])


def bindToStrata(url = DEFAULT_URL):
    '''
    Bind to HCS port and start strata
    :param strataPath:
    :param url:
    :return:
    '''

    bind(url)

    #Must start attempting to recive data before strata is started
    initThread = threading.Thread(target=__init, daemon= True)
    initThread.start()

    # global __proc
    # dirname = os.path.dirname(__file__)
    # path = os.path.join(dirname, 'RunSDS.ps1')
    # __proc = subprocess.Popen('powershell.exe -ExecutionPolicy Unrestricted ' + path)

    # start_info = win32process.STARTUPINFO()
    # start_info.dwFlags = win32con.STARTF_USESHOWWINDOW
    # start_info.wShowWindow = win32con.SW_MAXIMIZE
    #
    # hProcess, hThread, dwProcessId, dwThreadId = win32process.CreateProcess(
    #     strataPath,
    #     None,
    #     None,
    #     None,
    #     False,
    #     0,
    #     None,
    #     None,
    #     start_info
    # )
    # return hProcess


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
                    "class_id":classId
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
    myEncodedStr = bytes(
        "{\"hcs::notification\":{\"list\":[],\"type\":\"connected_platforms\"}}", 'utf-8')
    global __client
    global __strataId
    __client.send_multipart([__strataId, myEncodedStr])

if __name__ == "__main__":
    context = zmq.Context.instance()
    __client = context.socket(zmq.ROUTER)
    __client.RCVTIMEO = 10000  # 10s timeout.
    __client.setsockopt(zmq.IDENTITY, b'zmqRouterTest')
    __client.bind(DEFAULT_URL)
    try:
        __strataId = __client.recv()
    except zmq.Again:
        print("No Response received from Strata. Exiting...")
        quit(-1)
    if not __strataId:
        print("received an empty response. Exiting...")
        quit(-1)

    while True:
        print("waiting for response..")

        # 10s timeout.
        try:
            message = __client.recv()
        except zmq.Again:
            print("Response Timeout. Exiting...")
            quit(-1)
        if not message:
            print("received an empty response. Exiting...")
            quit(-1)

        print("Received reply [ %s ]" % (message))
        emptyDynamicPlatformList = b'{"hcs::notification":{"list":[{"class_id":"201"}],"type":"all_platforms"}}'

        if (message == b'{"hcs::cmd":"dynamic_platform_list","payload":{}}'):
            # If the dynamicPlatformList.json file exist use it, otherwise, send the empty list and use
            # the hardcoded uuidList.
            # Send the platform list and wait
            __client.send_multipart([__strataId, emptyDynamicPlatformList])

            classID = "201"
            myEncodedStr = bytes(
                "{\"hcs::notification\":{\"list\":[{\"class_id\":\"%s\",\"connection\":\"connected\",\"verbose_name\":\"\"}],\"type\":\"connected_platforms\"}}" % classID,
                'utf-8')
            __client.send_multipart([__strataId, myEncodedStr])

    import TestCommon
    # bind(DEFAULT_URL)
    # print("bind")
    # time.sleep(10)
    # reciveStrataId()
    # openPlatform("201")
    #closePlatforms(client, strataId)