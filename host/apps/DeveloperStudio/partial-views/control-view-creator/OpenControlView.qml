import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.SGQrcListModel 1.0

Rectangle {
    id: openProjectContainer
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
            text: "Open Control View Project"
        }

        Rectangle {
            // divider line
            color: "#333"
            Layout.preferredHeight: 1
            Layout.fillWidth: true
        }

//        Repeater {
//            model: qrcModel

//            delegate: Text {
//                text: "PREFIX: " + prefix + " | FILENAME: " + filename
//            }
//        }

        SGAlignedLabel {
            Layout.topMargin: 20
            color: "#666"
            fontSizeMultiplier: 1.25
            text: "Select control view project .QRC file:"
            target: directoryInput

            RowLayout {
                id: directoryInput

                SGButton {
                    text: "Select"
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
                text: "Open Project"

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

    SGQrcListModel {
        id: qrcModel
        url: "file:///Users/zbj9gc/Downloads/sample/qml.qrc"
    }


}
