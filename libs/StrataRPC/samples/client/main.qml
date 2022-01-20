/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    title: qsTr("StrataRPC Client Sample")

    Item {
        id: controlsItem
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 5
        width: 240
        height: parent.height - (2 * anchors.margins)

        Item {
            id: connectionItem
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 5
            width: parent.width
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

        Item {
            id: serverCommandsItem
            anchors.top: connectionItem.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 5
            height: 139

            Button {
                id: closeServerButton
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 5
                text: qsTr("Close Server")

                Connections {
                    target: closeServerButton
                    onClicked: Client.closeServer()
                }
            }

            Button {
                id: requestServerStatusButton
                anchors.top: closeServerButton.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 5
                text: qsTr("Request Server Status")

                Connections {
                    target: requestServerStatusButton
                    onClicked: Client.requestServerStatus()
                }
            }

            Item {
                id: serverPingItem
                height: 44
                anchors.top : requestServerStatusButton.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.margins: 5

                Button {
                    id: pingServerButton
                    anchors.left: parent.left
                    text: qsTr("Ping Server")

                    Connections {
                        target: pingServerButton
                        onClicked: Client.pingServer()
                    }
                }

                Label {
                    id: serverDelayLabel
                    anchors.left: pingServerButton.right
                    anchors.verticalCenter: pingServerButton.verticalCenter
                    anchors.margins: 5
                    text: qsTr("Delay: ")
                }

                Label {
                    id: serverDelayValue
                    anchors.left: serverDelayLabel.right
                    anchors.verticalCenter: pingServerButton.verticalCenter
                }

                Connections {
                    target: Client
                    onServerDelayUpdated: {
                        serverDelayValue.text = delay + "ms"
                    }
                }
            }
        }

        Item {
            id: errorsItem
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: serverCommandsItem.bottom
            anchors.bottom: parent.bottom
            anchors.margins: 5

            Label {
                id: errorsLabel
                text: qsTr("Errors:")
                anchors.top: parent.top
                anchors.left: parent.left
            }

            ScrollView {
                id: errorsScrollView
                anchors.top: errorsLabel.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                Flickable {
                    id: errorsFlickable
                    anchors.fill: parent
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {}

                    TextArea.flickable: TextArea {
                        id: errorsTextArea
                        property int msgCount: 0
                        anchors.fill: parent
                        font.pointSize: 13
                        readOnly: true
                        wrapMode: Text.Wrap
                    }
                }
            }

            Connections {
                target: Client
                onErrorOccurred: {
                    errorsTextArea.append(errorMessage);
                    errorsTextArea.msgCount++;
                }
            }
        }
    }

    Item {
        id: serverTimeItem
        anchors.bottom: parent.bottom
        anchors.right: parent.right
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
        anchors.top: parent.top
        anchors.left: controlsItem.right
        anchors.right: parent.right
        anchors.bottom: serverTimeItem.top
        anchors.margins: 5

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
