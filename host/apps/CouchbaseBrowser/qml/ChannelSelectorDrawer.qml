import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "Components"
ColumnLayout {
    id: root

    property alias model: listModel
    property var channels: []
    signal search(string text)
    signal changed()

    function selectAll()
    {
        for (var i = 0; i<model.count; i++)
            model.get(i).checked = true
        channels = []
        for (var i = 0; i<model.count; i++)
            channels.push(model.get(i).channel)
        root.changed()
    }

    function selectNone()
    {
        for (var i = 0; i<model.count; i++)
            model.get(i).checked = false
        channels = []
        root.changed()
    }

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
                onClicked: selectAll()
            }
            RadioButton {
                id: selectNoneRadioButton
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                Layout.alignment: Qt.AlignHCenter
                onClicked: selectNone()
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

    ListModel {
        id: listModel
    }

    ListView {
        id: listView
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width - 20
        Layout.alignment: Qt.AlignHCenter
        clip: true
        model: listModel

        delegate: Component {
            Rectangle  {
                id: background
                width: parent.width
                height: 30
                color: checked ? "#612b00" : "#b55400"
                border.width: 1
                border.color: "#393e46"
                opacity: mouseArea.containsMouse ? 0.5 : 1
                radius: 3

                Text {
                    anchors.centerIn: parent
                    text: channel
                    color: "#eee"
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                        checked = !checked
                        if (checked) channels.push(channel)
                        else channels.splice(channels.indexOf(channel),1)
                        root.changed()
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
