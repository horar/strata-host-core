import QtQuick 2.9
import "qrc:/sgwidgets"
import "qrc:/views/images"
import "qrc:/views/partial-views"

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

    onWidthChanged: {console.log(parent.width / parent.height < initialAspectRatio)}

    Image {
        id: name
        anchors {
            fill: root
        }
        source: "images/basic-background.png"
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
            color: "white"
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
            color: "white"
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

        SGLayoutDebug {
            visible: debugLayout
        }
    }
}
