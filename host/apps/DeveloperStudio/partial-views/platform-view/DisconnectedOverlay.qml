import QtQuick 2.12

import tech.strata.sgwidgets 1.0

Item {
    id: overlayRoot
    anchors {
        fill: parent
    }

    Rectangle {
        id: modalCover
        color: "#aaa"
        anchors {
            fill: parent
        }
    }

    Rectangle {
        id: popup
        color: "#ddd"
        anchors {
            centerIn: parent
        }
        width: errorColumn.width + 100
        height: errorColumn.height + 100

        Column {
            id: errorColumn
            anchors.centerIn: parent
            spacing: 20

            SGIcon {
                height: 70
                width: height
                source: "qrc:/sgimages/disconnected.svg"
                iconColor : "#aaa"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            SGText {
                id: error
                fontSizeMultiplier: 2
                color: "#555"
                text: "Platform disconnected"
                font.bold: true
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }

            SGText {
                id: errorSubtext
                fontSizeMultiplier: 1
                color: "#555"
                text: "Connect platform to access control interface"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
