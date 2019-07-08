import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Rectangle {
    id: root
    anchors.fill: parent
    color: "transparent"

    property alias model: listView.model
    property alias currentIndex: listView.currentIndex


    Label {
        id: label
        width: parent.width
        height: 30
        text: "<b>Document Selector:</b>"
        color: "#eee"
        anchors {
            top: parent.top
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
            horizontalCenterOffset: 5
        }

    }

    ListView {
        id: listView
        width: parent.width - 20
        height: model.length === 0 ? 0 : parent.height - 170
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
                }
            }
        }
        ScrollBar.vertical: ScrollBar {
            width: 10
            anchors.right: listView.left
            policy: ScrollBar.AlwaysOn
        }

        anchors {
            top: label.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
    }
}
