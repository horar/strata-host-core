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

            let url;
            // Below handles the case where the parentNode is the .qrc file
            if (model.parentNode && !model.parentNode.isDir) {
                url = SGUtilsCpp.joinFilePath(treeModel.projectDirectory, text)
            } else {
                url = SGUtilsCpp.joinFilePath(model.parentNode.filepath, text)
            }
            let path = SGUtilsCpp.urlToLocalFile(url)
            let parentDir = SGUtilsCpp.urlToLocalFile(treeModel.parentDirectoryUrl(url))

            treeModel.stopWatchingPath(parentDir);
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
            treeModel.startWatchingPath(parentDir);
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

        MouseArea {
            id: toolTipMouse
            anchors.fill: parent
            hoverEnabled: true
        }

        ToolTip {
            id: toolTip
            x: inQrcIcon.width + 5
            y: (inQrcIcon.height - height) / 2
            visible: toolTipMouse.containsMouse
            delay: 300
            text: "This file is in the project’s QRC resource file"
        }
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
