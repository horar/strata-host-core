import QtQuick 2.9
import "../../sgwidgets"

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
    property real valueSize: 23
    property real unitSize: 12
    property real bottomMargin: 0
    property color textColor: "#555"
    property color portColor: "#2eb457"

    Image {
        id: iconImage
        source: root.icon
        opacity: 0.05
        height: root.height * 0.9
        width: height
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: root.height * 0.05
        }
        mipmap: true
    }

    Item {
        id: labelBar
        width: parent.width
        height: labelText.height + 4

        Text {
            id: labelText
            color: "#777"
            text: "<b>" + root.label + "</b>"
            anchors {
                top: parent.top
                topMargin: 2
                left: parent.left
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
            width: labelText.width + 6
            anchors {
                bottom: parent.bottom
            }
        }
    }

    Text {
        id: valueText
        color: textColor
        text: "<b>" + root.value + "</b>"
        anchors {
            bottom: parent.bottom
            bottomMargin: root.bottomMargin
            right: unitText.left
            rightMargin: 5
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
            bottomMargin: 4
            right: iconImage.left
            rightMargin: -5
        }
        font {
            pixelSize: root.unitSize
        }
    }
}
