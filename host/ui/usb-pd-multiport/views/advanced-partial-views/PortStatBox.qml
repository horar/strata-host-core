import QtQuick 2.9
import "qrc:/sgwidgets"

Rectangle {
    id: root
    color: "#2eb457"
    height: 49
    width: parent.width
    clip: true

    property string label: "VOLTAGE"
    property string value: "20 V"
    property string icon: "/views/images/icon-voltage.svg"
    property real labelSize: 9
    property real valueSize: 30
    property real bottomMargin: 0
    property color textColor: "white"

    Text {
        id: voltage
        color: textColor
        text: "<b>" + root.label + "</b>"
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 5
        }
        font {
            pixelSize: root.labelSize
        }
    }

    Text {
        id: voltageValue
        color: textColor
        text: "<b>" + root.value + "</b>"
        anchors {
            bottom: parent.bottom
            bottomMargin: root.bottomMargin
            left: parent.left
            leftMargin: 5
        }
        font {
            pixelSize: root.valueSize
        }
    }

    Image {
        id: voltageIcon
        source: root.icon
        opacity: 0.2
        height: root.height * 1.5
        width: height
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 5
        }
    }
}
