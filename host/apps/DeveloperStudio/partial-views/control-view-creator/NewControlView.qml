import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0

import "qrc:/js/template_data.js" as TemplateData

Rectangle {
    id: createNewContainer
    color: "#ccc"

    ConfirmClosePopup {
        id: confirmClosePopup
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        titleText: "You have unsaved changes in " + unsavedFileCount + " files."
        popupText: "Your changes will be lost if you choose to not save them."
        acceptButtonText: "Save all"

        property int unsavedFileCount

        onPopupClosed: {
            if (closeReason === confirmClosePopup.closeFilesReason) {
                editor.openFilesModel.closeAll()
                openProjectContainer.url = sdsModel.newControlView.createNewProject(
                            fileSelector.fileUrl,
                            templateButtonGroup.checkedButton.path
                );
                toolBarListView.currentIndex = toolBarListView.editTab;
                openProjectContainer.addToTheProjectList(editor.treeModel.url.toString())
            } else if (closeReason === confirmClosePopup.acceptCloseReason) {
                editor.openFilesModel.saveAll()
                openProjectContainer.url = sdsModel.newControlView.createNewProject(
                            fileSelector.fileUrl,
                            templateButtonGroup.checkedButton.path
                );
                toolBarListView.currentIndex = toolBarListView.editTab;
                openProjectContainer.addToTheProjectList(editor.treeModel.url.toString())
            }
        }
    }

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
                    if (fileSelector.fileUrl.toString() !== "") {
                        let unsavedFileCount = editor.openFilesModel.getUnsavedCount()
                        if (unsavedFileCount > 0) {
                            confirmClosePopup.unsavedFileCount = unsavedFileCount
                            confirmClosePopup.open()
                        } else {
                            if (fileSelector.fileUrl.toString() !== "") {
                                openProjectContainer.url = sdsModel.newControlView.createNewProject(
                                            fileSelector.fileUrl,
                                            templateButtonGroup.checkedButton.path
                                );
                                toolBarListView.currentIndex = toolBarListView.editTab;
                                openProjectContainer.addToTheProjectList(editor.treeModel.url.toString())
                            }
                        }
                    }
                }
            }

            SGButton {
                text: "Cancel"

                onClicked: {
                    toolBarListView.currentIndex = -1
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

        onAccepted: {
            fileOutput.text = fileSelector.fileUrl
        }
    }
}
