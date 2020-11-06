import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import com.onsemi 1.0

Item {
    property var stackContainerRef

    Rectangle {
        id: background
        anchors.fill: parent
        color: "lightgrey"
    }

    Column {
        id: mainColumn
        spacing: 30
        anchors.left: parent.left

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
                    width: 540
                    height: 40
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

            Rectangle {
                border.width: 1
                border.color: "black"

                Layout.leftMargin: 30
                Layout.preferredHeight: 30

                TextField {
                    id: chatroomTextfield
                    text: ""
                    selectByMouse: true
                    width: 540
                    height: 40
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
                    text: "ws://localhost:4984/couch-chat-server"
                    selectByMouse: true
                    width: 540
                    height: 40
                }
            }
        }

        Button {
            id: loginButton
            height: 60
            width: 150
            x: 30

            enabled: {
                if (usernameTextfield.text !== "" && chatroomTextfield.text !== "" && chatserverTextfield.text !== "") {
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
                text: qsTr("Login")
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
                    couchChat.loginAndStartReplication(usernameTextfield.text, chatroomTextfield.text, chatserverTextfield.text)
                    stackContainerRef.currentIndex = 1
                }
            }
        }
    }
}
