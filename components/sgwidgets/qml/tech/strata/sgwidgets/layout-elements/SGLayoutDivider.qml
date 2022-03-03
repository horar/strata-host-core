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

    property string position: "top"

    color: "#ddd"
    width: 1
    height: 1
    z:1

    Component.onCompleted: {
        switch (position) {
            case "top":
                root.anchors.top = root.parent.top
                root.width = root.parent.width
                break;
            case "bottom":
                root.anchors.bottom = root.parent.bottom
                root.width = root.parent.width
                break;
            case "right":
                root.anchors.right = root.parent.right
                root.height = root.parent.height
                break;
            case "left":
                root.anchors.left = root.parent.left
                root.height = root.parent.height
                break;
        }
    }
}
