import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import com.onsemi 1.0

Item {
    id: root
    property var stackContainerRef
    property var channels_access_granted: []
    property bool loggedIn: false
    property bool joinedChatroom: false

    Rectangle {
        id: background
        anchors.fill: parent
        color: "lightgrey"
    }

    Column {
        id: mainColumn
        spacing: 30
        anchors.left: parent.left

        RowLayout {
            ColumnLayout {
                id: usernameInput
                spacing: -10

                Label {
                    color: "black"
                    visible: true
                    text: "Username"

                    Layout.leftMargin: 30
                    Layout.topMargin: 30
                    Layout.preferredHeight: 30
                }

                Rectangle {
                    border.width: 1
                    border.color: "black"

                    Layout.leftMargin: 30
                    Layout.preferredHeight: 30

                    TextField {
                        id: usernameTextfield
                        text: ""
                        selectByMouse: true
                        width: 300
                        height: 40
                        enabled: !loggedIn
                    }
                }
            }

            Button {
                id: loginButton
                Layout.leftMargin: 320 - 70
                Layout.topMargin: 60
                Layout.preferredHeight: 40
                Layout.preferredWidth: 150

                enabled: {
                    if (usernameTextfield.text !== "" && chatserverTextfield.text !== "") {
                        return true;
                    } else {
                        return false;
                    }
                }

                background: Rectangle {
                    anchors.fill: parent
                    color: loginButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                }

                contentItem: Text {
                    text: loggedIn ? qsTr("Logout") : qsTr("Login")
                    color: loginButton.enabled ? "white" : "lightgrey"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: loginButtonMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: {
                        if (!loggedIn) {
                            root.channels_access_granted = couchChat.readChannelsAccessGrantedOfUser(usernameTextfield.text)
                            loggedIn = true
                        } else {
                            root.channels_access_granted = []
                            loggedIn = false
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: chatserverInput
            spacing: -10

            Label {
                color: "black"
                visible: true
                text: "Chat server"

                Layout.leftMargin: 30
                Layout.preferredHeight: 30
            }

            Rectangle {
                border.width: 1
                border.color: "black"

                Layout.leftMargin: 30
                Layout.preferredHeight: 30
                Layout.bottomMargin: 30

                TextField {
                    id: chatserverTextfield
                    text: "ws://localhost:4984/chatroom-app"
                    selectByMouse: true
                    width: 300
                    height: 40
                    enabled: !loggedIn
                }
            }
        }

        ColumnLayout {
            id: chatroomInput
            spacing: -10

            Label {
                color: "black"
                visible: true
                text: "Chat room"

                Layout.leftMargin: 30
                Layout.preferredHeight: 30
            }

            ComboBox {
                id: chatroomCombobox
                width: 300
                Layout.leftMargin: 30
                Layout.preferredHeight: 30
                enabled: loggedIn && root.channels_access_granted.length > 0
                model: root.channels_access_granted
            }
        }

        Button {
            id: joinButton
            height: 60
            width: 150
            x: 30

            enabled: {
                if (loggedIn && usernameTextfield.text !== "" && chatserverTextfield.text !== "" && chatroomCombobox.currentText !== "") {
                    return true;
                } else {
                    return false;
                }
            }

            background: Rectangle {
                anchors.fill: parent
                color: joinButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
            }

            contentItem: Text {
                text: qsTr("Join chat room")
                color: joinButton.enabled ? "white" : "lightgrey"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                id: joinButtonMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                onClicked: {
                    couchChat.login(usernameTextfield.text, chatroomCombobox.currentText)
                    stackContainerRef.currentIndex = 1
                }
            }
        }
    }

    Connections {
        target: couchChat

        onReceivedDbContents: {
            root.channels_access_granted = allChannelsGranted
        }
    }
}
