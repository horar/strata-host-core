import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Extras 1.4

Window {
    visible: true
    width: 640
    height: 340
    title: qsTr("Strata Server")

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
            text: qsTr("Port")
            font.bold: false
            font.pointSize: 19
            styleColor: "#e36464"
            verticalAlignment: Text.AlignVCenter
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

        }

        Button {
            id: setPortBtn
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.verticalCenter: parent.verticalCenter
            width: 60
            height: parent.height
            text: qsTr("Set")

            Connections {
                target: setPortBtn
                onClicked: Server.setPort(portField.text)
            }
        }
    }

    Item {
        id: udpItem
        x: 25
        y: 134
        width: 281
        height: 189

        Label {
            id: udpLogLabel
            anchors.top: parent.top
            anchors.left: parent.left
            text: qsTr("UDP Messages:")
        }

        ScrollView {
            id: udpLogSV
            width: parent.width
            anchors.top: udpLogLabel.bottom
            anchors.bottom: parent.bottom
            clip: true

            TextArea {
                id: udpLogTA
                anchors.fill: parent
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
            x: 110
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
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
            anchors.rightMargin: 5
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
        y: 133
        width: 281
        height: 177

        Item {
            id: tcpLogItem
            anchors.top: parent.top
            width: parent.width
            anchors.bottom: sendMsgItem.top

            Label {
                id: tcpLogLabel
                anchors.left: parent.left
                anchors.top: parent.top
                text: qsTr("TCP Messages:")
            }

            ScrollView {
                id: tcpLogSV
                width: parent.width
                anchors.top: tcpLogLabel.bottom
                anchors.bottom: parent.bottom

                TextArea {
                    id: tcpLogTA
                    anchors.fill: parent
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

            TextField {
                id: sendMsgTextField
                anchors.left: parent.left
                anchors.right: sendMsgBtn.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5
                height: parent.height
                placeholderText: qsTr("TCP Message...")
            }

            Button {
                id: sendMsgBtn
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: 60
                height: parent.height
                text: qsTr("Send")

                Connections {
                    target: sendMsgBtn
                    onClicked: Server.sendTcpMessge(sendMsgTextField.text)
                }

            }
        }
    }

    Item {
        id: hostInfoItem
        x: 341
        y: 35
        width: 281
        height: 63

        Label {
            id: hostAddressLable
            anchors.left: hostInfoItem.left
            anchors.top: hostInfoItem.top
            text: qsTr("Host Address: ")
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
}

/*##^##
Designer {
    D{i:0;annotation:"1 //;;// MainAppWindow //;;//  //;;//  //;;// 1612428635";customId:"";formeditorZoom:1.100000023841858}
}
##^##*/
