/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick.Controls 2.12
import tech.strata.commoncpp 1.0

Menu {
    id: sideBarContextMenu

    MenuItem {
        text: "Add New File to Qrc"
        onTriggered: {
            createFilePopup.open()
            sideBarContextMenu.dismiss()
        }
    }

    MenuItem {
        text: Qt.platform.os === "windows" ? "Show in Explorer" : "Show in Finder"
        onTriggered: {
            SGUtilsCpp.showFileInFolder(treeModel.projectDirectory)
        }
    }

    MenuItem {
        text: "Import Files/Folder to Project"
        onTriggered: {
            importFileOrFolderPopup.callerIndex = -1
            importFileOrFolderPopup.open()
            sideBarContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Create New Folder"
        onTriggered: {
            createFolderPopup.open()
            sideBarContextMenu.dismiss()
        }
    }
}
