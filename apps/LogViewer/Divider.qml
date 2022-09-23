/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.theme 1.0

Item {
    id: control

    height: 6
    width: 1

    property alias mouseX: mouseArea.mouseX
    property color color:  "black"
    property color highlightCcolor:  Theme.palette.highlight

    Rectangle {
        id: divider
        width: 1
        anchors.centerIn: parent
        height: mouseArea.pressed ? parent.height - 2 : parent.height*0.6

        color: mouseArea.pressed ? highlightCcolor :control.color
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.SplitHCursor
        acceptedButtons: Qt.LeftButton
    }
}
