import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "js/login.js" as Authenticator

Window {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    title: qsTr("Strata")

    // Debug option(s)
    property bool showDebugCommandBar: false
    property bool is_remote_connected: false


    Component.onCompleted: {
        console.log("Initializing")
        NavigationControl.init(flipable,controlContainer, contentContainer, statusBarContainer)
    }


    Connections {
        target: coreInterface

        onRemoteConnectionChanged:{
            // Successful remote connection
            if (result === true){
                is_remote_connected = true
            }
            else {
                is_remote_connected = false
            }
        }
    }

    onClosing: {
        if(is_remote_connected) {
            // sending remote disconnect message to hcs
            var remote_disconnect_json = {
                "hcs::cmd":"remote_disconnect",
            }
            coreInterface.sendCommand(JSON.stringify(remote_disconnect_json))

            console.log("UI -> HCS ", JSON.stringify(remote_disconnect_json))
        }

        var remote_json = {
            "hcs::cmd":"advertise",
            "payload": {
                "advertise_platforms":false
            }
        }
        console.log("asking hcs to advertise the platforms",JSON.stringify(remote_json))
        coreInterface.sendCommand(JSON.stringify(remote_json))
        // End session with HCS
        coreInterface.unregisterClient();
    }

    Column {
        id: view
        spacing: 0
        anchors.fill: parent

        Rectangle {
            id: statusBarContainer
            height: visible ? 40 : 0
            width: parent.width

            property real windowHeight: mainWindow.height  // for centering popups spawned from the statusbar
            property bool showDebug: showDebugCommandBar  // for linking debug in status bar to the debug bar
        }

        Flipable {
            id: flipable
            height: parent.height - statusBarContainer.height
            width: parent.width

            property bool flipped: false

            front: SGControlContainer { id: controlContainer }
            back: SGContentContainer { id: contentContainer }

            transform: Rotation {
                id: rotation
                origin {
                    x: flipable.width/2;
                    y: flipable.height/2
                }
                axis {
                    x: 0;
                    y: -1;
                    z: 0
                }    // set axis.y to 1 to rotate around y-axis

                angle: 0    // the default angle
            }

            states: State {
                name: "back"
                PropertyChanges { target: rotation; angle: 180 }
                when: flipable.flipped
            }

            transitions: Transition {
                NumberAnimation { target: rotation; property: "angle"; duration: 400 }
            }
        }
    }

    // Debug commands for simulation
    Rectangle {
        id: commandBar
        visible: showDebugCommandBar
        width: parent.width
        height: childrenRect.height
        color: "lightgrey"
        anchors {
            bottom: parent.bottom
        }

        // Simulate Platform events
        GridLayout {
            columns: 10
            anchors { horizontalCenter: commandBar.horizontalCenter }
            Button {
                text: "USB-PD"
                onClicked: {
                    var data = { platform_name: "usb-pd"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "BuBU Interface"
                onClicked: {
                    var data = { platform_name: "bubu"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "Motor Vortex"
                onClicked: {
                    var data = { platform_name: "motor-vortex"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "Entice RGB Test"
                onClicked: {
                    var data = { platform_name: "entice_rgb"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "USB-PD 4 Ports"
                onClicked: {
                    var data = { platform_name: "usb-pd-multiport"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "Logic gate"
                onClicked: {
                    var data = { platform_name: "logic-gate"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }


            // UI events
            Button {
                text: "Toggle Content/Control"
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
                }
            }
            Button {
                text: "Statusbar Debug"
                onClicked: {
                    statusBarContainer.showDebug = !statusBarContainer.showDebug
                }
            }
            Button {
                text: "Disconnect"
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, null)
                    var disconnect_json = {"hcs::cmd":"disconnect_platform"}
                    console.log("disonnecting the platform")
                    coreInterface.sendCommand(JSON.stringify(disconnect_json))
                }
            }
            Button {
                text: "Logout"
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT,null)
                }
            }
            Button {
                text: "Login as guest"
                onClicked: {
                    var data = { user_id: "Guest" }
                    NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
                }
            }
        }
    }

    Button {
        text: "X"
        height: 30
        width: height
        onClicked: showDebugCommandBar = false
        anchors {
            right: commandBar.right
            bottom: commandBar.top
        }
        visible: commandBar.visible
    }

    Button {
        text: "DEBUG"
        height: 30
        width: 70
        visible: !showDebugCommandBar
        onClicked: showDebugCommandBar = true
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
    }

    ListModel {
        id: platformListModel

        // These properties are here (not in platform_selection.js) so they generate their built in signals
        property int currentIndex: 0
        property string selectedConnection: "" // Signal that determines UI behaviors

        Component.onCompleted: {
//            console.log("platformListModel component completed");
            if (!PlatformSelection.isInitialized) { PlatformSelection.initialize(this, coreInterface, documentManager) }
            PlatformSelection.populatePlatforms(coreInterface.platform_list_)
        }
    }

    Connections {
        target: coreInterface
        onPlatformListChanged: {
            //console.log("platform list updated: ", list)
            PlatformSelection.populatePlatforms(list)
        }
    }


    // Listen into Core Interface which gives us the platform changes
    Connections {
        target: coreInterface
        onPlatformIDChanged: {
            console.log("Main: PlatformIDChanged to ", id)
            // Map out UUID->platform name
            var uuid_map = {
                "SEC.2018.004.1.1.0.2.20180710161919.1bfacee3-fb60-471d-98f8-fe597bb222cd" : "usb-pd-multiport", //using USB-PD card to masquarade as multiport until hardware is available
                "P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af" : "motor-vortex",
                "P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671" : "bubu",
                "motorvortex1" : "motor-vortex",

            }

            // Send update to NavigationControl
            if (uuid_map.hasOwnProperty(id)){
                console.log("identified new platform as ", uuid_map[id])
                var data = { platform_name : uuid_map[id] }
                NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
            }
        }
        onPlatformStateChanged: {
            console.log("Main: PlatformStateChanged: ", platform_connected_state)

            if(platform_connected_state) {
                // Show control as we have connected
                //NavigationControl.updateState(NavigationControl.events.PLATFORM_CONNECTED_EVENT)
            }
            else if (!platform_connected_state){
                NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT)
            }
        }
    }
}
