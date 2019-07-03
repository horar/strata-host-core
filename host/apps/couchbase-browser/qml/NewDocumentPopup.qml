import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtQuick 2.12

Window {
    id: root
    width: 500
    height: 550
    minimumHeight: 550
    minimumWidth: 500
    visible: false
    flags: Qt.Tool

    signal submit();

    property alias docID: idNameField.text;
    property alias docBody: bodyTextArea.text;
    property bool changed: false

    Rectangle {
        anchors.fill: parent
        color: "#393e46"
        ColumnLayout {
            spacing: 15
            width: parent.width
            height: implicitHeight
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                text: "Please enter the requested information"
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 20
                color: "#eee"
            }
            Rectangle {
                id: idContainer
                Layout.preferredHeight: 40
                Layout.preferredWidth: parent.width - 25
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                Layout.margins: 10
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
            Rectangle {
                id: bodyContainer
                Layout.preferredHeight: root.height / 1.75
                Layout.preferredWidth: parent.width - 25
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
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
            Button {
                id: submitButton
                Layout.preferredHeight: 40
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
                text: "Submit"
                onClicked: {
                    submit();
                    root.visible = false;
                }
                enabled: changed
            }
        }
    }
}
