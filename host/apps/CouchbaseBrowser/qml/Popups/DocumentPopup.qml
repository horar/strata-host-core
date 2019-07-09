import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtQuick 2.12
import "../Components"

Window {
    id: root
    minimumHeight: 600
    minimumWidth: 500
    visible: false
    flags: Qt.Tool

    signal submit();

    property alias docID: idTextField.text;
    property alias docBody: bodyTextArea.text;
    property alias message: statusBar.message

    property bool validBody: true

    function isJSONString() {
        try {
            JSON.parse(docBody);
        } catch(e) {
            return false;
        }
        return true;
    }

    Rectangle {
        anchors.fill: parent
        color: "#393e46"
        border {
            width: 2
            color: "#b55400"
        }
        StatusBar {
            id: statusBar
            anchors.top: parent.top
        }
        ColumnLayout {
            spacing: 20
            width: parent.width-50
            height: parent.height-100
            anchors.centerIn: parent
            Item {
                id: idContainer
                Layout.preferredHeight: idLabel.height+idTextField.height
                Layout.fillWidth: true
                Label {
                    id: idLabel
                    text: "ID:"
                    color: "white"
                    anchors.top: parent.top
                }
                TextField {
                    id: idTextField
                    text: ""
                    height: 40
                    width: parent.width
                    anchors.top: idLabel.bottom
                    placeholderText: "Enter ID"
                    validator: RegExpValidator { regExp: /^(?!\s*$).+/ }
                }
            }
            Item {
                id: bodyContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
                Label {
                    id: bodyLabel
                    text: "Body:"
                    color: "#eeeeee"
                    anchors.top: parent.top
                }
                ScrollView {
                    id: scrollview
                    height: parent.height-50
                    width: parent.width
                    anchors.top: bodyLabel.bottom
                    clip: true
                    TextArea {
                        id: bodyTextArea
                        text: ""
                        color: validBody ? "black" : "red"
                        placeholderText: "Enter Body"
                        wrapMode: "Wrap"
                        selectByMouse: true
                        background: Rectangle {
                            anchors.fill:parent
                            color: "white"
                        }
                        onTextChanged: {
                            if (text === "") text = "{}";
                            validBody = isJSONString()
                        }
                    }
                }
            }
            Button {
                id: submitButton
                Layout.preferredHeight: 40
                Layout.preferredWidth: 100
                Layout.alignment: Qt.AlignHCenter
                text: "Submit"
                onClicked: {
                    submit();
                    root.visible = false;
                }
                enabled: validBody
            }
        }
    }
}
