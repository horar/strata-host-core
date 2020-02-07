import QtQuick 2.12
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.0 as QtLabsSettings

Item {
    property alias fileDialog: fileDialog

    FileDialog {
        id: fileDialog

        title: qsTr("Please choose a file")
        folder: shortcuts.documents
        selectFolder: true
        selectMultiple: false

        onAccepted: {
            selectedDir.text = "Files will be downloaded to: " + fileDialog.fileUrl
        }
    }

    QtLabsSettings.Settings {
        category: "QQControlsFileDialog"

        property alias lastDownloadFolder: fileDialog.folder
    }
}

