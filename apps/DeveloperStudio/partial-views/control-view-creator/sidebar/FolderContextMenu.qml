/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick.Controls 2.12
import tech.strata.commoncpp 1.0

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
        text: "Import Files/Folder to Project"
        onTriggered: {
            treeView.selectItem(styleData.index)
            if (!styleData.isExpanded) {
                treeView.expand(styleData.index)
            }

            importFileOrFolderPopup.callerIndex = styleData.index
            importFileOrFolderPopup.open()
            folderContextMenu.dismiss()
        }
    }

    MenuItem {
        text: Qt.platform === "windows" ? "Show in Explorer" : "Show in Finder"
        onTriggered: {
            SGUtilsCpp.showFileInFolder(model.filepath)
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
