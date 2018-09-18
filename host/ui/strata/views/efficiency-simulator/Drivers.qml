import QtQuick 2.9
import "component_source.js" as ComponentSource

Item {
    id: root
    anchors {
        fill: parent
    }

    Row {
        id: header
        anchors {
            horizontalCenter: root.horizontalCenter
        }

        Rectangle {
            id: col1
            color: "#ddd"
            height: 30
            width: col1Text.width + 40
            Text {
                id: col1Text
                text: '<b>Driver</b>'
                anchors {
                    verticalCenter: col1.verticalCenter
                    horizontalCenter: col1.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col2
            color: "#ddd"
            height: 30
            width: col2Text.width + 40
            Text {
                id: col2Text
                text: '<b>Max Voltage</b>'
                anchors {
                    verticalCenter: col2.verticalCenter
                    horizontalCenter: col2.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col3
            color: "#ddd"
            height: 30
            width: col3Text.width + 40
            Text {
                id: col3Text
                text: '<b>Sourcing Resistance</b>'
                anchors {
                    verticalCenter: col3.verticalCenter
                    horizontalCenter: col3.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col4
            color: "#ddd"
            height: 30
            width: col4Text.width + 40
            Text {
                id: col4Text
                text: '<b>Sinking Resistance</b>'
                anchors {
                    verticalCenter: col4.verticalCenter
                    horizontalCenter: col4.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col5
            color: "#ddd"
            height: 30
            width: col5Text.width + 40
            Text {
                id: col5Text
                text: '<b>Rise Delay Time</b>'
                anchors {
                    verticalCenter: col5.verticalCenter
                    horizontalCenter: col5.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col6
            color: "#ddd"
            height: 30
            width: col6Text.width + 40
            Text {
                id: col6Text
                text: '<b>External Gate Resistance</b>'
                anchors {
                    verticalCenter: col6.verticalCenter
                    horizontalCenter: col6.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col7
            color: "#ddd"
            height: 30
            width: col7Text.width + 40
            Text {
                id: col7Text
                text: '<b>Quiescent Current</b>'
                anchors {
                    verticalCenter: col7.verticalCenter
                    horizontalCenter: col7.horizontalCenter
                }
            }
        }
    }

    ListView {
        id: driverView
        anchors {
            left: header.left
            right: header.right
            bottom: root.bottom
            top: header.bottom
        }
        model: driverModel
        clip: true
        delegate: Rectangle {
            id: infoRowContainer
            width: infoRow.width
            height: 20
            color: index %2 === 0 ? "#eee" : "white"
            Row {
                id: infoRow
                anchors {
                    verticalCenter: infoRowContainer.verticalCenter
                }
                Text {
                    text: "  " + component_id
                    width: col1.width
                }
                Text {
                    text: MaximDriverVoltage
                    width: col2.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: SourcingResistance
                    width: col3.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: SinkingResistance
                    width: col4.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: RiseDelayTime
                    width: col5.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: ExternalGateResistance
                    width: col6.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: QuiescentCurrent
                    width: col7.width
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    ListModel {
        id: driverModel
        Component.onCompleted: {
            ComponentSource.loadComponentsIntoModel("driver", this)
        }
    }
}
