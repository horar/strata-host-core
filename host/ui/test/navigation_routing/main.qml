import QtQuick 2.10
import QtQuick.Window 2.10
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "navigationControl.js" as NavigationControl

Window {

    id: mainWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Navigation Framework")

    Item {

        id: controlContainer
        height: 0.7 * parent.height
        width: parent.width

        Component.onCompleted: {
            console.log("Initializing")
            NavigationControl.init(controlContainer)
        }
    }

    // Debug commands for simulation
    Rectangle {
        id: commandBar
        width: parent.width
        anchors.top: controlContainer.bottom
        anchors.bottom: parent.bottom

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
                    var data = { platform_name: "USB-PD Control"}
                    NavigationControl.updateState(NavigationControl.events.PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "BuBU Interface"
                onClicked: {
                    var data = { platform_name: "BuBu Interface"}
                    NavigationControl.updateState(NavigationControl.events.PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "Advanced"
                onClicked: {
                   var data = { platform_name: "USB-PD Advanced Control"}
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


        }
    }

}
