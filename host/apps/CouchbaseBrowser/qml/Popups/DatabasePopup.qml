import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12
import Qt.labs.platform 1.0
import "../Components"
import "../Images"

CustomPopup {
    id: root

    showMaximizedBtn: false
    defaultHeight: 500
    defaultWidth: 500

    property alias folderPath: folderInputBox.userInput
    property alias dbName: dbNameInputBox.userInput

    onClosed: {
        folderInputBox.clear()
        dbNameInputBox.clear()
        if (Qt.colorEqual(popupStatus.messageBackgroundColor,"darkred")) {
            clearFailedMessage()
        }
    }

    content: ColumnLayout {
        id: mainLayout
        height: 160
        width: parent.width
        anchors.centerIn: parent

        spacing: 20
        UserInputBox {
            id: folderInputBox
            Layout.maximumHeight: 50
            Layout.preferredHeight: 50
            Layout.preferredWidth: root.width / 2
            Layout.alignment: Qt.AlignHCenter

            showButton: true
            showLabel: true
            label: "Folder Path"
            color: "goldenrod"
            placeholderText: "Enter Folder Path"
            path: "../Images/folder-icon.svg"
            onClicked: {
                folderDialog.visible = true
            }
        }
        UserInputBox {
            id: dbNameInputBox
            Layout.maximumHeight: 50
            Layout.preferredHeight: 50
            Layout.preferredWidth: root.width / 2
            Layout.alignment: Qt.AlignHCenter

            showLabel: true
            label: "Database Name"
            placeholderText: "Enter Database Name"
        }

        CustomButton {
            id: submitButton
            Layout.preferredHeight: 30
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignHCenter

            text: "Submit"
            enabled: (folderInputBox.userInput.length !== 0) && (dbNameInputBox.userInput.length !== 0)
            onClicked: submit()
        }
    }
    FolderDialog {
        id: folderDialog
        onAccepted: folderInputBox.userInput = folderDialog.folder
    }
}
