import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Extras 1.4

Window {
    visible: true
    width: 640
    height: 340
    title: qsTr("Strata Server")
    color: "#9abfa8"


    Item {
        id: setPortItem
        x: 25
        y: 35
        width: 281
        height: 41

        Label {
            id: labelPort
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            text: qsTr("UDP Port")
            font.bold: false
            font.pointSize: 19
            styleColor: "#e36464"
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.Wrap
            anchors.verticalCenterOffset: 25
            anchors.leftMargin: -8
            horizontalAlignment: Text.AlignHCenter

        }

        TextField {
            id: portField
            anchors.left: labelPort.right
            anchors.right: setPortBtn.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            text: Server.getPort()
            placeholderText: "Enter broadcasting port"
            anchors.margins: 5
            anchors.verticalCenterOffset: 25
            anchors.rightMargin: 6
            anchors.leftMargin: 4
            enabled: !Server.isConnected

        }

        Button {
            id: setPortBtn
            x: 222
            anchors.right: parent.right
            anchors.verticalCenterOffset: 25
            anchors.rightMargin: -1
            anchors.verticalCenter: parent.verticalCenter
            width: 60
            height: parent.height
            text: qsTr("Set")
            enabled: !Server.isConnected

            Connections {
                target: setPortBtn
                onClicked: Server.setPort(portField.text)
            }
        }
    }

    Item {
        id: udpItem
        x: 25
        y: 165
        width: 281
        height: 158

        Label {
            id: udpLogLabel
            anchors.top: parent.top
            anchors.leftMargin: -8
            anchors.topMargin: -7
            anchors.left: parent.left
            text: qsTr("UDP Messages:")
        }

        ScrollView {
            id: udpLogSV
            x: 0
            width: parent.width
            anchors.top: udpLogLabel.bottom
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -16
            anchors.topMargin: 16
            clip: true

            TextArea {
                id: udpLogTA
                anchors.fill: parent
                anchors.rightMargin: -142
                anchors.bottomMargin: -109
                anchors.leftMargin: -10
                anchors.topMargin: -6
                text: Server.udpBuffer
                clip: false
            }
        }
    }



    Item {
        id: connectionStatusItem
        x: 25
        y: 90
        width: 281
        height: 38

        StatusIndicator {
            id: connectionStatusIndicator
            x: 241
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.verticalCenterOffset: 15
            anchors.rightMargin: 8
            width: 32
            height: 32
            color: "#65c903"
            active: (Server.isConnected === true)
        }

        Button {
            id: disconnectBtn
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: connectionStatusIndicator.left
            anchors.verticalCenterOffset: 18
            anchors.leftMargin: -7
            anchors.rightMargin: 12
            height: parent.height
            text: qsTr("Disconnect")
            enabled: (Server.isConnected === true)
            Connections {
                target: disconnectBtn
                onClicked: Server.disconnectTcpSocket()
            }
        }
    }

    Item {
        id: tcpItem
        x: 341
        y: 139
        width: 281
        height: 172

        Item {
            id: tcpLogItem
            anchors.top: parent.top
            width: parent.width
            anchors.bottom: sendMsgItem.top

            Label {
                id: tcpLogLabel
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: -7
                anchors.topMargin: 14
                text: qsTr("TCP Messages:")
            }

            ScrollView {
                id: tcpLogSV
                x: 0
                width: parent.width
                anchors.top: tcpLogLabel.bottom
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                anchors.topMargin: -8

                TextArea {
                    id: tcpLogTA
                    anchors.fill: parent
                    anchors.rightMargin: -147
                    anchors.bottomMargin: -92
                    anchors.leftMargin: -10
                    anchors.topMargin: 5
                    text: Server.tcpBuffer
                }
            }
        }

        Item {
            id: sendMsgItem
            anchors.bottom: parent.bottom
            anchors.topMargin: 5
            width: parent.width
            height: 34
            enabled: Server.isConnected

            TextField {
                id: sendMsgTextField
                anchors.left: parent.left
                anchors.right: sendMsgBtn.left
                anchors.verticalCenterOffset: 16
                anchors.leftMargin: -8
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 13
                height: parent.height
                placeholderText: qsTr("TCP Message...")
                enabled: Server.isConnected
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return && sendMsgTextField.text.length > 0) {
                        sendMsgBtn.clicked()
                    }
                }
            }

            Button {
                id: sendMsgBtn
                x: 222
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.verticalCenterOffset: 15
                anchors.rightMargin: -1
                width: 60
                height: parent.height
                text: qsTr("Send")
                enabled: Server.isConnected


                Connections {
                    target: sendMsgBtn
                    onClicked: {
                        Server.sendTcpMessge(sendMsgTextField.text)
                        sendMsgTextField.text = qsTr("")
                    }
                }
            }
        }
    }

    Item {
        id: hostInfoItem
        x: 341
        y: 57
        width: 281
        height: 63

        Label {
            id: hostAddressLable
            anchors.left: hostInfoItem.left
            anchors.top: hostInfoItem.top
            text: qsTr("IP: ")
            padding: 0
        }

        Label {
            id: hostAddressValueLable
            anchors.left: hostAddressLable.right
            y: hostAddressLable.y
            text: Server.hostAddress
        }

        Label {
            id: tcpPortLabel
            anchors.left: hostInfoItem.left
            anchors.top: hostAddressLable.bottom
            y: 30
            text: qsTr("TCP Port: ")
        }

        Label {
            id: tcpPortValueLabel
            anchors.left: tcpPortLabel.right
            y: tcpPortLabel.y
            text: Server.tcpPort
        }

        Label {
            id: clientAdressLabel
            anchors.left: hostInfoItem.left
            anchors.top: tcpPortLabel.bottom
            text: qsTr("Client Address: ")
        }

        Label {
            id: clientAdressValueLabel
            anchors.left: clientAdressLabel.right
            y: clientAdressLabel.y
            text: Server.clientAddreass
        }
    }

    Text {
        id: appTitle
        x: 9
        y: 11
        width: 291
        height: 29
        text: qsTr("Strata Host")
        font.pixelSize: 24
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        font.italic: true
        font.bold: true
    }
}

/*##^##
Designer {
    D{i:0;annotation:"1 //;;// MainAppWindow //;;//  //;;//  //;;// 1612428635";customId:"";formeditorZoom:1.100000023841858}
}
##^##*/
