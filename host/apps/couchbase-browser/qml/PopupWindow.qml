import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3

Window {
    id: root
    width: 500
    height: 500
    minimumHeight: 250
    minimumWidth: 500
    visible: false

    property string hostName
    property string databaseName
    property string userName
    property string password
    property bool valid: false
    function validate(){
        hostName = hostNameField.text
        databaseName = databaseNameField.text
        userName = usernameField.text
        password = passwordField.text
        valid = ((hostName.length == 0)||(databaseName.length == 0)||(userName.length == 0)||(password.length == 0)) ? false : true
        if(valid == true){
            hostNameField.text = ""
            databaseNameField.text = ""
            usernameField.text = ""
            passwordField.text = ""
            valid = false
            root.visible = false
        }
        else {
            popup.visible = true
        }
        console.log(hostName)
        console.log(databaseName)
        console.log(userName)
        console.log(password)
    }
    Popup {
        id: popup
        width: 300
        height: 200
        visible: false
        Label {
            text: "All fields must be valid"
            anchors.centerIn: parent
        }
    }
    Rectangle {
        anchors.fill: parent
        color: "#393e46"
        ColumnLayout {
            spacing: 1
            width: parent.width - 10
            height: implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Label {
                    text: "Please enter the requested information"
                    anchors.centerIn: parent
                    color: "white"
                }
            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: hostNameContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Host Name:"
                        color: "white"
                        anchors {
                            bottom: hostNameContainer.top
                            left: hostNameContainer.left
                        }
                    }
                    TextField {
                        id: hostNameField
                        anchors.fill: parent
                        placeholderText: "Enter Host Name"
                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: databaseNameContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Database Name:"
                        color: "white"
                        anchors {
                            bottom: databaseNameContainer.top
                            left: databaseNameContainer.left
                        }
                    }
                    TextField {
                        id: databaseNameField
                        anchors.fill: parent
                        placeholderText: "Enter Database Name"
                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: usernameContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Username:"
                        color: "white"
                        anchors {
                            bottom: usernameContainer.top
                            left: usernameContainer.left
                        }
                    }
                    TextField {
                        id: usernameField
                        anchors.fill: parent
                        placeholderText: "Enter Username"
                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: passwordContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Password:"
                        color: "white"
                        anchors {
                            bottom: passwordContainer.top
                            left: passwordContainer.left
                        }
                    }
                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        placeholderText: "Enter Password"
                        echoMode: "Password"
                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Button {
                    id: submitButton
                    height: parent.height / 2
                    width: parent.width / 4
                    text: "Submit"
                    anchors.centerIn: parent
                    onClicked: {
                        validate();
                    }
                }
            }
        }
    }
}
