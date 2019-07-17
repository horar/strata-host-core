import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

ColumnLayout {
    id: root

    signal submit()
    signal back()
    property var channels: []

    function add() {
        if (!channels.includes(channelInputField.text)) {
            channels.push(channelInputField.text)
            list.model = channels
            list.positionViewAtEnd()
        }
        channelInputField.clear()
    }

    ColumnLayout {
        id: channelViewContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        Label {
            text: "Selected Channels:"
            color: "#eee"
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "#d9d9d9"
            border {
                width: 1
                color: "#eee"
            }
            ListView {
                id: list
                anchors {
                    fill: parent
                    margins: 5
                }
                clip: true
                model: []
                delegate: Component {
                    Rectangle {
                        height: 18
                        width: parent.width
                        color: "#b55400"
                        border {
                            width: 1
                            color: "black"
                        }
                        Text {
                            anchors.centerIn: parent
                            text: model.modelData
                            font.pixelSize: 12
                            color: "#eee"
                        }
                    }
                }
                spacing: 2
            }
        }
    }
    RowLayout {
        id: channelInputContainer
        Layout.maximumHeight: 30
        Layout.fillWidth: parent
        TextField {
            id: channelInputField
            Layout.fillHeight: true
            Layout.fillWidth: true
            autoScroll: true
            placeholderText: "Enter Channel"
            onAccepted: add()
            onActiveFocusChanged: {
                channelInputBackground.border.color = activeFocus ? "#b55400" : "transparent"
            }
            background: Rectangle {
                id: channelInputBackground
                border {
                    width: 2
                    color: "transparent"
                }
            }
        }
        Button {
            id: addButton
            Layout.fillHeight: true
            Layout.preferredWidth: 50
            hoverEnabled: true
            text: "Add"
            onClicked: add()
            background: Rectangle {
                color: addButton.hovered ? "#8c4100" : "#b55400"
            }
        }
    }
    RowLayout {
        id: clearBtns
        Layout.preferredHeight: 30
        Layout.fillWidth: true
        Button {
            id: clearAllButton
            Layout.preferredHeight: parent.height
            Layout.fillWidth: true
            text:  "Clear All"
            onClicked: {
                channels = []
                list.model = []
            }
        }
        Button {
            id: clearLastButton
            Layout.preferredHeight: parent.height
            Layout.fillWidth: true
            text: "Clear Last"
            onClicked: {
                channels.pop()
                list.model = channels
            }
        }
    }

    RowLayout {
        id: mainBtns
        Layout.preferredHeight: 30
        Layout.fillWidth: true
        Button {
            Layout.preferredHeight: 30
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: "Back"
            onClicked: root.back()
        }
        Button {
            Layout.preferredHeight: 30
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            text: "Submit"
            onClicked: submit()
        }
    }
}
