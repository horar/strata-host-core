import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import QtQuick.Controls.Styles 1.4
import Qt.labs.folderlistmodel 2.12
import tech.strata.commoncpp 1.0
import QtQuick.Controls 1.4 as QtQC1
import QtQml.Models 2.12

import tech.strata.SGQrcTreeModel 1.0
import tech.strata.sgwidgets 1.0

Rectangle {
    id: sideBarRoot
    color: "#777"

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: treeViewContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"

            QtQC1.TreeView {
                id: treeView
                model: treeModel
                backgroundVisible: false
                alternatingRowColors: false
                width: parent.width
                height: parent.height

                Connections {
                    target: treeModel

                    // When a row is inserted, we want to focus on that row
                    onRowsInserted: {
                        treeView.selection.clearCurrentIndex();
                        console.info(parent)
                        let index = treeModel.index(first, 0, parent);
                        treeView.selection.select(index, ItemSelectionModel.Rows);
                        treeView.selection.setCurrentIndex(index, ItemSelectionModel.Current);

                        // Only set editing to true if we have created a new file and the filename is empty
                        let node = treeModel.getNode(index);
                        if (node.filename === "") {
                            treeModel.setData(index, true, SGQrcTreeModel.EditingRole);
                        } else {
                            openFilesModel.addTab(node.filename, node.filepath, node.filetype, node.uid)
                        }
                    }
                }

                selection: ItemSelectionModel {
                    model: treeModel
                }

                rowDelegate: Rectangle {
                    height: 25
                    color: styleData.selected ? "#CCCCCC" : "transparent"
                }

                itemDelegate: Item {
                    Component.onCompleted: {
                        if (model.filename === "Control.qml") {
                            openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                            treeView.selection.clearCurrentIndex();
                            treeView.selection.select(styleData.index, ItemSelectionModel.Rows);
                            treeView.selection.setCurrentIndex(styleData.index, ItemSelectionModel.Current);
                        }
                    }

                    Connections {
                        target: openFilesModel

                        onCurrentIndexChanged: {
                            if (visible && openFilesModel.currentId === model.uid) {
                                treeView.selection.clearCurrentIndex();
                                treeView.selection.select(styleData.index, ItemSelectionModel.Rows);
                                treeView.selection.setCurrentIndex(styleData.index, ItemSelectionModel.Current);
                            }
                        }
                    }

                    Text {
                        id: itemFilename
                        text: styleData.value
                        width: inQrcIcon.x - x - 10
                        height: 15
                        visible: model && !model.editing
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 10
                        color: "black"
                        elide: Text.ElideRight
                    }

                    TextInput {
                        id: itemFilenameEdit
                        width: inQrcIcon.x - x - 10
                        height: 15
                        visible: model && model.editing
                        anchors.verticalCenter: parent.verticalCenter
                        font.pointSize: 10
                        color: "black"
                        text: styleData.value
                        focus: visible
                        clip: true
                        autoScroll: activeFocus
                        readOnly: false

                        onEditingFinished: {
                            if (!model.editing) {
                                return;
                            }

                            // If a new file was created, and its filename is still empty
                            if (text === "" && model.filename === "") {
                                treeModel.removeRows(model.row, 1, styleData.index.parent);
                                return;
                            }

                            let path;
                            // Below handles the case where the parentNode is the .qrc file
                            if (model && !model.parentNode.isDir) {
                                path = SGUtilsCpp.joinFilePath(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory), displayText);
                            } else {
                                path = SGUtilsCpp.joinFilePath(SGUtilsCpp.urlToLocalFile(model.parentNode.filepath), displayText);

                            }

                            let success = SGUtilsCpp.createFile(path);
                            if (success) {
                                model.filename = displayText
                                model.filepath = SGUtilsCpp.pathToUrl(path);
                                if (!model.isDir) {
                                    model.filetype = SGUtilsCpp.fileSuffix(displayText)
                                    if (!model.inQrc) {
                                        treeModel.addToQrc(styleData.index);
                                    }
                                    openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                                }
                                model.editing = false
                            } else {
                                //handle error
                                console.error("Could not create file:", path)
                                treeModel.removeRows(model.row, 1, styleData.index.parent)
                            }
                        }

                        onFocusChanged: {
                            if (focus) {
                                forceActiveFocus();
                            } else {
                                forceActiveFocus(mouseArea);
                            }
                        }

                        onActiveFocusChanged: {
                            cursorPosition = activeFocus ? length : 0
                        }
                    }

                    SGIcon {
                        id: inQrcIcon
                        height: 15
                        width: 15
                        visible: model && !model.isDir

                        anchors {
                            verticalCenter: parent.verticalCenter
                            right: parent.right
                            rightMargin: 5
                        }

                        iconColor: model && model.inQrc ? "green" : "red"
                        source: model && model.inQrc ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/times-circle.svg"
                    }


                    Menu {
                        id: fileContextMenu

                        MenuItem {
                            text: "Add to Qrc"
                            onTriggered: {
                                treeModel.addToQrc(styleData.index);
                            }
                        }

                        MenuItem {
                            text: "Remove from Qrc"
                            onTriggered: {
                                treeModel.removeFromQrc(styleData.index);
                            }
                        }

                        MenuItem {
                            text: "Delete File"
                            onTriggered: {
                                openFilesModel.closeTab(model.uid)
                                treeModel.deleteFile(model.row, styleData.index.parent)
                            }
                        }

                        MenuSeparator {}

                        MenuItem {
                            text: "Add New File to Qrc"
                            onTriggered: {
                                treeModel.insertChild(false, -1, styleData.index.parent)
                            }
                        }

                        MenuItem {
                            text: "Add Existing File to Qrc"
                            onTriggered: {
                                existingFileDialog.callerIndex = styleData.index.parent
                                existingFileDialog.open();
                            }
                        }
                    }

                    Menu {
                        id: folderContextMenu

                        MenuItem {
                            text: "Add New File to Qrc"
                            onTriggered: {
                                if (!styleData.isExpanded) {
                                    treeView.expand(styleData.index)
                                }

                                treeModel.insertChild(false, -1, styleData.index)
                            }
                        }

                        MenuItem {
                            text: "Add Existing File to Qrc"
                            onTriggered: {
                                if (!styleData.isExpanded) {
                                    treeView.expand(styleData.index)
                                }

                                existingFileDialog.callerIndex = styleData.index
                                existingFileDialog.open();
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: {
                            if (model.filename !== "") {
                                if (mouse.button === Qt.RightButton) {
                                    if (model.isDir) {
                                        folderContextMenu.popup();
                                    } else {
                                        fileContextMenu.popup();
                                    }
                                } else if (mouse.button === Qt.LeftButton) {
                                    if (!model.isDir) {
                                        treeView.selection.clearCurrentIndex();
                                        treeView.selection.select(styleData.index, ItemSelectionModel.Rows);
                                        treeView.selection.setCurrentIndex(styleData.index, ItemSelectionModel.Current);
                                        if (openFilesModel.hasTab(model.uid)) {
                                            openFilesModel.currentId = model.uid
                                        } else {
                                            openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                                        }
                                    }
                                    forceActiveFocus()
                                }
                            }
                        }

                    }
                }

                QtQC1.TableViewColumn {
                    title: treeModel.root ? treeModel.root.filename : "Project Files"
                    role: "filename"
                    width: 250
                }
            }
        }

        FileDialog {
            id: existingFileDialog

            nameFilters: ["Qrc Item (*.qml *.js *.png *.jpg *.jpeg *.svg *.json *.txt *.gif *.html *.csv)"]
            selectExisting: true
            selectMultiple: false
            folder: treeModel.projectDirectory

            property variant callerIndex: null

            onAccepted: {
                if (callerIndex) {
                    treeModel.insertChild(fileUrl, -1, true, callerIndex)
                    callerIndex = null;
                }
            }
        }
    }
}
