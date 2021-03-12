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

}
