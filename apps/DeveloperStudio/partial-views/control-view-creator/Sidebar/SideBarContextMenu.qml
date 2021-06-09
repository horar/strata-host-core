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
        text: "Add Existing File to Qrc"
        onTriggered: {
            existingFileDialog.callerIndex = -1
            existingFileDialog.open()
            sideBarContextMenu.dismiss()
        }
    }
}
