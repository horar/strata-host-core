/*
 * Copyright (c) 2018-2021 onsemi.
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
    text: qsTr("Button")
    property alias textColor: buttonContent.color
    property alias color: buttonBackground.color

    contentItem: Text {
        id: buttonContent
        text: root.text
        font: root.font
        opacity: enabled ? 1.0 : 0.3
        color: checked ? "#ffffff" : "#26282a"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        id: buttonBackground
        implicitWidth: 100
        implicitHeight: 40
        opacity: root.enabled ? 1 : 0.3
        color: checked ? "#353637" : pressed ? "#cfcfcf":"#e0e0e0"
    }
}
