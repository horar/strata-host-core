import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import "../Components"

Window {
    id: root
    maximumHeight: 450
    minimumHeight: 450
    maximumWidth: 400
    minimumWidth: 400
    flags: Qt.Tool
    visible: false

    signal start()
    onClosing: { // This is not a bug
        loginContainer.visible = true
        selectChannelsContainer.visible = false
        password = ""
    }

    property alias url: urlField.userInput
    property alias username: usernameField.userInput
    property alias password: passwordField.userInput
    property string listenType: "pull"
    property alias channels: selectChannelsContainer.channels
    property int radioBtnSize: 30
    property alias popupStatus: statusBar

    Rectangle {
        id: container
        height: parent.height - statusBar.height
        width: parent.width
        color: "#393e46"
        ColumnLayout {
            id: loginContainer
            visible: true
            spacing: 15
            width: parent.width - 100
            height: parent.height - 130
            anchors.centerIn: parent

            UserInputBox {
                id: urlField
                Layout.preferredHeight: 30
                Layout.preferredWidth: parent.width - 60
                Layout.alignment: Qt.AlignHCenter
                showLabel: true
                label: "URL (required)"
                placeholderText: "Enter URL"
            }
            UserInputBox {
                id: usernameField
                Layout.preferredHeight: 30
                Layout.preferredWidth: parent.width - 60
                Layout.alignment: Qt.AlignHCenter
                showLabel: true
                label: "Username"
                placeholderText: "Enter Username"
            }
            UserInputBox {
                id: passwordField
                Layout.preferredHeight: 30
                Layout.preferredWidth: parent.width - 60
                Layout.alignment: Qt.AlignHCenter
                showLabel: true
                label: "Password"
                placeholderText: "Enter Password"
                isPassword: true
            }

            GridLayout {
                id: selectorContainer
                Layout.preferredHeight: 30
                Layout.preferredWidth: parent.width - 60
                Layout.alignment: Qt.AlignHCenter
                rows: 2
                columns: 3

                RadioButton {
                    id: pushButton
                    height: radioBtnSize
                    width: radioBtnSize
                    Layout.alignment: Qt.AlignCenter
                    checked: listenType === "push"
                    onClicked: listenType = "push"
                }
                RadioButton {
                    id: pullButton
                    height: radioBtnSize
                    width: radioBtnSize
                    Layout.alignment: Qt.AlignCenter
                    checked: listenType === "pull"
                    onClicked: listenType = "pull"
                }
                RadioButton {
                    id: pushAndPullButton
                    height: radioBtnSize
                    width: radioBtnSize
                    Layout.alignment: Qt.AlignCenter
                    checked: listenType === "pushpull"
                    onClicked: listenType = "pushpull"
                }

                Label {
                    text: "Push"
                    color: "#eee"
                    Layout.preferredWidth: parent.height/3
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    text: "Pull"
                    color: "#eee"
                    Layout.preferredWidth: parent.height/3
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                Label {
                    text: "Push & Pull"
                    color: "#eee"
                    Layout.preferredWidth: parent.height/3
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            RowLayout {
                spacing: 5
                Layout.maximumHeight: 30
                Layout.maximumWidth: parent.width
                Layout.alignment: Qt.AlignHCenter
                Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "All channels"
                    onClicked: warningPopup.visible = true
                    enabled: url.length !== 0
                }
                Button {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "Choose channels"
                    onClicked: {
                        loginContainer.visible = false
                        selectChannelsContainer.visible = true
                    }
                    enabled: url.length !== 0
                }
            }
        }

        ChannelSelector{
            id: selectChannelsContainer
            visible: false
            height: parent.height - 130
            width: parent.width/2
            anchors.centerIn: parent
            onSubmit: warningPopup.visible = true
        }
    }
    StatusBar {
        id: statusBar
        anchors.top: container.bottom
        width: parent.width
        height: 25
    }

    WarningPopup {
        id: warningPopup
        messageToDisplay: "Warning! Starting replication will override all changes."
        onAllow: {
            close()
            start()
        }
        onDeny: close()
    }
}
