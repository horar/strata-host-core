import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3

Window {
    id: root
    width: 500
    height: 550
    minimumHeight: 550
    minimumWidth: 500
    visible: false

    property alias docID: idNameField.text;
    property alias docBody: bodyTextArea.text;

    signal submit();

    Rectangle {
        anchors.fill: parent
        color: "#393e46"
        ColumnLayout {
            spacing: 1
            width: parent.width
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            Rectangle {
                Layout.preferredHeight: 80
                Layout.preferredWidth: parent.width - 25
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
                    id: idContainer
                    height: parent.height / 2
                    width: parent.width - 25
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "ID:"
                        color: "white"
                        anchors {
                            bottom: idContainer.top
                            left: idContainer.left
                        }
                    }
                    TextField {
                        id: idNameField
                        anchors.fill: parent
                        placeholderText: "Enter ID"
                    }
                }
            }
            Rectangle {
                Layout.preferredHeight: parent.height / 1.75
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                color: "transparent"
                Rectangle {
                    id: bodyContainer
                    height: parent.height
                    width: parent.width - 25
                    anchors {
                        centerIn: parent
                    }
                    Label {
                        text: "Body:"
                        color: "#eeeeee"
                        anchors {
                            bottom: bodyContainer.top
                            left: bodyContainer.left
                        }
                    }
                    ScrollView {
                        id: scrollview
                        anchors.fill: parent
                        clip: true
                        TextArea {
                            id: bodyTextArea
                            anchors.fill: parent
                            placeholderText: "Enter Body"
                            wrapMode: "Wrap"
                            selectByMouse: true
                            text: ""
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
                    onClicked: {
                        submit();
                        root.visible = false;
                    }
                }
            }
        }
    }
}
