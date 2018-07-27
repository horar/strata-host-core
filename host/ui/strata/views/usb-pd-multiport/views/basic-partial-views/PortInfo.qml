import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/views/usb-pd-multiport/sgwidgets"

Rectangle {
    id: root

    property bool portConnected: true
    property color portColor: "#30a2db"
    property int portNumber: 1

    property alias advertisedVoltage: advertisedVoltageBox.value
    property alias maxPower: maxPowerBox.value
    property alias inputPower: inputPowerBox.value
    property alias outputPower: outputPowerBox.value
    property alias outputVoltage: outputVoltageBox.value
    property alias portTemperature: portTemperatureBox.value
    property alias efficency: efficencyBox.value


    signal showGraph()

    color: "white"

    width: 400

    Item {
        id: margins
        anchors {
            fill: parent
            topMargin: 15
            leftMargin: 15
            rightMargin: 0
            bottomMargin: 15
        }

        Item {
            id: statsContainer
            anchors {
                top: margins.top
                bottom: margins.bottom
                right: margins.right
                left: margins.left
            }

            Text {
                id: portTitle
                text: "<b>Port " + portNumber + "</b>"
                font {
                    pixelSize: 25
                }
                anchors {
                    verticalCenter: statsContainer.verticalCenter
                }
                color: root.portConnected ? "black" : "#bbb"
            }

            Button {
                id: showGraphs
                text: "Graphs"
                anchors {
                    bottom: parent.bottom
                    horizontalCenter: portTitle.horizontalCenter
                }
                height: 20
                width: 60
                onClicked: root.showGraph()
            }

            Rectangle {
                id: divider
                width: 1
                height: statsContainer.height
                color: "#ddd"
                anchors {
                    left: portTitle.right
                    leftMargin: 10
                }
            }

            Item {
                id: stats
                anchors {
                    top: statsContainer.top
                    left: divider.right
                    leftMargin: 10
                    right: statsContainer.right
                    bottom: statsContainer.bottom
                }

                Item {
                    id: connectionContainer
                    visible: !root.portConnected

                    anchors {
                        centerIn: parent
                    }

                    Image {
                        id: connectionIcon
                        source: "../images/icon-usb-disconnected.svg"
                        height: stats.height * 0.666
                        width: height * 0.6925
                        anchors {
                            centerIn: parent
                            verticalCenterOffset: -connectionText.font.pixelSize / 2
                        }
                    }

                    Text {
                        id: connectionText
                        color: "#ccc"
                        text: "<b>Port Disconnected</b>"
                        anchors {
                            top: connectionIcon.bottom
                            topMargin: 5
                            horizontalCenter: connectionIcon.horizontalCenter
                        }
                        font {
                            pixelSize: 14
                        }
                    }
                }

                Column {
                    id: column1
                    visible: root.portConnected
                    anchors {
                        verticalCenter: stats.verticalCenter
                    }
                    width: stats.width/2-1
                    spacing: 3

                    PortStatBox {
                        id:advertisedVoltageBox
                        label: "PROFILE"
                        //value: "20"
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "V"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:maxPowerBox
                        label: "MAX CAPACITY"
                        //value: "100"
                        icon: "../images/icon-max.svg"
                        portColor: root.portColor
                        unit: "W"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:inputPowerBox
                        label: "POWER IN"
                        //value: "9"
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "W"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:outputPowerBox
                        label: "POWER OUT"
                        //value: "7.8"
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "W"
                        height: (root.height - 10)/4
                    }

                }

                Column {
                    id: column2
                    visible: root.portConnected
                    anchors {
                        left: column1.right
                        leftMargin: column1.spacing
                        verticalCenter: column1.verticalCenter
                    }
                    spacing: column1.spacing
                    width: stats.width/2 - 2

                    PortStatBox {
                        id:outputVoltageBox
                        label: "VOLTAGE OUT"
                        //value: "20.4"
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "V"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:portTemperatureBox
                        label: "TEMPERATURE"
                        //value: "36"
                        icon: "../images/icon-temp.svg"
                        portColor: root.portColor
                        unit: "°C"
                        height: (root.height - 10)/4
                    }

                    PortStatBox {
                        id:efficencyBox
                        label: "EFFICIENCY"
                        //value: "92"
                        icon: "../images/icon-efficiency.svg"
                        portColor: root.portColor
                        unit: "%"
                        height: (root.height - 10)/4
                    }
                }
            }
        }
    }
}
