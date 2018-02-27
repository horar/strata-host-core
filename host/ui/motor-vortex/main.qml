import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "js/navigation_control.js" as NavigationControl

Window {

    id: mainWindow
    visible: true
    width: 1200
    height: 900
    title: qsTr("Encore Design Suite -- Motor Vortex Demo")

    Flipable {
        id: flipable
        height: 0.85 * parent.height
        width: parent.width

        property bool flipped: false

        front: SGControlContainer{ id: controlContainer}
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
            NumberAnimation { target: rotation; property: "angle"; duration: 2000 }
        }
        Component.onCompleted: {
            console.log("Initializing")
            NavigationControl.init(controlContainer, contentContainer)
        }

    }

    // Debug commands for simulation
    Rectangle {
        id: commandBar
        width: parent.width
        anchors.top: flipable.bottom
        anchors.bottom: parent.bottom
        color: "lightgrey"
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
                    NavigationControl.updateState(NavigationControl.events.PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "BuBU Interface"
                onClicked: {
                    var data = { platform_name: "bubu"}
                    NavigationControl.updateState(NavigationControl.events.PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "Motor Vortex"
                onClicked: {
                   var data = { platform_name: "motor-vortex"}
                    NavigationControl.updateState(NavigationControl.events.PLATFORM_CONNECTED_EVENT, data)
                }
            }

        // UI events
            Button {
                text: "Disconnect"
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, null)
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
                flipable.flipped = !flipable.flipped
                }
            }
            }


        }
}
