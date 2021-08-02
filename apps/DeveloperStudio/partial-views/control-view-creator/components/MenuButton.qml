import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    id: button

    Component.onCompleted: {
        contentItem.color = Qt.binding(() => {
                                       if (enabled === false) {
                                               return "#bbb"
                                           } else {
                                               return "black"
                                           }
                                       })
    }

    background: Rectangle {
        color: enabled === false ? "transparent" : button.hovered ? "#eee" : "#fff"

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            color: "grey"
            visible: button.checked
            height: 2
        }
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onPressed: mouse.accepted = false
    }
}
