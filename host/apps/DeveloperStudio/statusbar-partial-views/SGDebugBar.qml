import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import "qrc:/js/navigation_control.js" as NavigationControl

Item {
    id: root

    Rectangle {
        id: commandBar
        visible: false
        width: parent.width
        height: flow.height
        color: "lightgrey"
        anchors {
            bottom: parent.bottom
        }

        // Buttons for event simulation
        Flow {
            id: flow
            spacing: 5
            anchors {
                left: commandBar.left
                right: commandBar.right
            }
            layoutDirection: Qt.RightToLeft

            Button {
                text: "BuBU Interface"
                onClicked: {
                    var data = { class_id: "P2.2018.1.1.0"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            Button {
                text: "Motor Vortex"
                onClicked: {
                    var data = { class_id: "204"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            Button {
                text: "Template UI"
                onClicked: {
                    var data = { class_id: "template"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            Button {
                text: "USB-PD 4 Ports"
                onClicked: {
                    var data = { class_id: "203"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            Button {
                text: "Logic gate"
                onClicked: {
                    var data = { class_id: "101"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            Button {
                text: "Linear-VR"
                onClicked: {
                    var data = { class_id: "206"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            Button {
                text: "15A-switcher"
                onClicked: {
                    var data = { class_id: "219"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            Button {
                text: "5A-switcher"
                onClicked: {
                    var data = { class_id: "208"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            Button {
                text: "USB Hub"
                onClicked: {
                    var data = { class_id: "218"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }
            Button {
                text: "SmartSpeaker"
                onClicked: {
                    var data = { class_id: "225"}
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
                text: "Reset Window"
                onClicked: {
                    mainWindow.height = 900
                    mainWindow.width = 1200
                }
            }

            Button {
                text: "Login as guest"
                onClicked: {
                    var data = { user_id: "Guest" }
                    NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
                }
            }

            SGLogLevelSelector {
            }
        }
    }


    MouseArea {
        id: debugCloser
        visible: commandBar.visible
        anchors {
            left: commandBar.left
            right: commandBar.right
            bottom: commandBar.top
            bottomMargin: 40
            top: parent.top
        }
        hoverEnabled: true
        onContainsMouseChanged: {
            if (containsMouse) {
                commandBar.visible = false
            }
        }
    }

    Rectangle {
        id: debugButton
        enabled: false
        height: 30
        width: 70
        visible: debugMouse.containsMouse
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        color: "#666"

        Text {
            text: qsTr("DEBUG")
            anchors.centerIn: debugButton
            color: "white"
        }
    }

    MouseArea {
        id: debugMouse
        visible: !commandBar.visible
        anchors {
            fill: debugButton
        }
        hoverEnabled: !commandBar.visible
        onClicked: {
            commandBar.visible = true
        }
    }
}
