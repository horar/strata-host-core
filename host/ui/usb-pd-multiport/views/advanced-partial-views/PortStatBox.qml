import QtQuick 2.9
import "qrc:/sgwidgets"

Rectangle {
    id: root
    color: "#2eb457"
    height: 30
    width: parent.width
    clip: true

    property string label: "VOLTAGE"
    property string value: "20 V"
    property string icon: "/views/images/icon-voltage.svg"

    Text {
        id: voltage
        color: "white"
        text: "<b>" + root.label + "</b>"
        anchors {
            top: parent.top
            topMargin: 5
            left: parent.left
            leftMargin: 5
        }
        font {
            pixelSize: 9
        }
    }

    Text {
        id: voltageValue
        color: "white"
        text: "<b>" + root.value + "</b>"
        anchors {
            bottom: parent.bottom
            bottomMargin: 0
            right: parent.right
            rightMargin: 5
        }
        font {
            pixelSize: 25
        }
    }

    Image {
        id: voltageIcon
        source: root.icon
        opacity: 0.25
        height: 40
        width: height
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10
        }
    }
}
