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
    visible: false
    flags: Qt.Tool
    signal submit

    //property alias folderPath: selectFolderField.userInput
    //property alias filename: filenameContainer.userInput

    property alias popupStatus: statusBar

    function validate() {
        if (selectFolderField.isEmpty() || filenameContainer.isEmpty()) {
            statusBar.message = "Please supply all requested information"
            statusBar.backgroundColor = "red"
        }            
        else submit()
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#393e46"
        border {
            width: 2
            color: "#b55400"
        }
        StatusBar {
            id: statusBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: 25
        }
        ColumnLayout {
            id: mainLayout
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

            }
            UserInputBox {
                Layout.maximumHeight: 50
                Layout.preferredHeight: 50
                Layout.preferredWidth: root.width / 2
                Layout.alignment: Qt.AlignHCenter
                showButton: false
                showLabel: true
                label: "Database Name"
                placeholderText: "Enter Database Name"
            }
            Button {
                id: submitButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 100
                Layout.topMargin: 10
                Layout.alignment: Qt.AlignHCenter
                text: "Submit"
                onClicked: {
                    folderInputBox.isEmpty()
                }

            }
        }
        FolderDialog {
            id: folderDialog
            onAccepted: selectFolderField.text = folderDialog.folder
        }
    }
}
