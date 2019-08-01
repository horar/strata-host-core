import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "Components"
ColumnLayout {
    id: root

    property alias model: listModel
    property var channels: []
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

    CheckBox {
        id: checkBox
        Layout.preferredHeight: 25
        Layout.preferredWidth: 25
        Layout.alignment: Qt.AlignLeft
        Layout.leftMargin: 12
        Layout.topMargin: 12
        Layout.bottomMargin: 5
        onClicked: {
            if (checkState === Qt.Checked) selectAll();
            if (checkState === Qt.Unchecked) selectNone();
        }
        visible: model.count !== 0
    }

    ListModel {
        id: listModel
    }

    ListView {
        id: listView
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width - 10
        Layout.alignment: Qt.AlignRight
        Layout.bottomMargin: 10
        clip: true
        model: listModel

        delegate: Component {
            Rectangle  {
                id: background
                width: parent.width - 10
                height: 30
                color: isLabel ? "transparent" : (checked ? "#612b00" : "#b55400")
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
                    enabled: !isLabel
                    anchors.fill: parent
                    onClicked: {
                        listView.currentIndex = index
                        checked = !checked
                        if (checked) channels.push(channel)
                        else channels.splice(channels.indexOf(channel),1)
                        if (channels.length === 0) checkBox.checkState = Qt.Unchecked;
                        else if (channels.length === root.model.count) checkBox.checkState = Qt.Checked;
                        else checkBox.checkState = Qt.PartiallyChecked;
                        root.changed()
                    }
                }
            }
        }
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            width: 10
            policy: ScrollBar.AsNeeded
        }
    }
}
