import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGSwitch Demo")

    SGSwitch {
        id: sgSwitch
        //
    }

    Switch {
        id: plainSwitch
        anchors.top: sgSwitch.bottom
    }

    Switch {
        id: root
        padding: 0
        anchors.top: plainSwitch.bottom
        property color textColor: "black"
        property bool vertical: false

//        onPressAndHold: {console.log("test")}
        onCheckedChanged: {console.log(checked)}

        indicator: Rectangle {
//            rotation: vertical ? -90 : 0
            id: groove
            implicitWidth: 52
            implicitHeight: 26
            x: root.leftPadding
            y: parent.height / 2 - height / 2
            radius: 13
            color: "#ddd"
//            border.color: "#cccccc"

            Text {
                id: offText
                color: "white"
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 5
                }
                font.pixelSize: 10
                text: qsTr("Off")
            }

            Rectangle {
                id: grooveFill
                visible: width === handle.width ? false : true
                width: ((root.visualPosition * parent.width) + (1-root.visualPosition) * handle.width) //- 0.01 * parent.width
                height: parent.height
                color: "#0cf"
                radius: height/2

                Behavior on width { NumberAnimation { duration: 100 } }

                Text {
                    id: onText
                    color: "white"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 5
                    }
                    font.pixelSize: 10
                    text: qsTr("On")
                }
            }

            Rectangle {
                id: handle
                x: ((root.visualPosition * parent.width) + (1-root.visualPosition) * width) - width
                width: 26
                height: 26
                radius: 13
                color: root.down ? "#eee" : "#fff"
                border.color: root.checked? "#0ad" : "#999"

                Behavior on x { NumberAnimation { duration: 100 } }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    drag {
                        target: handle
                        axis: Drag.XAxis
                    }
                }
            }
        }

        contentItem: Text {
            text: root.text
            font: root.font
            opacity: enabled ? 1.0 : 0.3
            color: root.textColor
            verticalAlignment: Text.AlignVCenter
            leftPadding: root.indicator.width + root.spacing
        }
    }
}
