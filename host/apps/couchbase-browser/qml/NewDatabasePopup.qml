import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import Qt.labs.platform 1.0

Popup {
    id: root
    width: 500
    height: 500
    visible: false
    padding: 0

    signal submit()

    property alias folderPath: selectFolderField.text
    property alias filename: filenameField.text

    function clearFields(){
        folderPath = ""
        filename = ""
    }
    function validate(){
        if((selectFolderField.text.length !== 0) && (filenameField.text.length !== 0)){
            submit()
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
        border {
            width: 2
            color: "#b55400"
        }

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
                    id: selectFolderContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Select Folder:"
                        color: "white"
                        anchors {
                            bottom: selectFolderContainer.top
                            left: selectFolderContainer.left
                        }
                    }
                    TextField {
                        id: selectFolderField
                        anchors.fill: parent
                        placeholderText: "Enter Path"
                    }
                    Button  {
                        height: parent.height
                        width: 40
                        onPressed: {
                            folderDialog.visible = true
                        }
                        anchors {
                            left: parent.right
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                        Image {
                            source: "Images/openFolderIcon.png"
                            width: parent.width / 1.5
                            height: parent.height / 1.5
                            anchors.centerIn: parent
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: filenameContainer
                    height: parent.height / 2
                    width: parent.width / 2
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Database Name:"
                        color: "white"
                        anchors {
                            bottom: filenameContainer.top
                            left: filenameContainer.left
                        }
                    }
                    TextField {
                        id: filenameField
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
                Button {
                    id: submitButton
                    height: parent.height / 2
                    width: parent.width / 4
                    text: "Submit"
                    anchors.centerIn: parent
                    onClicked: {
                        validate()
                    }
                }
            }
        }
    }
    //place dialog box here
    FolderDialog {
        id: folderDialog
        onAccepted: {
            selectFolderField.text = folderDialog.folder
        }
    }

}
