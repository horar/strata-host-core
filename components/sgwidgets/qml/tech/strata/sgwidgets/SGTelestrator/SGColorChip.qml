/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

Rectangle {
    id: root
    color: "white"
    height: 50
    width: height
    border {
        width: 1
        color: Qt.darker(root.color)
    }

    signal clicked (color color)

    MouseArea {
        id: mouseArea
        anchors {
            fill: root
        }

        onClicked: {
            root.clicked (root.color)
        }
    }
}
