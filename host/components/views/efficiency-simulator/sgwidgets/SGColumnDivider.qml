import QtQuick 2.0

Item {
    id: root
//    anchors {
//        left: parent.left
//        right: parent.right
//        leftMargin: 10
//        rightMargin: 10
//    }
    width: parent.width - 20
    x:10
    height: 20

    Rectangle {
        id: divider
        anchors {
            left: root.left
            right: root.right
            verticalCenter: root.verticalCenter
        }
        height: 1
        color: "#ccc"
    }
}
