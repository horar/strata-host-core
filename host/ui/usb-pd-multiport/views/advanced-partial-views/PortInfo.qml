import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/sgwidgets"

Item {
    id: root

    property bool portConnected: true

    height: parent.height
    width: 400

    Item {
        id: margins
        anchors {
            fill: parent
            margins: 15
        }

        Item {
            id: statsContainer
            anchors {
                top: parent.top
                bottom: showGraphs.top
                bottomMargin: 15
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
                        source: "/views/images/icon-usb-disconnected.svg"
                        height: stats.height * 0.666
                        width: height * 0.6925
                        anchors {
                            centerIn: parent
                        }
                    }

                }

                Column {
                    id: column1
                    visible: root.portConnected
                    anchors {
                        //
                    }
                    width: stats.width/2-1
                    spacing: 3

                    PortStatBox {
                        label: "PROFILE"
                        value: "20 V"
                        icon: "/views/images/icon-voltage.svg"
                    }

                    PortStatBox {
                        label: "MAX CAPACITY"
                        value: "100 W"
                        icon: "/views/images/icon-max.svg"
                    }

                    PortStatBox {
                        label: "POWER IN"
                        value: "9 W"
                        icon: "/views/images/icon-voltage.svg"
                    }

                    PortStatBox {
                        label: "POWER OUT"
                        value: "7.8 W"
                        icon: "/views/images/icon-voltage.svg"
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
                        label: "VOLTAGE OUT"
                        value: "20.4 V"
                        icon: "/views/images/icon-voltage.svg"
                    }

                    PortStatBox {
                        label: "TEMPERATURE"
                        value: "36 °C"
                        icon: "/views/images/icon-temp.svg"
                    }

                    PortStatBox {
                        label: "EFFICIENCY"
                        value: "92 %"
                        icon: "/views/images/icon-efficiency.svg"
                    }
                }
            }
        }

        Button {
            id: showGraphs
            text: "Show Graphs"
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
        }
    }
}
