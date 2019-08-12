import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../Components"

Popup {
    id: root
    height: 500
    width: 450
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    visible: false
    padding: 1
    closePolicy: Popup.CloseOnEscape
    modal: true

    property alias url: urlField.userInput
    property alias username: usernameField.userInput
    property alias password: passwordField.userInput
    property alias channels: selectChannelsContainer.channels
    property alias model: selectChannelsContainer.model
    property alias popupStatus: statusBar
    property string listenType: "pull"
    property int radioBtnSize: 30

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
        if (Qt.colorEqual(popupStatus.messageBackgroundColor,"darkred")) {
            clearFailedMessage()
        }
    }
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
        z: 1

        color: "#222831"
        ColumnLayout {
            id: loginContainer
            width: parent.width - 100
            height: parent.height - 130
            anchors.centerIn: parent

            visible: true
            spacing: 15
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
                    Layout.preferredWidth: parent.height/3
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter

                    text: "Push"
                    color: "#eee"
                }
                Label {
                    Layout.preferredWidth: parent.height/3
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                    text: "Pull"
                    color: "#eee"
                }
                Label {
                    Layout.preferredWidth: parent.height/3
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter

                    text: "Push & Pull"
                    color: "#eee"
                }
            }
            RowLayout {
                Layout.maximumHeight: 30
                Layout.maximumWidth: parent.width
                Layout.alignment: Qt.AlignHCenter

                spacing: 5
                CustomButton {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    text: "All channels"
                    enabled: url.length !== 0
                    onClicked: {
                        warningPopup.messageToDisplay = "Warning! Starting replication will override all changes."
                        warningPopup.open()
                    }
                }
                CustomButton {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    text: "Choose channels"
                    enabled: url.length !== 0
                    onClicked: {
                        loginContainer.visible = false
                        selectChannelsContainer.visible = true
                    }
                }
            }
        }
        ChannelSelector {
            id: selectChannelsContainer
            width: parent.width
            height: parent.height
            anchors.centerIn: parent

            visible: false
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

            onClicked: root.close()
            background: Rectangle {
                height: parent.height + 6
                width: parent.width + 6
                anchors.centerIn: parent

                radius: width/2
                color: closeBtn.hovered ? "white" : "transparent"
                SGIcon {
                    id: icon
                    height: closeBtn.height
                    width: closeBtn.width
                    anchors.centerIn: parent

                    fillMode: Image.PreserveAspectFit
                    iconColor: "darkred"
                    source: "qrc:/qml/Images/close.svg"
                }
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
