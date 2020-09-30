import QtQuick.Controls 2.12

Menu {
    id: folderContextMenu

    MenuItem {
        text: "Add New File to Qrc"
        onTriggered: {
            if (!styleData.isExpanded) {
                treeView.expand(styleData.index)
            }

            treeModel.insertChild(false, -1, styleData.index)
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
        text: "Delete Folder"
        onTriggered: {
            treeModel.deleteFile(model.row, styleData.index.parent)
            folderContextMenu.dismiss()
        }
    }
}
