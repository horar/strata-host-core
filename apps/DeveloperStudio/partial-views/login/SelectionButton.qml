/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    id: root
    checkable: true
    opacity: checked ? 1.0 : 0.3
    Accessible.role: Accessible.Button
    Accessible.onPressAction: function() {
        clicked()
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onPressed: mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }

    Text {
        text: root.text
        font: root.font
        color: "#545960"
        anchors {
            top: root.top
            horizontalCenter: root.horizontalCenter
        }

        elide: Text.ElideRight
    }

    contentItem: Item {}

    background: Rectangle {
        implicitWidth: 100
        implicitHeight: 30

        Rectangle {
            color: "#545960"
            width: parent.width
            height: 5
            anchors {
                bottom: parent.bottom
            }
        }
    }
}
