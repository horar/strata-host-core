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
    title: qsTr("Strata Platform")

    Button {
        id: broadcastBtn
        x: 25
        y: 98
        width: 255
        height: 44
        text: qsTr("Broadcast")
        font.pointSize: 14
        display: AbstractButton.TextBesideIcon
        enabled: !Client.isConnected
        Connections {
            target: broadcastBtn
            onClicked: Client.broadcastDatagram()
        }

    }

    Label {
        id: labelPort
        x: 25
        y: 55
        width: 53
        height: 37
        text: qsTr("UDP Port")
        font.bold: false
        font.pointSize: 13
        styleColor: "#e36464"
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
    }

    TextField {
        id: portField
        x: 84
        y: 55
        width: 99
        height: 37
        text: Client.getPort()
        placeholderText: "Enter broadcasting port"
        enabled: !Client.isConnected
    }

    Button {
        id: setPortBtn
        x: 197
        y: 55
        width: 83
        height: 37
        text: qsTr("Set")
        enabled: !Client.isConnected

        Connections {
            target: setPortBtn
            onClicked: Client.setPort(portField.text)
        }
    }

    Button {
        id: disconnectBtn
        x: 298
        y: 55
        width: 86
        height: 46
        text: qsTr("Disconnect")
        enabled: Client.isConnected

        Connections {
            target: disconnectBtn
            onClicked: Client.disconnect()
        }
    }

    ScrollView {
        id: messageScrollView
        x: 298
        y: 176
        width: 326
        height: 120
        clip: true
        enabled: Client.isConnected

        Flickable {
            anchors.fill: parent
            anchors.rightMargin: -9
            anchors.bottomMargin: -5
            anchors.leftMargin: 9
            anchors.topMargin: 5
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}

            TextArea.flickable: TextArea {
                id: messageTextArea
                property int msgCount: 0
                x: -10
                y: -6
                width: 326
                height: 120
                text: {
                    clear(Client.receivedMessages)
                    append(Client.receivedMessages.arg(msgCount++))
                }
                font.pointSize: 13
                readOnly: true
                wrapMode: Text.Wrap
                enabled: Client.isConnected
            }
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
        placeholderText: "TCP Message..."
        horizontalAlignment: Text.AlignLeft
        Keys.onPressed: {
            if (event.key === Qt.Key_Return && userInputField.text.length > 0) {
                sendBtn.clicked()
            }
        }
        enabled: Client.isConnected
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
                Client.tcpWrite(userInputField.text)
                userInputField.text = qsTr("")
            }
        }
        enabled: Client.isConnected

    }

    StatusIndicator {
        id: statusIndicator
        x: 317
        y: 107
        width: 49
        height: 42
        color: "#65c903"
        active: Client.isConnected
    }

    Text {
        id: messageElement
        x: 298
        y: 149
        width: 114
        height: 21
        text: qsTr("TCP Messages:")
        verticalAlignment: Text.AlignVCenter
        minimumPixelSize: 13
        font.pixelSize: 15
    }

    ScrollView {
        id: logScrollView
        x: 19
        y: 176
        width: 261
        height: 157

        Flickable {
            anchors.fill: parent
            anchors.rightMargin: -9
            anchors.bottomMargin: -5
            anchors.leftMargin: 9
            anchors.topMargin: 5
            boundsBehavior: Flickable.StopAtBounds

            TextArea.flickable: TextArea {
                id: logTextArea
                property int logCount : 0
                x: -10
                y: -6
                width: 305
                height: 124
                text: {
                    clear(Client.log)
                    append(Client.log.arg(logCount++))
                }
                font.pointSize: 13
                readOnly: true
                wrapMode: Text.Wrap
            }
        }
    }

    Text {
        id: logElement
        x: 25
        y: 149
        width: 114
        height: 21
        text: qsTr("Logs:")
        font.pixelSize: 13
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: ipText
        x: 398
        y: 55
        width: 215
        height: 19
        text: qsTr("IP: ") + Client.hostAddress
        font.pixelSize: 12
        wrapMode: Text.Wrap
        minimumPixelSize: 19
    }

    Text {
        id: tcpText
        x: 398
        y: 81
        width: 215
        height: 20
        text: qsTr("TCP Port: ") + Client.tcpPort
        font.pixelSize: 12
        wrapMode: Text.Wrap
        minimumPixelSize: 19
    }

    Text {
        id: appTitle
        x: 21
        y: 8
        width: 259
        height: 41
        text: qsTr("Strata Platform")
        font.pixelSize: 24
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        font.italic: true
        font.bold: true
        minimumPixelSize: 21
        fontSizeMode: Text.HorizontalFit
    }
}

