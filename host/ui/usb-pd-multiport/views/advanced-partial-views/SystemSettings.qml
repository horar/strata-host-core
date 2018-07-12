import QtQuick 2.9

Item {
    id: root
    height: 300
    anchors {
        left: parent.left
        right: parent.right
    }

    Text {
        id: name
        text: qsTr("text")
    }
}
