import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import com.onsemi 1.0

Item {
    property var stackContainerRef

    Column {
        Row {
            Column {
                Rectangle {
                    id: userName
                    height: 30
                    width: root.width - logoutButton.width

                    Text {
                        id: userNameText
                        text: "User: " + couchChat.user_name
                        topPadding: 8
                        leftPadding: 8
                        font.bold: true
                        font.pointSize: 14
                    }
                }

                Rectangle {
                    id: chatroom
                    height: 30
                    width: root.width - logoutButton.width

                    Text {
                        id: chatroomNameText
                        text: "Chatroom: " + couchChat.channel_name
                        topPadding: 8
                        leftPadding: 8
                        font.bold: true
                        font.pointSize: 14
                    }
                }
            }

            Button {
                id: logoutButton
                height: userName.height + chatroom.height
                width: 120

                background: Rectangle {
                    anchors.fill: parent

                    color: {
                        if (!logoutButton.enabled) {
                            return "lightgrey"
                        } else {
                            return logoutButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                        }
                    }
                }

                contentItem: Text {
                    text: qsTr("Logout")
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: logoutButtonMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: {
                        stackContainerRef.currentIndex = 0
                        couchChat.logoutAndStopReplication()
                    }
                }
            }
        }

        Rectangle { // separator
            height: 5
            color: "black"
            width: root.width
        }

        Flickable {
            id: chatScrollView
            height: 330 - userName.height - chatroom.height
            width: parent.width

            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}
            TextArea.flickable: TextArea {
                id: chatBoxText
                height: 300
                width: root.width
                textFormat: TextEdit.RichText
                font.pointSize: 12
                readOnly: true
            }
        }

        Rectangle { // separator
            height: 5
            color: "black"
            width: root.width
        }

        Row {
            TextField {
                id: inputField
                height: 60
                width: root.width - sendButton.width
                font.pointSize: 12

                placeholderText: qsTr("Enter Message...")

                onAccepted: {
                    if (inputField.text !== "") {
                        couchChat.sendMessage(inputField.text)
                        inputField.text = ""
                    }
                }
            }

            Button {
                id: sendButton
                height: inputField.height
                width: 120
                enabled: inputField.text !== ""

                background: Rectangle {
                    anchors.fill: parent

                    color: {
                        if (!sendButton.enabled) {
                            return "lightgrey"
                        } else {
                            return sendButtonMouseArea.containsMouse ? Qt.darker("grey", 1.5) : "grey"
                        }
                    }
                }

                contentItem: Text {
                    text: qsTr("Send")
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    id: sendButtonMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                    onClicked: {
                        couchChat.sendMessage(inputField.text)
                        inputField.text = ""
                    }
                }
            }
        }
    }

    Connections {
        target: couchChat

        onReceivedMessage: {
            if (!user || !message) {
                console.info("Received incorrect message")
            } else {
                console.info("Received message: " + message)
                chatBoxText.text += user === couchChat.user_name ? "<b>You</b> say:<br><b>" + message + "</b><br><br>" : "User <b>" + user + "</b> says:<br><b>" + message + "</b><br><br>"
            }
        }
    }
}
