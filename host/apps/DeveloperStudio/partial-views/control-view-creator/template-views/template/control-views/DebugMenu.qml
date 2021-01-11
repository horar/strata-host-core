import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

// This is an example debug menu that shows how you can test your UI by injecting
// spoofed notifications to simulate a connected platform board.
//
// It is for development and should be removed from finalized UI's.

Rectangle {
    id: root
    height: 200
    width: 350
    border {
        width: 1
        color: "#fff"
    }

    // Re-usable notification template
    property var notification: {
        "value": "",
        "payload": {},
        "sendAndReset": function () {
            this.send()
            this.reset()
        },
        "send": function () {
            platformInterface.injectDebugNotification(this)
        },
        "reset": function () {
            this.value = ""
            this.payload = {}
        }
    }

    Item {
        anchors {
            fill: root
            margins: 1
        }
        clip: true

        Column {
            width: parent.width
            spacing: 1

            Rectangle {
                id: header
                color: "#eee"
                width: parent.width
                height: 40

                Text {
                    text: "Debug (inject fake platform notifications):"
                    anchors {
                        verticalCenter: header.verticalCenter
                        left: header.left
                        leftMargin: 15
                    }
                }

                Button {
                    text: "X"
                    height: 30
                    width: height
                    onClicked: root.visible = false
                    anchors {
                        right: header.right
                        verticalCenter: header.verticalCenter
                    }
                }
            }

            Button {
                id: motorRunningTrue
                text: "Send motor_running_notification, 'running': true"
                onClicked: {
                    notification.value = "motor_running_notification"
                    notification.payload.running = true
                    notification.sendAndReset()
                }
            }

            Button {
                id: motorRunningFalse
                text: "Send motor_running_notification, 'running': false"
                onClicked: {
                    notification.value = "motor_running_notification"
                    notification.payload.running = false
                    notification.sendAndReset()
                }
            }

            Button {
                id: motorSpeed
                text: "Send motor_speed_notification, 'speed': random"
                onClicked: {
                    notification.value = "motor_speed_notification"
                    notification.payload.speed = (Math.random()*100).toFixed(2)
                    notification.sendAndReset()
                }
            }
        }
    }

    Rectangle {
        id: shadow
        anchors.fill: root
        visible: false
    }

    DropShadow {
        anchors.fill: shadow
        radius: 15.0
        samples: 30
        source: shadow
        z: -1
    }
}
