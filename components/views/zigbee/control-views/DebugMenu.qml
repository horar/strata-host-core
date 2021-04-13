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

            Row{
                Button {
                    id: lightsOn
                    text: "light on"
                    onClicked: {
                        CorePlatformInterface.data_source_handler('{
                                "value":"toggle_light_notification",
                                "payload":{
                                         "value": "on"
                                }
                        }')
                    }
                }

                Button {
                    id: lightsOff
                    text: "light off"
                    onClicked: {
                        CorePlatformInterface.data_source_handler('{
                                "value":"toggle_light_notification",
                                "payload":{
                                         "value": "off"
                                }
                        }')
                    }
                }
            }

            Row{
                Button {
                    id: doorOpen
                    text: "door open"
                    onClicked: {
                        CorePlatformInterface.data_source_handler('{
                                "value":"toggle_door_notification",
                                "payload":{
                                         "value": "open"
                                }
                        }')
                    }
                }

                Button {
                    id: doorClosed
                    text: "door closed"
                    onClicked: {
                        CorePlatformInterface.data_source_handler('{
                                "value":"toggle_door_notification",
                                "payload":{
                                         "value": "closed"
                                }
                        }')
                    }
                }
            }
            Row{
            Button {
                id: blueColor
                text: "blue"
                width:75
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"room_color_notification",
                                "payload":{
                                         "color": "blue"
                                }
                        }')
                }
            }
            Button {
                id: greenColor
                text: "green"
                width:75
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"room_color_notification",
                                "payload":{
                                         "color": "green"
                                }
                        }')
                }
            }
            Button {
                id: purpleColor
                text: "purple"
                width:75
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"room_color_notification",
                                "payload":{
                                         "color": "purple"
                                }
                        }')
                }
            }
            Button {
                id: redColor
                text: "red"
                width:75
                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                                "value":"room_color_notification",
                                "payload":{
                                         "color": "red"
                                }
                        }')
                }
            }
            }//row
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
