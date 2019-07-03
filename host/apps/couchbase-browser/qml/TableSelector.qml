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
        text: "<b>Table Selector</b>"
        color: "#eee"
        anchors {
            top: parent.top
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }

    }
    ListView {
        id: listView
        width: parent.width - 10
        height: parent.height - 170
        model: [""]
        delegate: listDelegate
        anchors {
            top: label.bottom
            topMargin: 5
            horizontalCenter: parent.horizontalCenter
        }
    }
    Component {
        id: listDelegate
        Rectangle  {
            id: content
            width: parent.width
            height: 30
            border.width: 1
            border.color: "#393e46"
            color: "#b55400"
            radius: 3
            ColumnLayout {
                id: column
                anchors {fill: parent; margins: 2}
                Text {
                    id: itemText
                    Layout.alignment: Qt.AlignHCenter
                    text: "this is dummy text"
                    color: "#eee"
                }
            }
        }
    }
}
