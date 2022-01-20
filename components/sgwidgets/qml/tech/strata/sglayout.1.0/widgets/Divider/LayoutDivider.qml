/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

import "../../"

LayoutContainer {
    id: dividerRoot

    property int orientation: Qt.Horizontal
    property alias color: dividerLine.color
    property int thickness: 1 // "width" is a reserved word and ambiguous when vertical

    contentItem: Item {

        Rectangle {
            id: dividerLine
            height: dividerRoot.orientation === Qt.Horizontal ? thickness : parent.height
            width: dividerRoot.orientation === Qt.Horizontal ? parent.width : thickness
            anchors {
                centerIn: parent
            }
            color: "black"
        }
    }
}

