import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3
import QtGraphicalEffects 1.12
import Qt.labs.platform 1.0
import "../Components"
import "../Images"

Popup {
    id: root
    width: 500
    height: 500
    visible: false
    padding: 1
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    closePolicy: Popup.CloseOnEscape
    modal: true

    signal submit()
    signal clearFailedMessage()

    property alias folderPath: folderInputBox.userInput
    property alias dbName: dbNameInputBox.userInput

    property alias popupStatus: statusBar

    onClosed: {
        folderInputBox.clear()
        dbNameInputBox.clear()
        if (Qt.colorEqual(popupStatus.messageBackgroundColor,"darkred")) {
            clearFailedMessage()
        }
    }

    Rectangle {
        id: container
        anchors.fill: parent
        color: "#222831"
        StatusBar {
            id: statusBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: 25
        }
        ColumnLayout {
            id: mainLayout
            spacing: 20
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
                color: "goldenrod"
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
                onClicked: submit()
                enabled: (folderInputBox.userInput.length !== 0) && (dbNameInputBox.userInput.length !== 0)
            }
        }
        FolderDialog {
            id: folderDialog
            onAccepted: folderInputBox.userInput = folderDialog.folder
        }
        Button {
            id: closeBtn
            height: 20
            width: 20
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 20
                rightMargin: 20
            }

            background: Rectangle {
                height: parent.height + 6
                width: parent.width + 6
                radius: width/2
                anchors.centerIn: parent
                color: closeBtn.hovered ? "white" : "transparent"
                Image {
                    id: icon
                    height: closeBtn.height
                    width: closeBtn.width
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/qml/Images/close.svg"
                }
            }
            onClicked: root.close()
        }
    }
    DropShadow {
        anchors.fill: container
        source: container
        horizontalOffset: 7
        verticalOffset: 7
        spread: 0
        radius: 20
        samples: 41
        color: "#aa000000"
    }
}
