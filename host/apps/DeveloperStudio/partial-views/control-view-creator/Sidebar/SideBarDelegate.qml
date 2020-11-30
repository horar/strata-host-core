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
        text: model ? model.filename : ""
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

                text = model.filename
            }
        }

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

            // If we are creating a new file
            if (model.filename === "") {

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
                }
            } else {
                // Else we are just renaming an already existing file
                if (text.length > 0 && model.filename !== text) {
                    // Don't attempt to rename the file if the text is the same as the original filename
                    const success = treeModel.renameFile(styleData.index, text)
                    if (success) {
                        if (openFilesModel.hasTab(model.uid)) {
                            openFilesModel.updateTab(model.uid, model.filename, model.filepath, model.filetype)
                        }
                    } else {
                        text = model.filename
                    }
                } else {
                    text = model.filename
                }

                model.editing = false
            }
        }

        onVisibleChanged: {
            if (visible) {
                forceActiveFocus();
            }
        }

        onActiveFocusChanged: {
            cursorPosition = activeFocus ? length : 0
            if (model.filename !== "") {
                select(0, model.filename.replace("." + model.filetype, "").length)
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
