import QtQuick 2.12

Rectangle {
    id: pressable

    property color bgColor: "transparent"
    property color hoverColor: "black"
    property alias hoverEnabled: mouseArea.hoverEnabled
    property alias containsMouse: mouseArea.containsMouse

    signal clicked()

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        hoverEnabled: true
        onClicked: pressable.clicked()
    }

    Rectangle {
        anchors.fill: parent
        color: hoverColor
        radius: parent.radius
        opacity: 0.2
        visible: !mouseArea.pressed && mouseArea.containsMouse
    }

    color: {
        if (mouseArea.pressed) {
            return "orange"
        }

        return bgColor
    }
}
