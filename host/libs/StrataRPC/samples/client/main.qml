import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3
import QtQuick.Extras 1.4
import QtCharts 2.3

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
            id: disconnectButton
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

    Item {
        id: randomGraphItem
        x: 255
        y: 7
        width: 375
        height: 299

        Button {
            id: requestRandomGraphButton
            anchors.left: randomGraphItem.left
            anchors.right: randomGraphItem.right
            anchors.bottom: randomGraphItem.bottom
            text: qsTr("Request Random Graph")

            Connections {
                target: requestRandomGraphButton
                onClicked: Client.requestRandomGraph()
            }
        }

        ChartView {
            title: "Random Graph"
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: requestRandomGraphButton.top
            antialiasing: true
            legend.visible: false

            ValueAxis {
                id: axisX
                min: 0
                max: 5
                tickCount: 6
                tickInterval: 1
            }

            ValueAxis {
                id: axisY
                min: 0
                max: 10
                tickCount: 6
                tickInterval: 1
            }

            LineSeries {
                id: randomLineSeries
                axisX: axisX
                axisY: axisY
            }

            Connections {
                target: Client
                onRandomGraphUpdated: {
                    randomLineSeries.clear()
                    for(let i=0; i < randomNumbersList.length; i++) {
                        randomLineSeries.append(i,randomNumbersList[i])
                    }
                }
            }
        }
    }
}
