import QtQuick.Controls 2.12
import tech.strata.commoncpp 1.0

Menu {
    id: sideBarContextMenu

    MenuItem {
        text: "Add New File to Qrc"
        onTriggered: {
            createFilePopup.visible = true
            sideBarContextMenu.dismiss()
        }
    }

    MenuItem {
        text: "Add Existing File to Qrc"
        onTriggered: {
            // existingFileDialog.callerIndex = styleData.index.parent
            existingFileDialog.open();
            sideBarContextMenu.dismiss()
        }
    }
}
