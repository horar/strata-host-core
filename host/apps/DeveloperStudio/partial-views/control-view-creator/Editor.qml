import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "Editor/"

Item {
    id: editorRoot

    function setVisible (index) {
        let file = fileModel.get(index);

        if (file.open === false) {
            file.open = true
        }

        for (let i = 0; i < fileModel.count; i++) {
            fileModel.get(i).visible = (i === index)
        }
        fileStack.currentIndex = openFileModel.mapIndexFromSource(index)
    }

    ColumnLayout {
        anchors.fill: parent

        spacing: 0

        Rectangle {
            id: editorControlBar
            Layout.preferredHeight: 45
            Layout.fillWidth: true
            color: "#777"

            RowLayout {
                x:2.5
                height: parent.height

                SGButton {
                    id: saveButton
                    text: "Save file"
                }

                SGButton {
                    text: "Undo"
                }

                SGButton {
                    text: "Redo"
                }
            }
        }

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 0

            SideBar {
                id: sideBar
                Layout.fillHeight: true
                Layout.preferredWidth: 250
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    color: "#777"

                    RowLayout {
                        height: parent.height
                        x:2.5

                        ButtonGroup { id: buttonGroup }

                        Repeater {
                            id: fileTabRepeater
                            model: openFileModel

                            delegate: SGButton {
                                // TODO: create more appropriate tab delegate with closer
                                checked: model.visible
                                ButtonGroup.group: buttonGroup
                                text: model.filename

                                property int modelIndex: index

                                onClicked: {
                                    if (checked) {
                                        editorRoot.setVisible(openFileModel.mapIndexToSource(modelIndex))
                                    }
                                }
                            }
                        }
                    }
                }

                StackLayout {
                    id: fileStack
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Repeater {
                        id: fileEditorRepeater
                        model: openFileModel

                        delegate: Component {
                            Loader {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                source: switch(model.filetype) {
                                    case "svg":
                                    case "jpg":
                                    case "jpeg":
                                    case "png":
                                    case "gif":
                                        return "./Editor/ImageContainer.qml"
                                    case "qml":
                                    case "csv":
                                    case "html":
                                    case "txt":
                                    case "json":
                                        return "./Editor/TextEditorContainer.qml"
                                    default:
                                        return "./Editor/UnsupportedFileType.qml"
                                }
                            }
                        }
                    }
                }

                SGSortFilterProxyModel {
                    id: openFileModel
                    sourceModel: fileModel
                    invokeCustomFilter: true

                    function filterAcceptsRow(index) {
                        let listElement = sourceModel.get(index)
                        return file_open(listElement)
                    }

                    function file_open(listElement) {
                        return listElement.open
                    }
                }
            }
        }
    }
}
