import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Extras 1.4

Window {
    id: window
    visible: true
    width: 640
    height: 340
    color: "#9abfa8"
    title: qsTr("Strata Client")

    Button {
        id: broadcastBtn
        x: 25
        y: 98
        width: 255
        height: 44
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
        font.pointSize: 17
        styleColor: "#e36464"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    TextField {
        id: portField
        x: 84
        y: 55
        width: 99
        height: 37
        text: client.getPort()
        placeholderText: "Enter broadcasting port"
    }

    Button {
        id: setPortBtn
        x: 197
        y: 55
        width: 83
        height: 37
        text: qsTr("Set")
        rotation: 0.536

        Connections {
            target: setPortBtn
            onClicked: client.setPort(portField.text)
        }
    }

    Label {
        id: statusLabel
        x: 172
        y: 200
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
        y: 206
        width: 86
        height: 42
        text: qsTr("Disconnect")
        enabled: client.connectionStatus === "Connected"

        Connections {
            target: disconnectBtn
            onClicked: client.disconnect()
        }
    }

    ScrollView {
        id: messageScrollView
        x: 313
        y: 195
        width: 305
        height: 117
        clip: true
        enabled: client.connectionStatus === "Connected"

        TextArea {
            id: messageTextArea
            x: -10
            y: -6
            width: 300
            height: 117
            text: client.receivedMessages
            font.pointSize: 17
            readOnly: true
            enabled: client.connectionStatus === "Connected"
//            background: Rectangle {
//                radius: 2
//                x: messageTextArea.x
//                y: messageTextArea.y
//                border.color: "#333"
//                border.width: 1
//            }
        }
    }

    TextField {
        id: userInputField
        x: 25
        y: 268
        width: 192
        height: 31
        text: qsTr("")
        font.pointSize: 16
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        enabled: client.connectionStatus === "Connected"
    }

    Button {
        id: sendBtn1
        x: 223
        y: 268
        width: 57
        height: 31
        text: qsTr("Send")
        Connections {
            target: sendBtn1
            onClicked: client.tcpWrite(userInputField.text)
        }
        enabled: client.connectionStatus === "Connected"

    }

    StatusIndicator {
        id: statusIndicator
        x: 117
        y: 206
        width: 49
        height: 42
        color: "#65c903"
        active: client.connectionStatus == "Connected" ? true : false
    }

    Text {
        id: messageElement
        x: 313
        y: 170
        width: 114
        height: 21
        text: qsTr("Messages:")
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 17
    }

    ScrollView {
        id: logScrollView
        x: 313
        y: 53
        width: 305
        height: 117
        TextArea {
            id: logTextArea
            x: -20
            y: -133
            width: 305
            height: 124
            text: qsTr("")
            font.pointSize: 17
            clip: false
        }
        clip: true
    }

    Text {
        id: logElement1
        x: 313
        y: 26
        width: 114
        height: 21
        text: qsTr("Logs:")
        font.pixelSize: 17
        verticalAlignment: Text.AlignVCenter
    }

}

