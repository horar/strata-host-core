import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import Qt.labs.platform 1.0
import "../Components"
import "../Images"

Window {
    id: root
    width: 500
    height: 500
    maximumHeight: 500
    minimumHeight: 500
    maximumWidth: 500
    minimumWidth: 500
    visible: false
    flags: Qt.Tool

    signal submit()

    property alias folderPath: folderInputBox.userInput
    property alias dbName: dbNameInputBox.userInput

    property alias popupStatus: statusBar

    onClosing: { // this is not a bug
        folderInputBox.clear()
        dbNameInputBox.clear()
    }

    function validate() {
        if (folderInputBox.isEmpty() || dbNameInputBox.isEmpty()) {
            statusBar.message = "Please supply all requested information"
            statusBar.backgroundColor = "red"
        }            
        else submit()
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#393e46"
        StatusBar {
            id: statusBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: 25
        }
        ColumnLayout {
            id: mainLayout
            spacing: 10
            height: 160
            width: parent.width
            anchors.centerIn: parent

            UserInputBox {
                id: folderInputBox
                Layout.maximumHeight: 50
                Layout.preferredHeight: 50
                Layout.preferredWidth: root.width / 2
                Layout.alignment: Qt.AlignHCenter
                showButton: true
                showLabel: true
                label: "Folder Path"
                placeholderText: "Enter Folder Path"
                path: "../Images/openFolder.svg"
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
                onClicked: validate()
                enabled: (folderInputBox.userInput.length !== 0) && (dbNameInputBox.userInput.length !== 0)
            }
        }
        FolderDialog {
            id: folderDialog
            onAccepted: folderInputBox.userInput = folderDialog.folder
        }
    }
}
