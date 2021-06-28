import QtQuick.Controls 2.12
import tech.strata.commoncpp 1.0

Menu {
    id: fileContextMenu

    MenuItem {
        text: "Add to Qrc"
        enabled: !model.inQrc && model.filetype !== "rcc"
        onTriggered: {
            treeModel.addToQrc(styleData.index)
            fileContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Remove from Qrc"
        enabled: model.inQrc && renameFileMenuItem.enabled
        onTriggered: {
            treeModel.removeFromQrc(styleData.index)
            fileContextMenu.dismiss()
        }
    }

    MenuItem {
        id: renameFileMenuItem
        text: "Rename File"
        enabled: {
            if (model.filetype === "rcc") {
                // If file has rcc extension, disable rename/remove from qrc/delete
                return false
            } else if (model.filename === "Control.qml" && SGUtilsCpp.parentDirectoryPath(SGUtilsCpp.urlToLocalFile(model.filepath)) === SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory, false)) {
                // If file is Control.qml in the project root, disable rename/remove from qrc/delete
                return false
            }
            return true
        }
        onTriggered: {
            treeView.selectItem(styleData.index)
            model.editing = true
        }
    }

    MenuItem {
        text: "Delete File"
        enabled: renameFileMenuItem.enabled
        onTriggered: {
            confirmDeleteFile.deleteType = "File"
            confirmDeleteFile.fileName = model.filename
            confirmDeleteFile.uid = model.uid
            confirmDeleteFile.row = model.row
            confirmDeleteFile.index = styleData.index.parent

            confirmDeleteFile.open()
            fileContextMenu.dismiss()
        }
    }

    MenuSeparator {}

    MenuItem {
        text: "Add New File to Qrc"
        onTriggered: {
            createFilePopup.open()
            fileContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Add Existing File to Qrc"
        onTriggered: {
            existingFileDialog.callerIndex = styleData.index.parent
            existingFileDialog.open()
            fileContextMenu.dismiss()
        }
    }
}
