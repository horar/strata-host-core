/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.3

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

Button {
    id: itemRoot
    text: qsTr("Item Text")
    hoverEnabled: true
    contentItem: SGText {
        id: itemText
        text: itemRoot.text
        opacity: enabled ? 1 : 0.3
        color: 'white'
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        font {
            family: Fonts.franklinGothicBold
        }

        fontSizeMultiplier: 1
    }

    background: Rectangle {
        id: itemBackground
        opacity: enabled ? 1 : 0.3
        color: !itemRoot.hovered ?
                   Qt.darker(Theme.palette.onsemiOrange, 1.15) : itemRoot.pressed ?
                       Qt.lighter(Theme.palette.onsemiOrange, 1.15) : Theme.palette.onsemiOrange
        clip: true
    }

    MouseArea {
        id: itemMouseArea
        anchors.fill: parent
        onPressed: mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }
}
