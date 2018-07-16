import QtQuick 2.9

Item {
    id: root

    property bool portConnected: true
    property int portNum: 1
    property color statBoxColor: "#2eb457"

    implicitWidth: 175

    Text {
        id: portNumber
        text: "<b>Port " + root.portNum + ":</b>"
    }

    Item {
        id: connectionContainer
        visible: !root.portConnected

        anchors {
            top: portNumber.bottom
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
                verticalCenterOffset: -10
            }
        }

        Text {
            id: connectionText
            color: "red"
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
        width: root.width
        spacing: 2
        anchors {
            top: portNumber.bottom
        }

        property real sbHeight: 30
        property real sbValueSize: 12
        property real sbLabelSize: 7

        PortStatBox {
            label: "PROFILE"
            value: "20 V"
            icon: "/views/images/icon-voltage.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.statBoxColor
        }

        PortStatBox {
            label: "MAX CAPACITY"
            value: "100 W"
            icon: "/views/images/icon-max.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.statBoxColor
        }

        PortStatBox {
            label: "POWER IN"
            value: "9 W"
            icon: "/views/images/icon-voltage.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.statBoxColor
        }

        PortStatBox {
            label: "POWER OUT"
            value: "7.8 W"
            icon: "/views/images/icon-voltage.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.statBoxColor
        }

        PortStatBox {
            label: "VOLTAGE OUT"
            value: "20.4 V"
            icon: "/views/images/icon-voltage.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.statBoxColor
        }

        PortStatBox {
            label: "TEMPERATURE"
            value: "36 °C"
            icon: "/views/images/icon-temp.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.statBoxColor
        }

        PortStatBox {
            label: "EFFICIENCY"
            value: "92 %"
            icon: "/views/images/icon-efficiency.svg"
            height: column1.sbHeight
            valueSize: column1.sbValueSize
            labelSize: column1.sbLabelSize
            color: root.statBoxColor
        }
    }
}
