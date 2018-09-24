import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id: root

    property bool portConnected: false
    property color portColor: "#30a2db"

    property alias advertisedVoltage: advertisedVoltageBox.value
    property alias maxPower: maxPowerBox.value
    property alias inputPower: inputPowerBox.value
    property alias outputPower: outputPowerBox.value
    property alias outputVoltage: outputVoltageBox.value
    property alias portTemperature: portTemperatureBox.value
    property alias efficency: efficencyBox.value

    property var deviceConnected: platformInterface.usb_pd_port_connect.connection_state
    property var deviceDisconnected: platformInterface.usb_pd_port_disconnect.connection_state
    property string portName: "USB_C_port_" + portNumber

    onDeviceConnectedChanged: {

        if (platformInterface.usb_pd_port_connect.port_id === portName){
            if (platformInterface.usb_pd_port_connect.connection_state === "connected"){
                root.portConnected = true;
            }
        }
    }

    onDeviceDisconnectedChanged: {
        if (platformInterface.usb_pd_port_disconnect.port_id === portName){
            if (platformInterface.usb_pd_port_disconnect.connection_state === "disconnected"){
                root.portConnected = false;
            }

        }
    }

    width: 400

    Item {
        id: margins
        anchors {
            fill: parent
            topMargin: 15
            leftMargin: 15
            rightMargin: 15
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

            Rectangle {
                color: portColor
                visible: portConnected
                anchors {
                    top: portTitle.bottom
                }
                height: 10
                width: portTitle.width
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
                        value: ""
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "V"
                    }

                    PortStatBox {
                        id: maxPowerBox
                        label: "MAX CAPACITY"
                        value: ""
                        icon: "../images/icon-max.svg"
                        portColor: root.portColor
                        unit: "W"
                    }

                    PortStatBox {
                        id:inputPowerBox
                        label: "POWER IN"
                        value: ""
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "W"
                    }

                    PortStatBox {
                        id: outputPowerBox
                        label: "POWER OUT"
                        value: ""
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "W"
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
                        value: ""
                        icon: "../images/icon-voltage.svg"
                        portColor: root.portColor
                        unit: "V"
                    }

                    PortStatBox {
                        id:portTemperatureBox
                        label: "TEMPERATURE"
                        value: ""
                        icon: "../images/icon-temp.svg"
                        portColor: root.portColor
                        unit: "°C"
                    }

                    PortStatBox {
                        id:efficencyBox
                        label: "EFFICIENCY"
                        value: ""
                        icon: "../images/icon-efficiency.svg"
                        portColor: root.portColor
                        unit: "%"
                    }
                }
            }
        }
    }
}
