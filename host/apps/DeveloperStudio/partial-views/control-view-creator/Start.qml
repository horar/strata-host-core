import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

Rectangle {
    id: startContainer
    color: "#ccc"

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 10

        SGText {
            color: "#666"
            fontSizeMultiplier: 2
            text: "What would you like to do?"
        }

        Rectangle {
            // divider line
            color: "#333"
            Layout.preferredHeight: 1
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.topMargin: 20
            Layout.fillWidth: false
            spacing: 20

            SGButton {
                text: "Open Control View Project"
                onClicked: {
                    toolBarListView.currentIndex = toolBarListView.openTab
                }
            }

            SGButton {
                text: "Start New Control View Project"
                onClicked: {
                    toolBarListView.currentIndex = toolBarListView.newTab
                }
            }
        }

        Item {
            // space filler
            Layout.fillHeight: true
        }
    }
}
