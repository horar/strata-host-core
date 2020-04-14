import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

// This is an example debug menu that shows how you can test your UI by injecting
// spoofed notifications to simulate a connected platform board.
//
// It is for development and should be removed from finalized UI's.

Rectangle {
    id: root
    height: 200
    width: 200
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
                    text: "Debug"
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
                id: addNode
                text: "add node"

                property int clickCount: 1  //node 1 is always the provisioner, so we'll start with 2
                onClicked: {
                    var colors = ["#ff00ff", "#ff4500","#ffff00", "#7cfc00", "#00ff7f","#ffc0cb","#9370db"];
                    addNode.clickCount++;

                    CorePlatformInterface.data_source_handler('{
                                "value":"node_added",
                                "payload":{
                                    "index": '+clickCount+',
                                    "color": "'+colors[clickCount-1]+'"
                                }
                        }')

                }
            }

            Button {
                id: consoleMessage
                text: "console"

                onClicked: {

                    CorePlatformInterface.data_source_handler('{
                                "value":"msg_cli",
                                "payload":{
                                    "msg": "console message"
                                }
                        }')

                }
            }



        Button {
            id: tempSensor
            text: "temperature"

            onClicked: {

                CorePlatformInterface.data_source_handler('{
                    "value":"sensor_status",
                    "payload":{
                         "uaddr": 2,
                         "sensor_type": "temperature",
                         "data":  100
                    }
                    }')

            }
        }
        Button {
            id: batterySensor
            text: "battery"

            onClicked: {

                CorePlatformInterface.data_source_handler('{
                    "value":"battery_status",
                    "payload":{
                        "uaddr":3,
                        "battery_level":55,
                        "battery_voltage":3.66,
                        "plugged_in":true,
                        "battery_state":"charging"
                    }
                    }')

            }
        }



//            Button {
//                id: motorRunningFalse
//                text: "Send motor_running_notification, 'running': false"
//                onClicked: {
//                    CorePlatformInterface.data_source_handler('{
//                                "value":"motor_running_notification",
//                                "payload":{
//                                         "running": false
//                                }
//                        }')
//                }
//            }

//            Button {
//                id: motorSpeed
//                text: "Send motor_speed_notification, 'speed': random"
//                onClicked: {
//                    CorePlatformInterface.data_source_handler('{
//                                "value":"motor_speed_notification",
//                                "payload":{
//                                         "speed": ' + (Math.random()*100).toFixed(2) + '
//                                }
//                        }')
//                }
//            }
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
