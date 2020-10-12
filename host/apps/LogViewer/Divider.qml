import QtQuick 2.12

Item {
    id: control

    height: parent.height
    width: 1

    property alias color: divider.color
    property alias mouseArea: mouseArea
    property alias mouseX: mouseArea.mouseX
    property bool clickable: false

    Rectangle {
        id: divider
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        height: mouseArea.pressed ? parent.height : parent.height/1.5
        color: mouseArea.pressed ? highlightColor : "black"

        MouseArea {
            id: mouseArea
            height: parent.height
            width: parent.width + 7
            anchors.centerIn: parent
            visible: clickable
            cursorShape: Qt.SplitHCursor
            acceptedButtons: Qt.LeftButton
        }
    }
}
