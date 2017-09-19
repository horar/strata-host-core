import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    border.color: "black"
    color: "white"
    anchors { fill: parent }

    Label {
        x: 32 ; y: 128
        width: 176;height: 64
        text: "back"
        opacity: 1
        anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
        font.pointSize: 72
    }

    Image {
        source:"infoIcon.svg"
        anchors { bottom: parent.bottom; right: parent.right }
        height: 40;width:40
    }

    MouseArea {
        width: 100; height: 100
        anchors { right: parent.right; bottom: parent.bottom }
        visible: true
        onClicked: flipable.flipped = !flipable.flipped
    }
}
