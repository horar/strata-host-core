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
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    visible: false
    padding: 1
    closePolicy: Popup.CloseOnEscape
    modal: true

    property alias folderPath: folderInputBox.userInput
    property alias dbName: dbNameInputBox.userInput
    property alias popupStatus: statusBar

    signal submit()
    signal clearFailedMessage()

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
            width: parent.width
            height: 25
            anchors.bottom: parent.bottom
        }
        ColumnLayout {
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
                enabled: (folderInputBox.userInput.length !== 0) && (dbNameInputBox.userInput.length !== 0)
                onClicked: submit()
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

            onClicked: root.close()
            background: Rectangle {
                height: parent.height + 6
                width: parent.width + 6
                anchors.centerIn: parent

                radius: width/2
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
        }
    }
    DropShadow {
        anchors.fill: container
        horizontalOffset: 7
        verticalOffset: 7
        source: container
        spread: 0
        radius: 20
        samples: 41
        color: "#aa000000"
    }
}
