import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../Components"

Popup {
    id: root
    width: maximized ? parent.width : 500
    height: maximized ? parent.height : 600
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    visible: false
    padding: 1
    closePolicy: Popup.CloseOnEscape
    modal: true

    property alias docID: idContainer.userInput
    property alias docBody: bodyTextArea.text;
    property alias popupStatus: statusBar
    property bool validBody: true
    property bool maximized: false

    signal submit()
    signal clearFailedMessage()

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

    Rectangle {
        id: container
        anchors.fill: parent

        color: "#222831"
        StatusBar {
            id: statusBar
            width: parent.width
            height: 25
            anchors.bottom: parent.bottom
        }
        ColumnLayout {
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
        Button {
            id: closeBtn
            height: 20
            width: 20
            anchors {
                top: parent.top
                right: parent.right
                topMargin: 20
                rightMargin: 20
            }

            onClicked: root.close()
            background: Rectangle {
                height: parent.height + 6
                width: parent.width + 6
                anchors.centerIn: parent

                radius: width/2
                color: closeBtn.hovered ? "white" : "transparent"
                SGIcon {
                    id: icon
                    height: closeBtn.height
                    width: closeBtn.width
                    anchors.centerIn: parent

                    fillMode: Image.PreserveAspectFit
                    iconColor: "#b55400"
                    source: "qrc:/qml/Images/close.svg"
                }
            }
        }

        Button {
            id: maximizeBtn
            height: 20
            width: 20
            anchors {
                top: parent.top
                right: closeBtn.left
                topMargin: 20
                rightMargin: 10
            }

            onClicked: maximized = !maximized
            background: Rectangle {
                height: parent.height + 6
                width: parent.width + 6
                anchors.centerIn: parent

                radius: 3
                color: maximizeBtn.hovered ? "white" : "transparent"
                SGIcon {
                    height: maximizeBtn.height
                    width: maximizeBtn.width
                    anchors.centerIn: parent

                    iconColor: "#b55400"
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/qml/Images/maximize.svg"
                }
            }
        }
    }
    DropShadow {
        anchors.fill: container
        horizontalOffset: 7
        verticalOffset: 7
        source: container
        spread: 0
        radius: 20
        samples: 41
        color: "#aa000000"
    }
}
