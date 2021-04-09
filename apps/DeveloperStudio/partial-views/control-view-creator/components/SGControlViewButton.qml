import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    background: Rectangle {
        color: buttonArea.containsMouse ? "#999" : "#aaa"
        radius: 5
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onPressed:  mouse.accepted = false
    }
}


