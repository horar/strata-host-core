import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Strata Client")

    Button {
        id: broadcastBtn
        x: 32
        y: 125
        width: 289
        height: 64
        text: qsTr("Broadcast")
        font.pointSize: 21
        clip: false
        checkable: false
        checked: false
        display: AbstractButton.TextBesideIcon

        Connections {
            target: broadcastBtn
            onClicked: client.broadcastDatagram()
        }

    }

    Label {
        id: labelPort
        x: 35
        y: 61
        width: 53
        height: 39
        text: qsTr("Port")
        font.pointSize: 21
        styleColor: "#e36464"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    TextField {
        id: portField
        x: 111
        y: 58
        width: 128
        height: 46
        text: client.getPort()
        placeholderText: "Enter broadcasting port"
    }

    Button {
        id: setPortBtn
        x: 250
        y: 61
        width: 71
        height: 40
        text: qsTr("Set")

        Connections {
            target: setPortBtn
            onClicked: client.setPort(portField.text)
        }
    }

    Label {
        id: statusLabel
        x: 515
        y: 417
        width: 119
        height: 54
        text: client.connectionStatus
    }

    Button {
        id: disconnectBtn
        x: 35
        y: 220
        text: qsTr("Disconnect")
        enabled: client.connectionStatus == "connected"

        Connections {
            target: disconnectBtn
            onClicked: client.disconnect()
        }
    }

}

