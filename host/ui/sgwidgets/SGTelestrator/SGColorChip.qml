import QtQuick 2.0

Rectangle {
    id: root
    color: "white"
    height: 50
    width: height
    border {
        width: 1
        color: Qt.darker(root.color)
    }

    signal clicked (color color)

    MouseArea {
        id: mouseArea
        anchors {
            fill: root
        }

        onClicked: {
            root.clicked (root.color)
        }
    }
}
