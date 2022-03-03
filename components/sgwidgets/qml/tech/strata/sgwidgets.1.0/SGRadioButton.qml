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
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


RadioButton {
    id: radioButton
    implicitWidth: indicator.width
    implicitHeight: indicator.height
    objectName: "RadioButton"
    opacity: enabled ? 1.0 : 0.3
    layer.enabled: true

    property Item buttonContainer: null
    property real radioSize: buttonContainer ? buttonContainer.radioSize : 20 * label.fontSizeMultiplier
    property color radioColor: buttonContainer ? buttonContainer.radioColor : "black"
    property int index

    property alias fontSizeMultiplier: label.fontSizeMultiplier
    property alias color: label.color
    property alias alignment: label.alignment

    onCheckedChanged: {
        if (checked && buttonContainer) {
            buttonContainer.currentIndex = index
        }
    }

    indicator: SGAlignedLabel {
        id: label
        target: outerRadio
        text: radioButton.text
        color: buttonContainer ? buttonContainer.textColor : "black"
        alignment: buttonContainer ? buttonContainer.alignment : SGAlignedLabel.SideRightCenter
        fontSizeMultiplier: buttonContainer ? buttonContainer.fontSizeMultiplier : 1

        Rectangle {
            id: outerRadio
            implicitWidth: radioButton.radioSize
            implicitHeight: implicitWidth
            radius: width/2
            color: "transparent"
            border.width: 1
            border.color: radioButton.radioColor

            Rectangle {
                id: innerRadio
                implicitWidth: outerRadio.width * 0.6
                implicitHeight: implicitWidth
                anchors {
                    horizontalCenter: outerRadio.horizontalCenter
                    verticalCenter: outerRadio.verticalCenter
                }
                radius: width / 2
                color: radioButton.radioColor
                visible: radioButton.checked
            }
        }
    }
}


