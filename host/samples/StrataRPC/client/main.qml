import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Extras 1.4

Window {
    id: window
    visible: true
    width: 640
    height: 340
    title: qsTr("Strata Client")

    Item {
        id: connectionItem
        x: 15
        y: 18
        width: 225
        height: 95

        Button {
            id: connectButton
            height: 40
            anchors.left: connectionItem.left
            anchors.right: connectionStatusIndicator.left
            anchors.top: connectionItem.top
            anchors.margins: 5
            text: "Connect"
            enabled: (Client.connectionStatus === false)
            Connections {
                target: connectButton
                onClicked: Client.connectToServer()
            }
        }
        StatusIndicator {
            id: connectionStatusIndicator
            anchors.right: connectionItem.right
            anchors.margins: 5
            height: connectButton.height
            anchors.verticalCenter: connectButton.verticalCenter
            color: "#00ff00"
            active: (Client.connectionStatus === true)
        }

        Button {
            id: disconnectButtons
            anchors.left: connectionItem.left
            anchors.right: connectionItem.right
            anchors.top: connectButton.bottom
            anchors.margins: 5
            text: "Disconnect"
            enabled: (Client.connectionStatus === true)
            Connections {
                target: disconnectButton
                onClicked: Client.disconnectServer()
            }
        }
    }

    Button {
        id: closeServerButton
        x: 15
        y: 119
        width: 225
        height: 40
        text: qsTr("Close Server")
        Connections {
            target: closeServerButton
            onClicked: Client.closeServer()
        }
    }

    Button {
        id: requestServerStatusButton
        x: 15
        y: 165
        width: 225
        height: 40
        text: qsTr("Request Server Status")
        Connections {
            target: requestServerStatusButton
            onClicked: Client.requestServerStatus()
        }
    }

    Item {
        id: serverTimeItem
        x: 475
        y: 323
        width: 173
        height: 17
        Label {
            id: serverTimeLabel
            text: "Server Time: "
        }
        Label {
            id: serverTimeValue
            text: Client.serverTime
            anchors.left: serverTimeLabel.right
        }
    }
}
