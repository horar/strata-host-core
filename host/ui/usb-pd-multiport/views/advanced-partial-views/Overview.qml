import QtQuick 2.9
import "qrc:/sgwidgets"

Item {
    id: root
    width: parent.width

    Item{
        id: leftColumn
        anchors {
            left: parent.left
            top: parent.top
            right: rightColumn.left
            bottom: parent.bottom
        }

        Item {
            id: margins
            anchors {
                fill: parent
                margins: 15
            }

            SGCapacityBar {
                id: capacityBar
                width: margins.width
                //label: "Power Stackup:"
                labelLeft: false
                barWidth: margins.width

                gaugeElements: Row {
                    id: container
                    property real totalValue: childrenRect.width // Necessary for over threshold detection signal

                    SGCapacityBarElement{
                        color: miniInfo1.statBoxColor
                        value: 20
                    }

                    SGCapacityBarElement{
                        color: miniInfo2.statBoxColor
                        value: 20
                    }

                    SGCapacityBarElement{
                        color: miniInfo3.statBoxColor
                        value: 20
                    }
                }
            }

            PortInfoMini {
                id: miniInfo1
                portNum: 1
                anchors {
                    top: capacityBar.bottom
                    left: margins.left
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                statBoxColor: "#30a2db"
            }

            PortInfoMini {
                id: miniInfo2
                portNum: 2
                anchors {
                    top: capacityBar.bottom
                    left: miniInfo1.right
                    leftMargin: 20
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                statBoxColor: "#3bb539"
            }

            PortInfoMini {
                id: miniInfo3
                portNum: 3
                anchors {
                    top: capacityBar.bottom
                    left: miniInfo2.right
                    leftMargin: 20
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                statBoxColor: "#d68f14"
            }

            PortInfoMini {
                id: miniInfo4
                portNum: 4
                anchors {
                    top: capacityBar.bottom
                    left: miniInfo3.right
                    leftMargin: 20
                    bottom: margins.bottom
                }
                width: margins.width / 4 - 15
                portConnected: false
            }
        }
    }

    Item{
        id: rightColumn
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: root.width/3

        SGStatusListBox {
            id: currentFaults
            height: rightColumn.height/2
            width: rightColumn.width
            title: "Current Faults:"
        }

        SGOutputLogBox {
            id: faultHistory
            height: rightColumn.height/2
            anchors {
                top: currentFaults.bottom
            }
            width: rightColumn.width
            title: "Fault History:"

        }
    }
}
