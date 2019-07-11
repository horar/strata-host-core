import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import "../Components"

Window {
    id: root
    width: 400
    height: 400
    minimumWidth: 400
    minimumHeight: 400
    maximumHeight: 400
    maximumWidth: 400
    visible: false
    flags: Qt.Tool

    signal start()

    property alias url: urlContainer.userInput
    property alias username: usernameContainer.userInput
    property alias password: passwordContainer.userInput

    property string rep_type: "pull"
    property var channels: []

    function clearAllFields(){
        urlContainer.clearField()
        usernameContainer.clearField()
        passwordContainer.clearField()
    }
    function validate(){
        if(urlContainer.isEmpty() === true){
            statusBar.message = "URL field cannot be empty"
        }
        else {
            channelPopup.visible = true
            root.visible = false
        }
    }
    Rectangle {
        id: background
        anchors.fill: parent
        color: "#393e46"
        border {
            width: 2
            color: "#b55400"
        }
        StatusBar {
            id: statusBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: 25
        }
        ColumnLayout {
            spacing: 15
            width: parent.width - 10
            height: parent.height - 130
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            UserInputBox {
                id: urlContainer
                Layout.preferredHeight: 30
                Layout.preferredWidth: parent.width / 2
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                label: "URL:"
            }
            UserInputBox {
                id: usernameContainer
                Layout.preferredHeight: 30
                Layout.preferredWidth: parent.width / 2
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                label: "Username:"
            }
            UserInputBox {
                id: passwordContainer
                Layout.preferredHeight: 30
                Layout.preferredWidth: parent.width / 2
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                label: "Password:"
                isPassword: true

            }
            Button {
                id: submitButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignHCenter
                text: "Submit"
                onClicked: {
                    validate()
                    clearAllFields()
                }
            }
        }
    }
    ChannelPopup {
        id: channelPopup
        visible: false
    }
}
