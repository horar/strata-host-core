import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import com.onsemi 1.0

Window {
    id: root
    visible: true

    width: 600
    height: 400
    maximumHeight: height
    maximumWidth: width
    minimumHeight: height
    minimumWidth: width

    title: qsTr("Chat")

    Column {
        Rectangle {
            id: userName
            height: 30
            width: root.width

            Text {
                id: userNameText
                text: "User: " + couchChat.user_name
                topPadding: 8
                leftPadding: 8
                color: "blue"
                font.bold: true
                font.pointSize: 14
            }
        }

        Rectangle {
            id: chatroom
            height: 30
            width: root.width

            Text {
                id: chatroomNameText
                text: "Chatroom: " + couchChat.channel_name
                topPadding: 8
                leftPadding: 8
                color: "blue"
                font.bold: true
                font.pointSize: 14
            }
        }

        ScrollView {
            id: chatScrollView
            height: 330 - userName.height - chatroom.height
            width: parent.width
            clip: true

            TextArea {
                id: chatBoxText
                height: 300
                width: root.width
                textFormat: TextEdit.RichText
                wrapMode: TextEdit.Wrap
                readOnly: true
                font.pointSize: 12
                Component.onCompleted: chatBoxText.clear()
            }
        }

        Row {
            TextField {
                id: inputField
                height: 70
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
                text: qsTr("Send")
                enabled: inputField.text !== ""

                onClicked: {
                    couchChat.sendMessage(inputField.text)
                    inputField.text = ""
                }
            }
        }
    }

    Connections {
        target: couchChat

        onReceivedMessage: {
            console.info("Received message: " + message)
            chatBoxText.text += "\n\n" + message
        }
    }
}
