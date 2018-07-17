import QtQuick 2.9
import "qrc:/sgwidgets"

Item {
    id: root

    property bool portConnected: true
    property int portNum: 1
    property color portColor: "#2eb457"

    implicitWidth: 175

    Text {
        id: portNumber
        text: "<b>Port " + root.portNum + ":</b>"
        font {
            pixelSize: 15
        }
        color: portConnected ? "black" : "#ccc"
    }

    SGDivider {
        id: div1
        color: "#ccc"
        anchors {
            top: portNumber.bottom
            topMargin: 2
        }
    }

    Item {
        id: connectionContainer
        visible: !root.portConnected

        anchors {
            top: div1.bottom
            topMargin: 8
            bottom: root.bottom
            right: root.right
            left: root.left
        }

        Image {
            id: connectionIcon
            source: "/views/images/icon-usb-disconnected.svg"
            height: root.height * 0.5
            width: height * 0.6925
            anchors {
                centerIn: parent
                verticalCenterOffset: -connectionText.font.pixelSize / 2

            }
        }

        Text {
            id: connectionText
            color: "#ccc"
            text: "<b>Port Disconnected</b>"
            anchors {
                top: connectionIcon.bottom
                topMargin: 5
                horizontalCenter: connectionIcon.horizontalCenter
            }
        }
    }

    Column {
        id: column1
        visible: root.portConnected
        width: root.width / 2 - 2
        spacing: 2
        anchors {
            top: div1.bottom
            topMargin: 8
        }

        property real sbHeight: 50
        property real sbValueSize: 24
        property real sbLabelSize: 9
        property real bottomMargin: 4

        PortStatBox {
            label: "PROFILE"
            value: "20 V"
            icon: "/views/images/icon-voltage.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.portColor
            bottomMargin: column1.bottomMargin

        }

        PortStatBox {
            label: "MAX CAPACITY"
            value: "100 W"
            icon: "/views/images/icon-max.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.portColor
            bottomMargin: column1.bottomMargin
        }

        PortStatBox {
            label: "POWER IN"
            value: "9 W"
            icon: "/views/images/icon-voltage.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.portColor
            bottomMargin: column1.bottomMargin
        }

        PortStatBox {
            label: "POWER OUT"
            value: "7.8 W"
            icon: "/views/images/icon-voltage.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.portColor
            bottomMargin: column1.bottomMargin
        }
    }

    Column {
        id: column2
        visible: root.portConnected
        width: root.width / 2 - 2
        spacing: 2
        anchors {
            left: column1.right
            leftMargin: 2
            top: column1.top
        }

        PortStatBox {
            label: "VOLTAGE OUT"
            value: "20.4 V"
            icon: "/views/images/icon-voltage.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.portColor
            bottomMargin: column1.bottomMargin
        }

        PortStatBox {
            label: "TEMPERATURE"
            value: "36 °C"
            icon: "/views/images/icon-temp.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.portColor
            bottomMargin: column1.bottomMargin
        }

        PortStatBox {
            label: "EFFICIENCY"
            value: "92 %"
            icon: "/views/images/icon-efficiency.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.portColor
            bottomMargin: column1.bottomMargin
        }
    }
}
