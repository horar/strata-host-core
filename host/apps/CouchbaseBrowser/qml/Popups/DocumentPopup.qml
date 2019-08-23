import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../Components"

CustomPopup {
    id: root

    showMaximizedBtn: true
    defaultHeight: 600
    defaultWidth: 500

    property alias docID: idContainer.userInput
    property alias docBody: bodyTextArea.text
    property bool validBody: true

    function isJSONString() {
        try {
            JSON.parse(docBody);
        } catch(e) {
            return false;
        }
        return true;
    }
    onClosed: {
        docID = ""
        docBody = ""
        if (Qt.colorEqual(popupStatus.messageBackgroundColor,"darkred")) {
            clearFailedMessage()
        }
    }

    content: ColumnLayout {
        width: parent.width-50
        height: parent.height-100
        anchors.centerIn: parent

        spacing: 20
        UserInputBox {
            id: idContainer
            Layout.preferredHeight: 30
            Layout.preferredWidth: parent.width
            Layout.fillWidth: true

            label: "ID:"
            showLabel: true
            placeholderText: "Enter Document ID"
        }
        Item {
            id: bodyContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            Label {
                id: bodyLabel
                anchors.top: parent.top

                text: "Body:"
                color: "#eeeeee"
            }
            ScrollView {
                id: scrollview
                height: parent.height-50
                width: parent.width
                anchors.top: bodyLabel.bottom
                anchors.topMargin: 5

                clip: true
                TextArea {
                    id: bodyTextArea
                    text: "{}"
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
        CustomButton {
            id: submitButton
            Layout.preferredHeight: 40
            Layout.preferredWidth: 100
            Layout.alignment: Qt.AlignHCenter

            text: "Submit"
            enabled: validBody && (idContainer.userInput.length !== 0)
            onClicked: submit();
        }
    }
}
