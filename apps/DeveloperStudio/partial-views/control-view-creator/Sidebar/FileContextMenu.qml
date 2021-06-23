import QtQuick.Controls 2.12
import tech.strata.commoncpp 1.0

Menu {
    id: fileContextMenu

    MenuItem {
        text: "Add to Qrc"
        enabled: !model.inQrc && model.filetype !== "rcc"
        onTriggered: {
            treeModel.addToQrc(styleData.index);
            fileContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Remove from Qrc"
        enabled: model.inQrc && model.filename !== "Control.qml"
        onTriggered: {
            treeModel.removeFromQrc(styleData.index);
            fileContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Rename File"
        enabled: !(model.filename === "Control.qml" && SGUtilsCpp.parentDirectoryPath(SGUtilsCpp.urlToLocalFile(model.filepath)) === SGUtilsCpp.urlToLocalFile(treeModel.projectDirectory))
        onTriggered: {
            treeView.selectItem(styleData.index)

            renameFilePopup.renameType = "File"
            renameFilePopup.modelIndex = styleData.index
            renameFilePopup.uid = model.uid
            renameFilePopup.fileName = model.filename
            renameFilePopup.fileExtension = model.filetype
            renameFilePopup.directoryPath = model.filepath
            renameFilePopup.open()
            fileContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Delete File"
        enabled: model.filename !== "Control.qml"
        onTriggered: {
            openFilesModel.closeTab(model.uid)
            treeModel.deleteFile(model.row, styleData.index.parent)
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
            existingFileDialog.open();
            fileContextMenu.dismiss()
        }
    }
}
