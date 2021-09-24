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

RadioButton {
    id: root

    property color textColor: typeof masterTextColor !== "undefined" ? masterTextColor : "black"
    property color radioColor: typeof masterRadioColor !== "undefined" ? masterRadioColor : "black"

    text: "Radio Button"
    implicitWidth: buttonText.implicitWidth + buttonText.anchors.leftMargin + indicator.width
    implicitHeight: Math.max(root.indicator.height, buttonText.height)

    contentItem: buttonText

    Text {
        id: buttonText
        anchors {
            left: root.indicator.right
            leftMargin: 10
        }
        text: root.text
        opacity: enabled ? 1.0 : 0.3
        color: root.textColor
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    indicator: Rectangle {
        id: outerRadio
        implicitWidth: typeof radioButtonSize !== "undefined" ? radioButtonSize : 20
        implicitHeight: implicitWidth
//        y: root.height / 2 - height / 2
        radius: width/2
        color: "transparent"
        opacity: enabled ? 1.0 : 0.3
        border.width: 1
        border.color: radioColor

        Rectangle {
            id: innerRadio
            implicitWidth: outerRadio.width * 0.6
            implicitHeight: implicitWidth
            anchors {
                horizontalCenter: outerRadio.horizontalCenter
                verticalCenter: outerRadio.verticalCenter
            }
            radius: width / 2
            opacity: enabled ? 1.0 : 0.3
            color: radioColor
            visible: root.checked
        }
    }
}

