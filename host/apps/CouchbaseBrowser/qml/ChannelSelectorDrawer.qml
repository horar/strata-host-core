import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "Components"
ColumnLayout {
    id: root

    property alias model: listModel
    property var channels: []
    property int channelsLength: 0
    signal changed()

    function selectAll()
    {
        for (var i = 0; i<model.count; i++) {
            model.get(i).checked = true
        }
        channels = []
        for (var i = 0; i<model.count; i++) {
            channels.push(model.get(i).channel)
        }
        channelsLength = channels.length
        root.changed()
    }

    function selectNone()
    {
        for (var i = 0; i<model.count; i++) {
            model.get(i).checked = false
        }
        channels = []
        channelsLength = 0
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

        visible: model.count !== 0
        checkState: channelsLength === 0 ? Qt.Unchecked
                                         : channelsLength === root.model.count ? Qt.Checked
                                                                               : Qt.PartiallyChecked
        onClicked: {
            if (checkState === Qt.Checked) {
                selectAll();
            }
            if (checkState === Qt.Unchecked) {
                selectNone();
            }
        }
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
                    width: parent.width - 10
                    anchors.centerIn: parent

                    text: channel
                    color: "#eee"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    enabled: !isLabel
                    onClicked: {
                        listView.currentIndex = index
                        checked = !checked
                        if (checked) {
                            channels.push(channel)
                        }
                        else {
                            channels.splice(channels.indexOf(channel),1)
                        }
                        channelsLength = channels.length
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
