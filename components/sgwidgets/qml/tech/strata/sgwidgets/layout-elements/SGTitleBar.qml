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
    anchors {
        left: parent.left
        right: parent.right
    }
    height: 30
    color: "#ddd"
    border {
        color: "#bbb"
        width: 0
    }

    property alias title: title.text
    property alias horizontalAlignment: title.horizontalAlignment
    property alias pixelSize: title.font.pixelSize
    property alias bold: title.font.bold

    Text {
        id: title
        text: qsTr("Title")
        anchors {
            verticalCenter: root.verticalCenter
            left: root.left
            leftMargin: 10
            right: root.right
            rightMargin: 10
        }
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
    }
}
