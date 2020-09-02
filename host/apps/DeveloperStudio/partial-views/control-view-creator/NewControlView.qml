import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

Rectangle {
    id: createNewContainer
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
            text: "Create New Control View Project"
        }

        Rectangle {
            // divider line
            color: "#333"
            Layout.preferredHeight: 1
            Layout.fillWidth: true
        }

        SGAlignedLabel {
            Layout.topMargin: 20
            color: "#666"
            fontSizeMultiplier: 1.25
            text: "Select directory to create project in:"
            target: directoryInput

            RowLayout {
                id: directoryInput

                SGButton {
                    text: "Open"
                }

                Rectangle {
                    Layout.preferredWidth: 600
                    Layout.preferredHeight: 40
                    color: "#eee"
                    border.color: "#333"
                    border.width: 1

                    TextInput {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 10
                        }
                        text: "/Users/zbgzzh/Desktop"
                        color: "#333"
                    }
                }
            }
        }

        RowLayout {
            Layout.topMargin: 20
            Layout.fillWidth: false
            spacing: 20

            SGButton {
                text: "Create Project"

                onClicked: {
                    viewStack.currentIndex = editUseStrip.offset
                    editUseStrip.checkedIndices = 1
                }
            }

            SGButton {
                text: "Cancel"

                onClicked: {
                    viewStack.currentIndex = 0
                }
            }
        }

        Item {
            // space filler
            Layout.fillHeight: true
        }
    }
}
