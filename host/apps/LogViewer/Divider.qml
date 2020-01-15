import QtQuick 2.12

Item {
    id: control

    height: parent.height
    width: 1

    property alias color: divider.color

    Rectangle {
        id: divider
        anchors.fill: parent
        color: "black"
    }
}
