import QtQuick 2.9
import QtQuick.Controls 2.0

Item {
    id: root

    property alias pressed: switchRoot.pressed
    property alias down: switchRoot.down
    property alias checked: switchRoot.checked

    property real switchWidth: 52
    property color textColor: "black"
    property color handleColor: "white"
    property color grooveFillColor: "#0cf"
    property string label: "fgdfgd"
    property string checkedLabel: ""
    property string uncheckedLabel: ""
    property bool labelsInside: false
    property real fontSize: 10

    implicitHeight: childrenRect.height
    implicitWidth: childrenRect.width

    Text {
        id: uncheckedLabelText
        visible: uncheckedLabel === "" ? false : !root.labelsInside
        text: uncheckedLabel
        font.pixelSize: root.fontSize
        anchors {
            left: parent.left
            verticalCenter: switchRoot.verticalCenter
        }
    }

    Text {
        id: checkedLabelText
        visible: uncheckedLabel === "" ? false : !root.labelsInside
        text: checkedLabel
        font.pixelSize: root.fontSize
        anchors {
            left: switchRoot.right
            verticalCenter: switchRoot.verticalCenter
        }
    }

    Switch {
        id: switchRoot
        Rectangle {
            color: "blue"
            opacity: .15
            anchors {
                fill: parent
            }
            z:20
            Component.onCompleted: console.log("height: " + height + "\n     width:  " + width)

        }

        anchors {
            left: uncheckedLabelText.right
        }
        width: groove.width
        height: groove.height
        padding: 0

        indicator: Rectangle {
            id: groove
            width: root.switchWidth
            implicitHeight: 26
            y: parent.height / 2 - height / 2
            radius: 13
            color: "#ddd"

            Text {
                id: uncheckedText
                visible: uncheckedLabel === "" ? false : root.labelsInside
                color: "white"
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 5
                }
                font.pixelSize: root.fontSize
                text: qsTr("Off")
            }

            Rectangle {
                id: grooveFill
                visible: width === handle.width ? false : true
                width: ((switchRoot.visualPosition * parent.width) + (1-switchRoot.visualPosition) * handle.width)
                height: parent.height
                color: "#0cf"
                radius: height/2

                Behavior on width {
                    enabled: switchRoot.pressed ? false : true
                    NumberAnimation { duration: 100 }
                }

                Text {
                    id: checkedText
                    visible: checkedLabel === "" ? false : root.labelsInside
                    color: "white"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 5
                    }
                    font.pixelSize: root.fontSize
                    text: qsTr("On")
                }
            }

            Rectangle {
                id: handle
                x: ((switchRoot.visualPosition * parent.width) + (1-switchRoot.visualPosition) * width) - width
                width: 26
                height: 26
                radius: 13
                color: root.down ? "#eee" : "#fff"
                border.color: root.checked? "#0ad" : "#999"

                Behavior on x {
                    enabled: switchRoot.pressed ? false : true
                    NumberAnimation { duration: 100 }
                }
            }
        }

        //    contentItem: Text {
        //        width: contentWidth
        //        visible: root.label === "" ? false : true
        //        text: root.label
        //        font: root.font
        //        opacity: enabled ? 1.0 : 0.3
        //        color: root.textColor
        //        verticalAlignment: Text.AlignVCenter
        //        leftPadding: root.label === "" ? 0 : root.indicator.width + root.spacing
        //    }
    }
}
