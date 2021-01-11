import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml.Models 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
    id: itemContainer
    anchors.verticalCenter: parent.verticalCenter

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

    TextField {
        id: itemFilenameEdit
        width: inQrcIcon.x - x - 10
        height: parent.height
        visible: styleData.selected && model.editing
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: TextInput.AlignVCenter
        font.pointSize: 10
        color: "black"
        selectionColor: "#ACCEF7"
        text: styleData.value
        clip: true
        autoScroll: activeFocus
        readOnly: false

        Keys.onEscapePressed: {
            if (model.editing) {
                model.editing = false

                if (model.filename === "") {
                    treeModel.removeRows(model.row, 1, styleData.index.parent);
                    return;
                }

                text = Qt.binding(() => styleData.value)
            }
        }

        onEditingFinished: {
            if (!model.editing) {
                return;
            }

            if (text.indexOf('/') >= 0) {
                text = Qt.binding(() => styleData.value)
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

            treeModel.stopWatchingPath(SGUtilsCpp.parentDirectoryPath(path));
            // If we are creating a new file
            if (styleData.value === "") {
                const success = SGUtilsCpp.createFile(path);
                if (!success) {
                    //handle error
                    console.error("Could not create file:", path)
                } else {
                    model.editing = false
                    model.filename = text
                    model.filepath = SGUtilsCpp.pathToUrl(path);
                    if (!model.isDir) {
                        model.filetype = SGUtilsCpp.fileSuffix(text).toLowerCase();
                        if (!model.inQrc) {
                            treeModel.addToQrc(styleData.index);
                        }
                    }
                    openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                    treeModel.addPathToTree(model.filepath)
                }
            } else {
                // Else we are just renaming an already existing file
                if (text.length > 0 && styleData.value !== text) {
                    // Don't attempt to rename the file if the text is the same as the original filename
                    const success = treeModel.renameFile(styleData.index, text)
                    if (success) {
                        if (openFilesModel.hasTab(model.uid)) {
                            openFilesModel.updateTab(model.uid, model.filename, model.filepath, model.filetype)
                        } else if (model.isDir) {
                            handleRenameForOpenFiles(treeModel.getNode(styleData.index))
                        }
                    } else {
                        text = Qt.binding(() => styleData.value)
                    }
                } else {
                    text = Qt.binding(() => styleData.value)
                }

                model.editing = false
            }
            treeModel.startWatchingPath(SGUtilsCpp.parentDirectoryPath(path));
        }

        onVisibleChanged: {
            if (visible) {
                forceActiveFocus();
            }
        }

        onActiveFocusChanged: {
            cursorPosition = activeFocus ? length : 0
            if (styleData.value !== "") {
                select(0, styleData.value.replace("." + model.filetype, "").length)
            }
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
                    treeView.selectItem(styleData.index)
                    contextMenu.item.popup()
                } else if (mouse.button === Qt.LeftButton) {
                    treeView.selectItem(styleData.index)
                    if (!model.isDir) {
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

    /**
      * This function handles when directories are renamed.
      * The purpose is to make sure that all open tabs that are underneath the directory are updated
     **/
    function handleRenameForOpenFiles(node) {
        for (let i = 0; i < node.childCount(); i++) {
            let childNode = node.childNode(i);
            if (childNode.isDir) {
                handleRenameForOpenFiles(childNode)
            } else if (openFilesModel.hasTab(childNode.uid)) {
                openFilesModel.updateTab(childNode.uid, childNode.filename, childNode.filepath, childNode.filetype)
            }
        }
    }

    Connections {
        target: openFilesModel

        onCurrentIndexChanged: {
            if (visible && openFilesModel.currentId === model.uid) {
                treeView.selectItem(styleData.index);
            }

            if (openFilesModel.currentId === "" && treeView.selection.currentIndex.valid) {
                // No files are selected
                treeView.selection.clearCurrentIndex()
            }
        }
    }
}
