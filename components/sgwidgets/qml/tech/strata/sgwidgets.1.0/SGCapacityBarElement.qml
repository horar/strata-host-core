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
    objectName: "capacityBarElement"

    property real value: 0
    property real secondaryValue: 0
    property alias color: primaryElement.color
    property var capacityBar: null

    width: (root.value-capacityBar.minimumValue)/(capacityBar.maximumValue-capacityBar.minimumValue)*capacityBar.masterWidth
    height: capacityBar.height
    clip: true

    Rectangle {
        id: primaryElement
        color: "blue"
        width: root.width
        height: root.height
    }

    Rectangle {
        id: secondaryElement
        width: (root.secondaryValue-capacityBar.minimumValue)/(capacityBar.maximumValue-capacityBar.minimumValue)*capacityBar.masterWidth
        height: root.height
        anchors {
            left: root.left
        }
        color: Qt.lighter(root.color, 1.3)
    }
}
