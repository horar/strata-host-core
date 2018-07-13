import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/sgwidgets"

Item {
    id: root
    height: parent.height
    width: 300

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
                id: advertisedVoltages
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
                    left: advertisedVoltages.right
                    leftMargin: 10
                }
            }

            PortStats {
                id: stats
                anchors {
                    left: divider.right
                    leftMargin: 10
                    right: statsContainer.right
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
