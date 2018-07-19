import QtQuick 2.9
import "qrc:/sgwidgets"
import "qrc:/views/images"
import "qrc:/views/basic-partial-views"

Item {
    id: root

    property bool debugLayout: false
    property real ratioCalc: root.width / 1200

    anchors {
//        fill: parent
        horizontalCenter: parent.horizontalCenter
    }

    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Image {
        id: name
        anchors {
            fill: root
        }
        source: "images/basic-background.png"
    }

    PlugAnimation {
        id: port1Animation
        x: 748 * ratioCalc
        y: 83 * ratioCalc
    }

    PlugAnimation {
        id: port2Animation
        x: 748 * ratioCalc
        y: 275 * ratioCalc
    }

    PlugAnimation {
        id: port3Animation
        x: 748 * ratioCalc
        y: 467 * ratioCalc
    }

    PlugAnimation {
        id: port4Animation
        x: 748 * ratioCalc
        y: 659 * ratioCalc
    }

    Item {
        id: inputColumn
        width: 310 * ratioCalc
        height: root.height
        anchors {
            left: root.left
            leftMargin: 80 * ratioCalc
        }

        Rectangle {
            id: combinedPortStats
            color: "#eee"
            anchors {
                top: inputColumn.top
                topMargin: 55 * ratioCalc
                left: inputColumn.left
                right: inputColumn.right
            }
            height: 300 * ratioCalc

            Text {
                text: "Combined port stats go here"
                anchors.centerIn: parent
            }
        }

        Rectangle {
            id: inputConversionStats
            color: combinedPortStats.color
            anchors {
                top: combinedPortStats.bottom
                topMargin: 20 * ratioCalc
                left: inputColumn.left
                right: inputColumn.right
            }
            height: 428 * ratioCalc

            Text {
                text: "Input power conversion info goes here"
                anchors.centerIn: parent
            }
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }

    Item {
        id: portColumn
        width: 330 * ratioCalc
        height: root.height
        anchors {
            left: inputColumn.right
            leftMargin: 20 * ratioCalc
        }

        PortInfo {
            id: portInfo1
            height: 172 * ratioCalc
            anchors {
                top: portColumn.top
                topMargin: 55 * ratioCalc
                left: portColumn.left
                right: portColumn.right
            }
            portNumber: 1
        }

        PortInfo {
            id: portInfo2
            height: portInfo1.height
            anchors {
                top: portInfo1.bottom
                topMargin: 20 * ratioCalc
                left: portColumn.left
                right: portColumn.right
            }
            portNumber: 2
        }

        PortInfo {
            id: portInfo3
            height: portInfo1.height
            anchors {
                top: portInfo2.bottom
                topMargin: 20 * ratioCalc
                left: portColumn.left
                right: portColumn.right
            }
            portNumber: 3
        }

        PortInfo {
            id: portInfo4
            height: portInfo1.height
            anchors {
                top: portInfo3.bottom
                topMargin: 20 * ratioCalc
                left: portColumn.left
                right: portColumn.right
            }
            portNumber: 4
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }

    Item {
        id: deviceColumn
        width: 280 * ratioCalc
        height: root.height
        anchors {
            left: portColumn.right
            leftMargin: 160 * ratioCalc
        }

        Column {
            anchors {
                top: parent.top
                topMargin: 55 * ratioCalc
                right: parent.right
            }

            width: parent.width - (100 * ratioCalc)
            spacing: 20 * ratioCalc

            DeviceInfo {
                height: portInfo1.height
                width: parent.width

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    onClicked: {
                        if (!port1Animation.pluggedIn) {
                            port1Animation.source = "images/cord.gif"
                            port1Animation.currentFrame = 0
                            port1Animation.playing = true
                            port1Animation.pluggedIn = !port1Animation.pluggedIn
                        } else {
                            port1Animation.source = "images/cordReverse.gif"
                            port1Animation.currentFrame = 0
                            port1Animation.playing = true
                            port1Animation.pluggedIn = !port1Animation.pluggedIn
                        }
                    }
                }
            }

            DeviceInfo {
                height: portInfo1.height
                width: parent.width

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    onClicked: {
                        if (!port2Animation.pluggedIn) {
                            port2Animation.source = "images/cord.gif"
                            port2Animation.currentFrame = 0
                            port2Animation.playing = true
                            port2Animation.pluggedIn = !port2Animation.pluggedIn
                        } else {
                            port2Animation.source = "images/cordReverse.gif"
                            port2Animation.currentFrame = 0
                            port2Animation.playing = true
                            port2Animation.pluggedIn = !port2Animation.pluggedIn
                        }
                    }
                }
            }

            DeviceInfo {
                height: portInfo1.height
                width: parent.width

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    onClicked: {
                        if (!port3Animation.pluggedIn) {
                            port3Animation.source = "images/cord.gif"
                            port3Animation.currentFrame = 0
                            port3Animation.playing = true
                            port3Animation.pluggedIn = !port3Animation.pluggedIn
                        } else {
                            port3Animation.source = "images/cordReverse.gif"
                            port3Animation.currentFrame = 0
                            port3Animation.playing = true
                            port3Animation.pluggedIn = !port3Animation.pluggedIn
                        }
                    }
                }
            }

            DeviceInfo {
                height: portInfo1.height
                width: parent.width

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    onClicked: {
                        if (!port4Animation.pluggedIn) {
                            port4Animation.source = "images/cord.gif"
                            port4Animation.currentFrame = 0
                            port4Animation.playing = true
                            port4Animation.pluggedIn = !port4Animation.pluggedIn
                        } else {
                            port4Animation.source = "images/cordReverse.gif"
                            port4Animation.currentFrame = 0
                            port4Animation.playing = true
                            port4Animation.pluggedIn = !port4Animation.pluggedIn
                        }
                    }
                }
            }
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }
}
