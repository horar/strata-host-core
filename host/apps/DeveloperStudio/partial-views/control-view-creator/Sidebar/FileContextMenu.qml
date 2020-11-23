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
        enabled: model.inQrc
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
            model.editing = true
        }
    }

    MenuItem {
        text: "Delete File"
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
            treeModel.insertChild(false, -1, styleData.index.parent)
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
