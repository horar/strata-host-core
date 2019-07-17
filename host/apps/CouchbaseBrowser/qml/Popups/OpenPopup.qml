import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import "../Components"

Window {
    id: root
    width: 500
    height: 600
    color: "#393e46"
    flags: Qt.Tool
    visible: false

    signal submit()
    signal remove(string dbName)
    signal clear()
    property alias fileUrl: fileInputBox.userInput
    property alias popupStatus: statusBar
    property alias model: dbList.model

    StatusBar {
        id: statusBar
        anchors.bottom: parent.bottom
        width: parent.width
    }
    ColumnLayout {
        width: parent.width
        height: parent.height - 80
        DBList {
            id: dbList
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - 200
            Layout.alignment: Qt.AlignHCenter
            visible: model.count > 0
            onRemove: root.remove(dbName)
            onClear: root.clear()
            onChosenDBPathChanged: fileInputBox.userInput = chosenDBPath
        }
        UserInputBox {
            id: fileInputBox
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignHCenter
            showButton: true
            showLabel: true
            label: "File Path"
            placeholderText: "Enter File Path e.g file:///Users/abc.xyz"
            path: "../Images/openFolderIcon.png"
            onClicked: fileDialog.visible = true
        }
        Button {
            Layout.preferredWidth: 100
            Layout.preferredHeight: 40
            text: "Open"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 15
            onClicked: root.submit()
            enabled: fileUrl.length !== 0
        }
    }

    FileDialog {
        id: fileDialog
        title: "Please select a database"
        folder: shortcuts.home
        onAccepted: {
            close()
            fileInputBox.userInput = fileUrl
        }
        onRejected: close()
    }
}
