import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    id: root
    checkable: true
    opacity: checked ? 1.0 : 0.3
    Accessible.role: Accessible.Button
    Accessible.onPressAction: function() {
        clicked()
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }

    Text {
        text: root.text
        font: root.font
        color: "#545960"
        anchors {
            top: root.top
            horizontalCenter: root.horizontalCenter
        }

        elide: Text.ElideRight
    }

    contentItem: Item {}

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 30

        Rectangle {
            color: "#545960"
            width: parent.width
            height: 5
            anchors {
                bottom: parent.bottom
            }
        }
    }
}
