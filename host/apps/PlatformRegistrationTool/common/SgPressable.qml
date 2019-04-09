import QtQuick 2.12

Rectangle {
    id: pressable

    property color bgColor: "transparent"
    property alias hoverEnabled: mouseArea.hoverEnabled

    signal clicked()

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        hoverEnabled: true
        onClicked: pressable.clicked()
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
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
