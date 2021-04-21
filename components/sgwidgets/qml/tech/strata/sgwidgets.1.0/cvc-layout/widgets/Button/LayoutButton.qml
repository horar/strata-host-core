import QtQuick 2.12
import QtQuick.Controls 2.12

import "../../"

LayoutContainer {

    property alias text: buttonObject.text

    signal clicked()

    contentItem: Button {
        id: buttonObject
        text: "Button"

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

