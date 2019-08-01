import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import "../Components"

Popup {
    id: root
    width: maximized ? parent.width : 500
    height: maximized ? parent.height : 600
    visible: false
    padding: 1
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    signal submit()

    property alias docID: idContainer.userInput
    property alias docBody: bodyTextArea.text;
    property alias popupStatus: statusBar

    property bool validBody: true
    property bool maximized: false

    onClosed: {
        docID = ""
        docBody = ""
    }

    function isJSONString() {
        try {
            JSON.parse(docBody);
        } catch(e) {
            return false;
        }
        return true;
    }

    Rectangle {
        id: container
        anchors.fill: parent
        color: "#222831"
        StatusBar {
            id: statusBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: 25
        }
        ColumnLayout {
            spacing: 20
            width: parent.width-50
            height: parent.height-100
            anchors.centerIn: parent
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
                onClicked: submit();
                enabled: validBody && (idContainer.userInput.length !== 0)
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

            background: Rectangle {
                height: parent.height + 6
                width: parent.width + 6
                radius: width/2
                anchors.centerIn: parent
                color: closeBtn.hovered ? "white" : "transparent"
                Image {
                    id: icon
                    height: closeBtn.height
                    width: closeBtn.width
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/qml/Images/close.svg"
                }
            }
            onClicked: root.close()
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

            background: Rectangle {
                height: parent.height + 6
                width: parent.width + 6
                radius: 3
                anchors.centerIn: parent
                color: maximizeBtn.hovered ? "white" : "transparent"
                Image {
                    height: maximizeBtn.height
                    width: maximizeBtn.width
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/qml/Images/maximize.svg"
                }
            }
            onClicked: maximized = !maximized
        }
    }
    DropShadow {
        anchors.fill: container
        source: container
        horizontalOffset: 7
        verticalOffset: 7
        spread: 0
        radius: 20
        samples: 41
        color: "#aa000000"
    }
}
