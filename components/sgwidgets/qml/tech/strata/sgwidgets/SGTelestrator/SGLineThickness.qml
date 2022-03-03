/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

Item {
    id: root
    height: 50
    width: lineThickness + 5
    property alias lineThickness: thicknessIndicator.width

    signal clicked (real thickness)

    Rectangle {
        id: thicknessIndicator
        color: "black"
        height: root.height
        anchors {
            horizontalCenter: root.horizontalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: root
        }

        onClicked: {
            root.clicked (root.lineThickness)
        }
    }
}
