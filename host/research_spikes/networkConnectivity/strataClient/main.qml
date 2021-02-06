import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Extras 1.4

Window {
    visible: true
    width: 640
    height: 340
    title: qsTr("Strata Client")

    Button {
        id: broadcastBtn
        x: 25
        y: 107
        width: 255
        height: 56
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
        x: 25
        y: 53
        width: 53
        height: 48
        text: qsTr("Port")
        font.bold: false
        font.pointSize: 19
        styleColor: "#e36464"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    TextField {
        id: portField
        x: 84
        y: 55
        width: 96
        height: 46
        text: client.getPort()
        placeholderText: "Enter broadcasting port"
    }

    Button {
        id: setPortBtn
        x: 197
        y: 55
        width: 83
        height: 48
        text: qsTr("Set")

        Connections {
            target: setPortBtn
            onClicked: client.setPort(portField.text)
        }
    }

    Label {
        id: statusLabel
        x: 172
        y: 189
        width: 96
        height: 48
        text: client.connectionStatus
        font.pointSize: 14
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Button {
        id: disconnectBtn
        x: 25
        y: 189
        width: 86
        height: 54
        text: qsTr("Disconnect")
        enabled: client.connectionStatus == "Connected"

        Connections {
            target: disconnectBtn
            onClicked: client.disconnect()
        }
    }

    ScrollView {
        id: scrollView
        x: 315
        y: 189
        width: 305
        height: 117
    }

    TextField {
        id: userInputField
        x: 25
        y: 249
        width: 192
        height: 57
        text: qsTr("Text Field")
    }

    Button {
        id: sendBtn1
        x: 223
        y: 249
        width: 57
        height: 57
        text: qsTr("Send")
        Connections {
            target: sendBtn1
        }
    }

    StatusIndicator {
        id: statusIndicator
        x: 117
        y: 195
        width: 49
        height: 42
        color: "#65c903"
        active: client.connectionStatus == "Connected" ? true : flase
    }


}

/*##^##
Designer {
    D{i:10;customId:""}
}
##^##*/
