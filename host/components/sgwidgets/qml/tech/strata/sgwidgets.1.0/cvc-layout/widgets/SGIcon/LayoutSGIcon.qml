import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {
    id: layoutRoot

    // pass through all properties
    property alias iconColor: icon.iconColor
    property alias source: icon.source
    property alias mouseInteraction: mouse.enabled
    property alias containsMouse: mouse.containsMouse
    property alias cursorShape: mouse.cursorShape
    property alias hoverEnabled: mouse.hoverEnabled

    signal clicked()

    SGIcon {
        id: icon

        MouseArea {
            id: mouse
            enabled: false
            anchors {
                fill: parent
            }
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:  {
                layoutRoot.clicked()
            }
        }
    }
}

