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

    AnimatedImage {
        id: animation
        property bool pluggedIn: false
        source: "images/cord.gif"
        height: 81 * ratioCalc
        width: 350 * ratioCalc
        playing: false
        x: 748 * ratioCalc
        y: 83 * ratioCalc
        onCurrentFrameChanged: {
            if (currentFrame === frameCount-1) {
                playing = false
            }
        }

        Rectangle {
            id: coverup1
            width: 8 * ratioCalc
            height: 50 * ratioCalc
            color: "#bab9bc"
            anchors {
                left: animation.left
                leftMargin: 10 * ratioCalc
                bottom: animation.bottom
                bottomMargin: 0
            }

            Rectangle {
                color: "black"
                opacity: .25
                width: 2 * ratioCalc
                height: 23 * ratioCalc
                anchors {
                    left: parent.right
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 2
                }
            }

            Rectangle {
                id: coverup2
                width: 9 * ratioCalc
                height: 50 * ratioCalc
                color: "#d1d1d4"
                anchors {
                    right: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }
        }
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
            spacing: 20

            DeviceInfo {
                height: portInfo1.height
                width: parent.width
                MouseArea {
                    anchors {
                        fill: parent
                    }
                    onClicked: {
                        if (!animation.pluggedIn) {
                            animation.source = "images/cord.gif"
                            animation.currentFrame = 0
                            animation.playing = true
                            animation.pluggedIn = !animation.pluggedIn
                        } else {
                            animation.source = "images/cordReverse.gif"
                            animation.currentFrame = 0
                            animation.playing = true
                            animation.pluggedIn = !animation.pluggedIn
                        }


                    }
                }
            }

            DeviceInfo {
                height: portInfo1.height
                width: parent.width
            }

            DeviceInfo {
                height: portInfo1.height
                width: parent.width
            }

            DeviceInfo {
                height: portInfo1.height
                width: parent.width
            }
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }
}
