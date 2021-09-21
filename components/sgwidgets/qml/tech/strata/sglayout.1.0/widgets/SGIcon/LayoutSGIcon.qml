/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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

    contentItem: SGIcon {
        id: icon

        MouseArea {
            id: mouse
            enabled: false
            visible: enabled
            anchors {
                fill: parent
            }
            hoverEnabled: false
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

            onClicked:  {
                layoutRoot.clicked()
            }
        }
    }
}

