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
            existingFileDialog.open()
            folderContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Rename Folder"
        onTriggered: {
            treeView.selectItem(styleData.index)
            if (!styleData.isExpanded) {
                treeView.expand(styleData.index)
            }

            renameFilePopup.renameType = "Folder"
            renameFilePopup.modelIndex = styleData.index
            renameFilePopup.uid = model.uid
            renameFilePopup.fileName = model.filename
            renameFilePopup.fileExtension = model.filetype
            renameFilePopup.directoryPath = model.filepath
            renameFilePopup.open()
            folderContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Delete Folder"
        onTriggered: {
            confirmDeleteFile.deleteType = "Folder"
            confirmDeleteFile.fileName = model.filename
            confirmDeleteFile.uid = model.uid
            confirmDeleteFile.row = model.row
            confirmDeleteFile.index = styleData.index.parent

            confirmDeleteFile.open()
            folderContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Create New Folder"
        onTriggered: {
            createFolderPopup.folderPath = model.filepath
            createFolderPopup.open()
            folderContextMenu.dismiss()
        }
    }
}
