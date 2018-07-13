import QtQuick 2.9
import "qrc:/sgwidgets"

Column {
    id: root
    anchors {
        //
    }
    spacing: 5

    Rectangle {
        id: voltageContainer
        color: "#2eb457"
        height: 40
        width: parent.width
        clip: true

        Text {
            id: voltage
            color: "white"
            text: qsTr("VOLTAGE")
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                leftMargin: 5
            }
            font {
                pixelSize: 7
            }
        }

        Text {
            id: voltageValue
            color: "white"
            text: qsTr("<b>20 V</b>")
            anchors {
                bottom: parent.bottom
                bottomMargin: 0
                left: parent.left
                leftMargin: 5
            }
            font {
                pixelSize: 25
            }
        }

        Image {
            id: voltageIcon
            source: "/views/images/icon-voltage.svg"
            opacity: 0.2
            height: 60
            width: 60
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }
        }
    }

    Rectangle {
        id: otherContainer
        color: voltageContainer.color
        height: voltageContainer.height
        width: voltageContainer.width
        clip: true

        Text {
            id: other
            color: "white"
            text: qsTr("VOLTAGE")
            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                leftMargin: 5
            }
            font {
                pixelSize: voltage.font.pixelSize
            }
        }

        Text {
            id: otherValue
            color: "white"
            text: qsTr("<b>20 V</b>")
            anchors {
                bottom: parent.bottom
                bottomMargin: voltageValue.anchors.bottomMargin
                left: parent.left
                leftMargin: 5
            }
            font {
                pixelSize: voltageValue.font.pixelSize
            }
        }

        Image {
            id: otherIcon
            source: "/views/images/icon-voltage.svg"
            opacity: 0.2
            height: 60
            width: 60
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }
        }
    }
}
