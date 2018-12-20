import QtQuick 2.9
import "qrc:/views/usb-pd-multiport/sgwidgets"

Rectangle {
    id: root
    height: 49
    width: parent.width
    clip: true
    color: "#f4f4f4"

    property string label: "VOLTAGE"
    property string value: "20"
    property string unit: "V"
    property string icon: "../images/icon-voltage.svg"
    property real labelSize: 9
    property real valueSize: 27
    property real unitSize: 12
    property real bottomMargin: 0
    property color textColor: "#555"
    property color portColor: "#2eb457"

    Item {
        id: labelBar
        width: parent.width
        height: labelText.height + 4

        Text {
            id: labelText
            color: "#777"
            text: "<b>" + root.label + "</b>"
            anchors {
                top: labelBar.top
                topMargin: 2
                left: labelBar.left
                leftMargin: 3
            }
            font {
                pixelSize: root.labelSize
            }
        }

        Rectangle {
            id: underline
            color: "#ccc"
            height: 1
            width: labelBar.width
            anchors {
                bottom: labelBar.bottom
            }
        }
    }

    Text {
        id: valueText
        color: textColor
        text: "<b>" + root.value + "</b>"
        anchors {
            bottom: root.bottom
            bottomMargin: root.bottomMargin
            right:unitText.left
            rightMargin:0
        }
        font {
            pixelSize: root.valueSize
        }
    }

    Text {
        id: unitText
        color: "#aaa"
        text: root.unit
        anchors {
            bottom: valueText.bottom
            bottomMargin: 3
            right:root.right
            rightMargin:5
        }
        font {
            pixelSize: root.unitSize
        }
    }

}
