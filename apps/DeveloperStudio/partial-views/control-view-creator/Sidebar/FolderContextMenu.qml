import QtQuick.Controls 2.12

Menu {
    id: folderContextMenu

    MenuItem {
        text: "Add New File to Qrc"
        onTriggered: {
            if (!styleData.isExpanded) {
                treeView.expand(styleData.index)
            }

            createFilePopup.directoryPath = model.filepath
            createFilePopup.open()
            folderContextMenu.dismiss()
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
            folderContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Rename Folder"
        onTriggered: {
            treeView.selectItem(styleData.index)
            model.editing = true
        }
    }

    MenuItem {
        text: "Delete Folder"
        onTriggered: {
            treeModel.deleteFile(model.row, styleData.index.parent)
            folderContextMenu.dismiss()
        }
    }
}
