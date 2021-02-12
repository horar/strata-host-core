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
        x: 445
        y: 71
        width: 96
        height: 48
        text: client.connectionStatus
        font.pointSize: 14
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Button {
        id: disconnectBtn
        x: 298
        y: 55
        width: 86
        height: 88
        text: qsTr("Disconnect")
        enabled: client.connectionStatus === "Connected"

        Connections {
            target: disconnectBtn
            onClicked: client.disconnect()
        }
    }

    ScrollView {
        id: messageScrollView
        x: 298
        y: 176
        width: 326
        height: 120
        clip: true
        enabled: client.connectionStatus === "Connected"

        TextArea {
            id: messageTextArea
            x: -10
            y: -6
            width: 326
            height: 120
            text: client.receivedMessages
            font.pointSize: 13
            readOnly: true
            wrapMode: Text.Wrap
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
        x: 298
        y: 302
        width: 250
        height: 31
        text: qsTr("")
        font.pointSize: 16
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        Keys.onPressed: {
            if (event.key === Qt.Key_Return && userInputField.text.length > 0) {
                sendBtn.clicked()
            }
        }
        enabled: client.connectionStatus === "Connected"
    }

    Button {
        id: sendBtn
        x: 559
        y: 302
        width: 65
        height: 31
        text: qsTr("Send")
        Connections {
            target: sendBtn
            onClicked: {
                client.tcpWrite(userInputField.text)
                userInputField.text = qsTr("")
            }
        }
        enabled: client.connectionStatus === "Connected"

    }

    StatusIndicator {
        id: statusIndicator
        x: 390
        y: 77
        width: 49
        height: 42
        color: "#65c903"
        active: client.connectionStatus == "Connected" ? true : false
    }

    Text {
        id: messageElement
        x: 298
        y: 149
        width: 114
        height: 21
        text: qsTr("Messages:")
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 17
    }

    ScrollView {
        id: logScrollView
        x: 19
        y: 176
        width: 261
        height: 157
        TextArea {
            id: logTextArea
            x: -10
            y: -6
            width: 305
            height: 124
            text: client.log
            font.pointSize: 13
            readOnly: true
            wrapMode: Text.Wrap
        }
        clip: true
    }

    Text {
        id: logElement
        x: 25
        y: 149
        width: 114
        height: 21
        text: qsTr("Logs:")
        font.pixelSize: 17
        verticalAlignment: Text.AlignVCenter
    }

}

