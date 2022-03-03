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
    id: button

    Component.onCompleted: {
        contentItem.color = Qt.binding(() => {
                                       if (enabled === false) {
                                               return "#bbb"
                                           } else {
                                               return "black"
                                           }
                                       })
    }

    background: Rectangle {
        color: enabled === false ? "transparent" : button.hovered ? "#eee" : "#fff"

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            color: "grey"
            visible: button.checked
            height: 2
        }
    }

    MouseArea {
        id: buttonArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onPressed: mouse.accepted = false
    }
}
