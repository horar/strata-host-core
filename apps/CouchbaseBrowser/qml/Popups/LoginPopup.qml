/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../Components"

CustomPopup {
    id: root

    showMaximizedBtn: false
    defaultHeight: 500
    defaultWidth: 450

    property alias url: urlField.userInput
    property alias username: usernameField.userInput
    property alias password: passwordField.userInput
    property alias channels: selectChannelsContainer.channels
    property alias model: selectChannelsContainer.model
    property string listenType: "pull"
    property int radioBtnSize: 30

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

    content: Item {
        width: parent.width-100
        height: parent.height-100
        anchors.centerIn: parent

        ColumnLayout {
            id: loginContainer
            anchors.fill: parent

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
            anchors.fill: parent

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
    }
    WarningPopup {
        id: warningPopup
        onAllow: {
            close()
            submit()
        }
        onDeny: close()
    }
}
