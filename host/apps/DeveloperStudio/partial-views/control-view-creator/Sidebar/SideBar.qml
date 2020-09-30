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
                width: treeViewContainer.width
                height: treeViewContainer.height
                focus: true

                Connections {
                    target: treeModel

                    // When a row is inserted, we want to focus on that row
                    onRowsInserted: {
                        console.info("Row inserted", first, parent)
                        let index = treeModel.index(first, 0, parent);
                        treeView.selection.clearCurrentIndex();
                        treeView.selection.select(index, ItemSelectionModel.Rows);
                        treeView.selection.setCurrentIndex(index, ItemSelectionModel.Current);
                        // Only set editing to true if we have created a new file and the filename is empty
                        if (treeModel.getNode(index).filename === "") {
                            treeModel.setData(index, true, SGQrcTreeModel.EditingRole)
                        }
                    }

                    onFileAdded: {
                        if (parentPath === treeModel.projectDirectory) {
                            for (let i = 0; i < treeModel.root.childNodes.count; i++) {
                                if (treeModel.root.childNodes[i].filepath === path) {
                                    // Don't add the file because it already exists
                                    return;
                                }
                            }
                            treeModel.insertChild(path, -1, treeView.rootIndex);
                        }
                    }
                }

                headerDelegate: Rectangle {
                    height: 25
                    color: "#777"

                    Text {
                        width: parent.width
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 5
                        verticalAlignment: Text.AlignVCenter

                        text: SGUtilsCpp.fileName(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory))
                        font.pointSize: 12
                        font.bold: true
                        font.capitalization: Font.AllUppercase
                        color: "white"
                        elide: Text.ElideRight
                    }
                }

                rowDelegate: Rectangle {
                    height: 25
                    color: styleData.selected ? "#ccc" : "transparent"
                    focus: styleData.selected
                    onFocusChanged: {
                        forceActiveFocus();
                    }

                    rowDelegate: Rectangle {
                        height: 25
                        color: styleData.selected ? "#CCCCCC" : "transparent"
                        focus: styleData.selected

                        onFocusChanged: {
                            forceActiveFocus()
                        }
                    }

                    itemDelegate: Item {
                        id: itemContainer
                        anchors.verticalCenter: parent.verticalCenter

                        Component.onCompleted: {
                            if (model.filename === "Control.qml") {
                                openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                                treeView.selection.clearCurrentIndex();
                                treeView.selection.select(styleData.index, ItemSelectionModel.Rows);
                                treeView.selection.setCurrentIndex(styleData.index, ItemSelectionModel.Current);
                            }
                        }



                        Text {
                            id: itemFilename
                            text: styleData.value
                            width: inQrcIcon.x - x - 10
                            height: 15
                            visible: !itemFilenameEdit.visible
                            anchors.verticalCenter: parent.verticalCenter
                            font.pointSize: 10
                            color: "black"
                            elide: Text.ElideRight
                        }

                        TextInput {
                            id: itemFilenameEdit
                            width: inQrcIcon.x - x - 10
                            height: 15
                            visible: styleData.selected && model.editing
                            anchors.verticalCenter: parent.verticalCenter
                            font.pointSize: 10
                            color: "black"
                            text: styleData.value
                            clip: true
                            autoScroll: activeFocus
                            readOnly: false
                            // TODO: add a proper validator for editing
                            validator: RegExpValidator { regExp: /^.+$/ }


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
                                if (model.parentNode && !model.parentNode.isDir) {
                                    path = SGUtilsCpp.joinFilePath(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory), displayText);
                                } else {
                                    path = SGUtilsCpp.joinFilePath(SGUtilsCpp.urlToLocalFile(model.parentNode.filepath), displayText);

                                }
                                model.filename = displayText
                                model.filepath = SGUtilsCpp.pathToUrl(path);
                                if (!model.isDir) {
                                    model.filetype = SGUtilsCpp.fileSuffix(displayText)
                                    model.md5 = treeModel.getMd5(path);
                                    if (!model.inQrc) {
                                        treeModel.addToQrc(styleData.index);
                                    }
                                }
                                model.editing = false

                                let success = SGUtilsCpp.createFile(path);
                                if (!success) {
                                    //handle error
                                    console.error("Could not create file:", path)
                                } else {
                                    openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                                }
                            }

                            onVisibleChanged: {
                                if (visible) {
                                    forceActiveFocus();
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

                            Action {
                                text: "Add to Qrc"
                                onTriggered: {
                                    treeModel.addToQrc(styleData.index);
                                    fileContextMenu.dismiss()
                                }
                            }

                            Action {
                                text: "Remove from Qrc"
                                onTriggered: {
                                    treeModel.removeFromQrc(styleData.index);
                                    fileContextMenu.dismiss()
                                }
                            }

                            Action {
                                text: "Delete File"
                                onTriggered: {
                                    openFilesModel.closeTab(model.uid)
                                    treeModel.deleteFile(model.row, styleData.index.parent)
                                    fileContextMenu.dismiss()
                                }
                            }

                            MenuSeparator {}

                            Action {
                                text: "Add New File to Qrc"
                                onTriggered: {
                                    console.info("Adding new file")
                                    treeModel.insertChild(false, -1, styleData.index.parent)
                                    fileContextMenu.dismiss()
                                }
                            }

                            Action {
                                text: "Add Existing File to Qrc"
                                onTriggered: {
                                    existingFileDialog.callerIndex = styleData.index.parent
                                    existingFileDialog.open();
                                    fileContextMenu.dismiss()
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
                                    fileContextMenu.dismiss()
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
                                    fileContextMenu.dismiss()
                                }
                            }

                            MenuItem {
                                text: "Delete Folder"
                                onTriggered: {
                                    treeModel.deleteFile(model.row, styleData.index.parent)
                                    fileContextMenu.dismiss()
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
                                    }
                                }
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

                        Connections {
                            target: treeModel

                            onFileChanged: {
                                if (model && model.filepath === path) {
                                    // Refresh text editor if it is open
                                    model.md5 = treeModel.getMd5(SGUtilsCpp.urlToLocalFile(path))
                                }
                            }

                            onFileDeleted: {
                                if (model && model.uid === uid) {
                                    openFilesModel.closeTab(model.uid)
                                    treeModel.removeFromQrc(styleData.index)
                                    treeModel.removeRows(model.row, 1, styleData.index.parent)
                                }
                            }

                            onFileAdded: {
                                if (model && model.filepath === parentPath) {
                                    for (let i = 0; i < model.childNodes.count; i++) {
                                        if (model.childNodes[i].filepath === path) {
                                            // Don't add the file because it already exists
                                            return;
                                        }
                                    }
                                    treeModel.insertChild(path, -1, styleData.index);
                                }
                            }

                            onFileRenamed: {
                                if (model && model.filepath === oldPath) {
                                    treeModel.handleExternalRename(styleData.index, oldPath, newPath);
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
