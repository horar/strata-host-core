import QtQuick 2.12
import QtQml.Models 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
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
        verticalAlignment: Text.AlignVCenter
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
        verticalAlignment: TextInput.AlignVCenter
        font.pointSize: 10
        color: "black"
        text: styleData.value
        clip: true
        autoScroll: activeFocus
        readOnly: false

        onEditingFinished: {
            if (!model.editing) {
                return;
            }

            if (text.indexOf('/') >= 0) {
                text = model.filename
            }

            // If a new file was created, and its filename is still empty
            if (text === "" && model.filename === "") {
                treeModel.removeRows(model.row, 1, styleData.index.parent);
                return;
            }

            let path;
            // Below handles the case where the parentNode is the .qrc file
            if (model.parentNode && !model.parentNode.isDir) {
                path = SGUtilsCpp.joinFilePath(SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory), text);
            } else {
                path = SGUtilsCpp.joinFilePath(SGUtilsCpp.urlToLocalFile(model.parentNode.filepath), text);

            }
            model.filename = text
            model.filepath = SGUtilsCpp.pathToUrl(path);
            if (!model.isDir) {
                model.filetype = SGUtilsCpp.fileSuffix(text)
                model.md5 = treeModel.getMd5(path);
                if (!model.inQrc) {
                    treeModel.addToQrc(styleData.index);
                }
            }

            let success = SGUtilsCpp.createFile(path);
            if (!success) {
                //handle error
                console.error("Could not create file:", path)
            } else {
                model.editing = false
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
        visible: model && !model.isDir && model.inQrc

        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: 5
        }

        iconColor: "green"
        source: "qrc:/sgimages/check-circle.svg"
    }

    Loader {
        id: contextMenu
        source: {
            if (!model) {
                return ""
            } else if (model.isDir) {
                return "./FolderContextMenu.qml"
            } else {
                return "./FileContextMenu.qml"
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
                    contextMenu.item.popup()
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
                if (!model.isDir) {
                    openFilesModel.closeTab(model.uid)
                }
                treeModel.removeFromQrc(styleData.index)
                treeModel.removeRows(model.row, 1, styleData.index.parent)
                treeModel.startSave();
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
                treeModel.insertChild(path, -1, false, styleData.index);
            }
        }

        onFileRenamed: {
            if (model && model.filepath === oldPath) {
                treeModel.handleExternalRename(styleData.index, oldPath, newPath);
            }
        }
    }
}
