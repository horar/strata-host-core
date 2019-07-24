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
        model.clear()
        channels = []
        selectChannelsContainer.selected = 0
        loginContainer.visible = true
        selectChannelsContainer.closePopup()
        selectChannelsContainer.visible = false
        password = ""
    }

    property alias url: urlField.userInput
    property alias username: usernameField.userInput
    property alias password: passwordField.userInput
    property string listenType: "pull"
    property alias channels: selectChannelsContainer.channels
    property alias model: selectChannelsContainer.model
    property int radioBtnSize: 30
    property alias popupStatus: statusBar
    StatusBar {
        id: statusBar
        anchors.bottom: container.bottom
        width: parent.width
        height: 25
        z: 2
    }

    Rectangle {
        id: container
        height: parent.height
        width: parent.width
        color: "#393e46"
        z: 1
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
                CustomButton {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    text: "All channels"
                    onClicked: {
                        warningPopup.messageToDisplay = "Warning! Starting replication will override all changes."
                        warningPopup.show()
                    }
                    enabled: url.length !== 0
                }
                CustomButton {
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
        ChannelSelector {
            id: selectChannelsContainer
            visible: false
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
            onSubmit: {
                warningPopup.messageToDisplay = "Warning! Starting replication will override all changes." + (channels.length !== 0 ? "" :
                    "\nAre you sure that you want to select no channel?\nIf you select no channel, all channels will be selected")
                warningPopup.show()
            }
            onGoBack: {
                selectChannelsContainer.visible = false
                loginContainer.visible = true
            }
        }
    }
    WarningPopup {
        id: warningPopup
        onAllow: {
            close()
            start()
        }
        onDeny: close()
    }
}
