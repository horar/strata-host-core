import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import QtQuick 2.12

Window {
    id: root
    minimumHeight: 600
    minimumWidth: 500
    visible: false
    flags: Qt.Tool

    signal submit();

    property alias docID: idTextField.text;
    property alias docBody: bodyTextArea.text;
    property string originalID: ""
    property string originalBody: "{}"
    property bool idChanged: false
    property bool bodyChanged: false
    property bool validBody: true

    onIdChangedChanged: {
        submitButton.enabled = (idChanged || bodyChanged) && validBody
    }

    onBodyChangedChanged: {
        submitButton.enabled = (idChanged || bodyChanged) && validBody
    }

    onValidBodyChanged: {
        submitButton.enabled = (idChanged || bodyChanged) && validBody
    }

    function isJSONString() {
        try {
            JSON.parse(docBody);
        } catch(e) {
            return false;
        }
        return true;
    }

    function isBodyChanged() {
        if (!isJSONString()) return true

        var originalJSON = JSON.parse(originalBody)
        var newJSON = JSON.parse(docBody)
        let originalKeys = []
        let newKeys = []
        let i = 0
        for (i in originalJSON) originalKeys.push(i);
        for (i in newJSON) newKeys.push(i);

        if (originalKeys.length !== newKeys.length) return true;

        for (i = 0;i<originalKeys.length;i++)
        if (originalKeys[i] !== newKeys[i]) return true;

        for (i = 0;i<originalKeys.length;i++)
        if (originalJSON[originalKeys[i]] !== newJSON[originalKeys[i]]) return true;

        return false;
    }

    Rectangle {
        anchors.fill: parent
        color: "#393e46"
        ColumnLayout {
            spacing: 20
            width: parent.width-50
            height: parent.height-50
            anchors.centerIn: parent
            Label {
                text: "Please enter the requested information"
                color: "#eee"
                Layout.alignment: Qt.AlignHCenter
                topPadding: 30
                bottomPadding: 10
            }
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
                    text: originalID
                    height: 40
                    width: parent.width
                    anchors.top: idLabel.bottom
                    placeholderText: "Enter ID"
                    validator: RegExpValidator { regExp: /^(?!\s*$).+/ }
                    onTextChanged: {
                        idChanged = text !== originalID
                    }
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
                    height: parent.height-bodyLabel.height
                    width: parent.width
                    anchors.top: bodyLabel.bottom
                    clip: true
                    TextArea {
                        id: bodyTextArea
                        text: originalBody
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
                            bodyChanged = isBodyChanged()
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
                enabled: false
            }
        }
    }
}
