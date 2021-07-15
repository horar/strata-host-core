import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../"

LayoutContainer {
    id: buttonRoot

    property alias text: buttonObject.text
    property alias hovered: buttonObject.hovered
    property alias pressed: buttonObject.pressed
    property alias checked: buttonObject.checked
    property alias checkable: buttonObject.checkable
    property alias down: buttonObject.down
    property alias buttonObject: buttonObject // exposed for advanced customization

    // match default button colors:
    property color textColor: {
        if (buttonObject.checked) {
            if (buttonObject.enabled) {
                return "#ffffff"
            } else {
                return "#4dffffff"
            }
        } else {
            if (buttonObject.enabled) {
                return "#26282a"
            } else {
                return "#4d26282a"
            }
        }
    }

    property color color: {
        if (buttonObject.checked) {
            if (buttonObject.down) {
                return "#79797a"
            } else {
                return "#353637"
            }
        } else {
            if (buttonObject.down) {
                return "#cfcfcf"
            } else {
                return "#e0e0e0"
            }
        }
    }

    signal clicked()

    contentItem: Button {
        id: buttonObject
        text: "Button"

        Component.onCompleted: {
            background.color = Qt.binding(() => {return buttonRoot.color})
            contentItem.color = Qt.binding(() => {return buttonRoot.textColor})
        }

        onClicked: parent.clicked()

        MouseArea {
            id: mouse
            anchors {
                fill: parent
            }
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onPressed:  mouse.accepted = false
        }
    }
}

