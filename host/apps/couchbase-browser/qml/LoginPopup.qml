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

    signal start()

    property alias hostName: hostNameField.text
    property alias username: usernameField.text
    property alias password: passwordField.text
    property alias push: pushButton.checked
    property alias pull: pullButton.checked
    property alias pushAndPull: pushAndPullButton.checked

    function clearInput()
    {
        hostNameField.text = ""
        usernameField.text = ""
        passwordField.text = ""
    }

    function validate(){
        if(hostName.length !== 0){
            start();
        }
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
                    id: usernameContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Username:"
                        color: "#eee"
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
                Rectangle {
                    id: selectorContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    color: "transparent"
                    anchors {
                        centerIn: parent
                        verticalCenterOffset: -10
                    }
                    RowLayout {
                        anchors.fill: parent

                        RadioButton {
                            id: pushButton
                            text: qsTr("")
                            Layout.alignment: Qt.AlignLeft
                        }
                        RadioButton {
                            id: pushAndPullButton
                            checked: true
                            text: qsTr("")
                            Layout.alignment: Qt.AlignHCenter
                        }
                        RadioButton {
                            id: pullButton
                            text: qsTr("")
                            Layout.alignment: Qt.AlignRight
                        }
                    }
                    Label {
                        id: pushLabel
                        text: "Push"
                        color: "#eee"
                        anchors {
                            top: selectorContainer.bottom
                            left: selectorContainer.left
                            leftMargin: 10
                        }
                    }
                    Label {
                        id: pullLabel
                        text: "Pull"
                        color: "#eee"
                        anchors {
                            top: selectorContainer.bottom
                            right: selectorContainer.right
                            rightMargin: 12
                        }
                    }
                    Label {
                        id: pushAndPullLabel
                        text: "Push & Pull"
                        color: "#eee"
                        anchors {
                            top: selectorContainer.bottom
                            horizontalCenter: selectorContainer.horizontalCenter

                        }
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
                    onClicked: validate();
                }
            }
        }
    }
}
