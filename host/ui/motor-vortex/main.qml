import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "js/navigation_control.js" as NavigationControl

Window {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    title: qsTr("Encore Design Suite")

    // Debug option(s)
    property bool showDebugCommandBar: true

    Component.onCompleted: {
        console.log("Initializing")
        NavigationControl.init(flipable,controlContainer, contentContainer, statusBarContainer)
    }

    onClosing: {
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
                NumberAnimation { target: rotation; property: "angle"; duration: 500 }
            }
        }
    }

    // Debug commands for simulation
    Rectangle {
        id: commandBar
        visible: showDebugCommandBar
        width: parent.width
        height: 44
        color: "lightgrey"
        anchors {
            bottom: parent.bottom
        }

        // Simulate Platform events
        GridLayout {
            anchors.centerIn: parent
            Text {
                id: commandLabel
                text: qsTr("Commands")
            }
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

            // UI events
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
                text: "Toggle Content/Control"
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
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
        Button {
            text: "X"
            height: 30
            width: height
            onClicked: showDebugCommandBar = false
            anchors {
                right: commandBar.right
            }
        }
    }

    Button {
        text: "^"
        height: 30
        width: height
        visible: !showDebugCommandBar
        onClicked: showDebugCommandBar = true
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
    }

    // Listen into Core Interface which gives us the platform changes
    Connections {
        target: coreInterface
        onPlatformIDChanged: {
            console.log("Main: PlatformIDChanged to ", id)
            // Map out UUID->platform name
            var uuid_map = {
                //"P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af" : "usb-pd" assume motor for now
                "P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af" : "motor-vortex",
                "P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671" : "bubu",
                "motorvortex1" : "motor-vortex"
            }

            // Send update to NavigationControl
            if (uuid_map.hasOwnProperty(id)){
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
