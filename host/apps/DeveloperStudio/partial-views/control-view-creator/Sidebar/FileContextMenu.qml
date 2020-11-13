import QtQuick.Controls 2.12

Menu {
    id: fileContextMenu

    MenuItem {
        text: "Add to Qrc"
        enabled: !model.inQrc
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
