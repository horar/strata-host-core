import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0

import "qrc:/js/template_data.js" as TemplateData

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
            text: "Select a UI template:"
            target: templateLayout

            GridLayout {
                id: templateLayout
                columns: 4

                ButtonGroup {
                    id: templateButtonGroup
                    exclusive: true
                }

                Repeater {
                    model: ListModel {
                        id: templateModel

                        Component.onCompleted: {
                            for (let i = 0; i < TemplateData.data.length; i++) {
                                append(TemplateData.data[i])
                            }
                        }
                    }

                    delegate: AbstractButton {
                        id: templateButton
                        Layout.preferredWidth: delegateContent.width
                        Layout.preferredHeight: delegateContent.height
                        ButtonGroup.group: templateButtonGroup
                        checkable: true

                        property string path: model.path

                        Component.onCompleted: {
                            if (index === 0) {
                                checked = true
                            }
                        }

                        Rectangle {
                            id: delegateContent
                            width: delegateColumn.implicitWidth + 20
                            height: delegateColumn.implicitHeight + 20
                            color: templateButton.checked ? "#eee" : "transparent"
                            radius: 10

                            MouseArea {
                                anchors {
                                    fill: parent
                                }
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPressed: mouse.accepted = false
                            }

                            ColumnLayout {
                                id: delegateColumn
                                anchors {
                                    centerIn: parent
                                }

                                Image {
                                    id: templateImage
                                    Layout.preferredWidth: 150
                                    Layout.preferredHeight: 100
                                    source: model.image
                                }

                                SGText {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.maximumWidth: templateImage.width
                                    wrapMode: Text.Wrap
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    text: model.name
                                }
                            }
                        }
                    }
                }
            }
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
                    text: "Browse..."

                    onPressed: {
                        fileSelector.open();
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 600
                    Layout.preferredHeight: 40
                    color: "#eee"
                    border.color: "#333"
                    border.width: 1

                    TextInput {
                        id: fileOutput
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 10
                        }
                        text:  fileSelector.folder.toString();
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
                    editor.treeModel.url = sdsModel.newControlView.createNewProject(fileOutput.text, templateButtonGroup.checkedButton.path);
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

    FileDialog {
        id: fileSelector
        folder: shortcuts.home
        selectFolder: true
    }
}
