import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../Components"

Popup {
    id: root
    height: 500
    width: 450
    visible: false
    padding: 1
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    closePolicy: Popup.CloseOnEscape
    modal: true

    signal start()
    signal clearFailedMessage()

    onClosed: {
        selectChannelsContainer.channels = []
        selectChannelsContainer.channelsLength = 0
        selectChannelsContainer.searchKeyword = ""
        loginContainer.visible = true
        selectChannelsContainer.closePopup()
        selectChannelsContainer.visible = false
        password = ""
        if (Qt.colorEqual(popupStatus.messageBackgroundColor,"darkred"))
            clearFailedMessage()
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
        color: "#222831"
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
                        warningPopup.open()
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
                warningPopup.messageToDisplay = "Warning! Starting replication will override all changes."
                warningPopup.open()
            }
            onGoBack: {
                selectChannelsContainer.visible = false
                loginContainer.visible = true
            }
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
    WarningPopup {
        id: warningPopup
        onAllow: {
            close()
            start()
        }
        onDeny: close()
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
