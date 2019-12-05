import QtQuick 2.9
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Rectangle {
    id: root
    height: 200
    width: 350
    border {
        width: 1
        color: "#fff"
    }

    Item {
        anchors {
            fill: root
            margins: 1
        }
        clip: true

        Column {
            width: parent.width

            Rectangle {
                id: header
                color: "#eee"
                width: parent.width
                height: 40

                Text {
                    text: "Debug Buttons (spoof platform notifications):"
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
                    }
                }
            }

            Button {
                id: motorRunningTrue
                text: "Send motor_running_notification, 'running': true"
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"motor_running_notification",
                                "payload":{
                                         "running": true
                                }
                        }')
                }
            }

            Button {
                id: motorRunningFalse
                text: "Send motor_running_notification, 'running': false"
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"motor_running_notification",
                                "payload":{
                                         "running": false
                                }
                        }')
                }
            }

            Button {
                id: motorSpeed
                text: "Send motor_speed_notification, 'speed': random"
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"motor_speed_notification",
                                "payload":{
                                         "speed": ' + (Math.random()*100).toFixed(2) + '
                                }
                        }')
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
