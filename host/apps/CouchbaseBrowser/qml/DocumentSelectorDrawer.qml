import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Rectangle {
    id: root   

    property alias model: listView.model
    property alias currentIndex: listView.currentIndex

    signal search(string text)

    TextField {
        id: searchbox
        height: 30
        width: parent.width - 20
        anchors{
            top: parent.top
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        placeholderText: "Search document"
        onAccepted: search(text)
        onEditingFinished: {
            if (text.length === 0) search("")
        }
    }

    ListView {
        id: listView
        height: parent.height - searchbox.height - 20
        width: parent.width - 20
        anchors{
            top: searchbox.bottom
            topMargin: 10
            horizontalCenter: parent.horizontalCenter
        }
        clip: true
        model: []
        delegate: Component {
            Rectangle  {
                width: parent.width
                height: 30
                border.width: 1
                border.color: "#393e46"
                color: listView.currentIndex === index ? "#612b00" : mouseArea.containsMouse ? "#8c4100" : "#b55400"
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
