'''
Tests involving loading control views via OTA.
'''

import Common
import StrataInterface as strata
import sys
import time 
import json
import zmq
import os
from shutil import copy2
from GUIInterface.StrataUI import *

hcs_endpoint = "tcp://127.0.0.1:5563"

class OpenControlView(unittest.TestCase):
    '''
    Test opening a control view that via OTA
    '''

    def setUp(self):
        rccFilePath = (os.getenv("SDSRootDir") + "/views-logic-gate.rcc").replace('\\', '/')
        if (os.path.exists(rccFilePath)):
            os.remove(rccFilePath)
        ui = StrataUI()
        ui.SetToLoginTab()

    def tearDown(self) -> None:
        rccFilePath = (os.getenv("SDSRootDir") + "/views-logic-gate.rcc").replace('\\', '/')
        currentDir = os.path.dirname(os.path.realpath(__file__))
        copy2(os.path.abspath(currentDir + "/../views-logic-gate.rcc"), rccFilePath)
        ui = StrataUI()
        ui.CloseControlView()
        Logout(ui)
        strata.closePlatforms()

    def test_open_ota_control_view(self):
        args = Common.getCommandLineArguments(sys.argv)
        ui = StrataUI()
        # assert on login page
        self.assertIsNotNone(ui.OnLoginScreen())

        Login(ui, args.username, args.password, self)

        time.sleep(0.5)
        self.assertTrue(ui.OnPlatformView())

        strata.initPlatformList([
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

        time.sleep(3)
        strata.openPlatform("201")
        self.assertTrue(ui.ConnectedPlatforms() > 0)
        time.sleep(1)

        docs = self.sample_platform_docs("201")

        outputPath = os.getenv("APPDATA")
        outputPath += "/ON Semiconductor/Host Controller Service/DEV/documents/control_views/{}".format(docs["control_view"][1]["uri"])
        outputPath = outputPath.replace('\\', '/')

        if (os.path.exists(outputPath)):
            os.remove(outputPath)

        ui.OpenControlView()
        time.sleep(0.7)
        strata.platformDocumentsMessage(classId="201",
            documents=docs["documents"],
            datasheets=docs["datasheets"],
            firmwares=docs["firmwares"],
            controlViews=docs["control_view"])

        time.sleep(1)
        currentDir = os.path.dirname(os.path.realpath(__file__))
        rccPath = os.path.abspath(currentDir + "/../views-logic-gate.rcc")
        strata.controlViewDownloadProgressMessage("201", docs["control_view"][1]["uri"], outputPath, rccPath)

        self.assertTrue(ui.OnControlView())

    def test_open_previously_downloaded_control_view(self):
        args = Common.getCommandLineArguments(sys.argv)
        ui = StrataUI()
        # assert on login page
        self.assertIsNotNone(ui.OnLoginScreen())

        Login(ui, args.username, args.password, self)

        time.sleep(0.5)
        self.assertTrue(ui.OnPlatformView())

        docs = self.sample_platform_docs("201")
        strata.initPlatformList([
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

        time.sleep(3)
        strata.openPlatform("201")
        self.assertTrue(ui.ConnectedPlatforms() > 0)
        time.sleep(1)

        ui.OpenControlView()
        time.sleep(0.7)
        strata.platformDocumentsMessage(classId="201",
            documents=docs["documents"],
            datasheets=docs["datasheets"],
            firmwares=docs["firmwares"],
            controlViews=docs["control_view"])

        time.sleep(1)
        self.assertTrue(ui.OnControlView())


    def sample_platform_docs(self, classId):
        return {
            "channels": classId,
            "documents": {
                "downloads": [
                ],
                "views": [
                ]
            },
            "datasheets": [
            ],
            "firmwares": [
                {
                    "uri": "test/firmware/logic-gates-debug-1.0.0.bin",
                    "md5": "4faf37c0b328bcbba49bb918301e9cac",
                    "name": "firmware",
                    "timestamp": "2019-11-04 17:16:48",
                    "version": "1.0.0"
                },
                {
                    "uri": "test/firmware/logic-gates-debug-1.0.1.bin",
                    "md5": "6bb9955c20d9fafaa1f80adb26852dc8",
                    "name": "firmware",
                    "timestamp": "2020-11-04 17:16:48",
                    "version": "1.0.1"
                }
            ],
            "control_view": [
                {
                    "uri": "test/control-views/logic-gates-1.1.0.rcc",
                    "md5": "be047ba32e5ff99907e040456f3f65f9",
                    "name": "control view",
                    "timestamp": "2019-11-04 17:16:48",
                    "version": "1.1.0",
                    "filepath":"", 
                },
                {
                    "uri": "test/control-views/logic-gates-1.1.3.rcc",
                    "md5": "be047ba32e5ff99907e040456f3f65f9",
                    "name": "control view",
                    "timestamp": "2019-11-07 17:00:00",
                    "version": "1.1.3",
                    "filepath": ""
                }
            ],
            "name": "STR-TEST-PLATFORM",
            "platform_selector": {
                "file": "",
                "filename": "thumbnail",
                "filesize": "4717",
                "md5": "7a1c7a45b7f46761452abab05b4bf848",
                "name": "platform_selector",
                "prettyName": "thumbnail",
                "timestamp": "2020-04-14T00:30:46.281Z"
            }
        }