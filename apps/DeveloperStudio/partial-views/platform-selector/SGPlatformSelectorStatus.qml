import QtQuick 2.12

import tech.strata.sgwidgets 1.0

Item {
    id: root
    visible: status !== "loaded"

    property string status

    Column {
        anchors {
            centerIn: root
        }
        spacing: 20

        AnimatedImage {
            source: "qrc:/images/loading.gif"
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            visible: root.status === "loading"
            playing: visible
        }

        SGIcon {
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            source: "qrc:/sgimages/exclamation-circle.svg"
            iconColor: "lightgrey"
            height: 40
            width: 40
            visible: root.status === "error"
        }

        SGText {
            id: status
            color: "lightgrey"
            font.bold: true
            text: {
                switch (root.status) {
                case "loading":
                    return "Loading platform list..."
                case "error":
                    return "Failed to load platform list\nRestart Strata to retry"
                default:
                    return ""
                }
            }
            fontSizeMultiplier: 3
            anchors {
                horizontalCenter: parent.horizontalCenter
            }
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
