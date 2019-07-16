import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "Components"
ColumnLayout {
    id: root

    property alias model: listView.model
    property alias currentIndex: listView.currentIndex
    signal search(string text)

    UserInputBox {
        id: searchbox
        showButton: true
        iconSize: 12
        Layout.preferredWidth: parent.width - 20
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 10
        path: "Images/cancelIcon.png"
        onAccepted: search(userInput)
        onClicked: searchbox.userInput = ""
    }
    Item {
        Layout.preferredHeight: 50
        Layout.preferredWidth: parent.width - 20
        Layout.alignment: Qt.AlignHCenter
        GridLayout {
            rows: 2
            columns: 2
            anchors.fill: parent
            RadioButton {
                id: selectAllRadioButton
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    // background color of delegate should be connected with items populated to the model
                }
            }
            RadioButton {
                id: selectNoneRadioButton
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    // background color of delegate should be connected with items populated to the model
                }
            }
            Label {
                Layout.alignment: Qt.AlignCenter
                text: "All"
                color: "#eee"
                Layout.preferredWidth: parent.height/3
            }
            Label {
                text: "None"
                Layout.alignment: Qt.AlignCenter
                color: "#eee"
                Layout.preferredWidth: parent.height/3
                Layout.rightMargin: 10
            }
        }
    }



    ListView {
        id: listView
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width - 20
        Layout.alignment: Qt.AlignHCenter
        clip: true
        model: []

        delegate: Component {
            Rectangle  {
                id: background
                property bool checked: false
                width: parent.width
                height: 30
                color: "#b55400"
                border.width: 1
                border.color: "#393e46"
                opacity: mouseArea.containsMouse ? 0.5 : 1
                radius: 3

                Text {
                    anchors.centerIn: parent
                    text: model.modelData
                    color: "#eee"
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                        checked = !checked
                        background.color = (checked === false) ? "#b55400" : "#612b00"
                    }
                    hoverEnabled: true
                    onEntered: {
                        if (listView.height < listView.contentHeight)
                            scrollBar.policy = ScrollBar.AlwaysOn
                        else
                            scrollBar.policy = ScrollBar.AlwaysOff
                    }
                    onExited: {
                        if (listView.height < listView.contentHeight)
                            scrollBar.policy = ScrollBar.AsNeeded
                        else
                            scrollBar.policy = ScrollBar.AlwaysOff
                    }
                }
            }
        }
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            width: 10
            anchors.right: listView.left
            policy: ScrollBar.AlwaysOff
        }
    }
}
