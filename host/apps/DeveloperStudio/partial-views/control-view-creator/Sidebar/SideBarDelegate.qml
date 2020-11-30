import QtQuick 2.12
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
                model.filetype = SGUtilsCpp.fileSuffix(text).toLowerCase()
                if (!model.inQrc) {
                    treeModel.addToQrc(styleData.index);
                }
            }

            treeModel.stopWatchingPath(SGUtilsCpp.parentDirectoryPath(path));

            let success = SGUtilsCpp.createFile(path);
            if (!success) {
                //handle error
                console.error("Could not create file:", path)
            } else {
                model.editing = false
                openFilesModel.addTab(model.filename, model.filepath, model.filetype, model.uid)
                treeModel.addPathToTree(model.filepath)
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
                        treeView.selectItem(styleData.index)
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
                treeView.selectItem(styleData.index);
            }

            if (openFilesModel.currentId === "" && treeView.selection.currentIndex.valid) {
                // No files are selected
                treeView.selection.clearCurrentIndex()
            }
        }
    }
}
