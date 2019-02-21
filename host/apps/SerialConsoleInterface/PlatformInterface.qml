import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------
    // List of Connected Platforms

    property var platformList : {
            "default": {
                "name": "No Board Connected",
                "connected": false
            }
    }

    // -------------------
    // List of Tabs/Content

    property var tabList : { "tabCount": 0,
                             "nextTabToConnect": 0,
                             "tabs": []
    }

    // -------------------
    // Test Commands

    property var tests : { "1":
                           [ '{"cmd":"request_platform_id"}',
                           '{"cmd":"request_platform_id1"}',
                           '{"cmd":"request_platform_id2"}',
                           '{"cmd":"request_platform_id3"}',
                           '{"cmd":"request_platform_id4"}',
                            '{"cmd":"request_platform_id5"}' ]
    }

    property var coreCommands : { "1":
                           [ '{"cmd":"request_platform_id"}' ]
    }

    // -------------------------------------------------------------------
    // Connect to platformController notification signals

    Connections {
        target: boardsMgr

        onConnectedBoard: {
            CorePlatformInterface.newBoardConnected(connection_id, verbose_name)
        }

        onDisconnectedBoard: {
            CorePlatformInterface.boardDisconnected(connection_id)
        }

        onNotifyBoardMessage: {
            CorePlatformInterface.boardMessage(connection_id, message)
        }
    }

    signal statusImageUpdate()

    // DEBUG Tool
    Window {
        id: debug
        visible: true
        width: 200
        height: 200
        x:200
        y: 600
        title: "Platform Interface Debug"

        Button {
            id: button1
            text: "connect platform"
            onClicked: {
                CorePlatformInterface.platformConnectionChanged ('{"verboseName":"Fake Platform ID", "connected":true, "platformID": "fakeID"}')
            }
        }

        Button {
            id: button2
            anchors { top: button1.bottom }
            text: "disconnect platform"
            onClicked: {
                CorePlatformInterface.platformConnectionChanged ('{"verboseName":"Fake Platform ID", "connected":false, "platformID": "fakeID"}')
            }
        }
    }
}
