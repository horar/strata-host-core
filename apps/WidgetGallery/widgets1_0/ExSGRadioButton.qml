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
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    anchors.fill: parent

    SGAlignedLabel{
        id: demoLabel
        target: radioButtons
        text: "Default Radio Buttons"
        enabled: editEnabledCheckBox.checked
        fontSizeMultiplier: 1.3

        SGRadioButtonContainer {
            id: radioButtons

            // Optional configuration:
            columns: 1                  // Default: undefined (container is a GridLayout)
            // textColor: "black"       // Default: "black"
            // radioColor: "black"      // Default: "black"
            // exclusive: false         // Default: true (modifies the built-in ButtonGroup)
            // radioSize: 20            // Default: 20 * fontSizeMultiplier (can also be individually set for buttons)
            // columnSpacing: 5         // Default: 5
            // rowSpacing: 5            // Default: 5
            // alignment: SGAlignedLabel.SideRightCenter    // Default: SGAlignedLabel.SideRightCenter (see SGAlignedLabel for alignment enumeration options)
            // fontSizeMultiplier: 1.0  // Default: 1

            SGRadioButton {
                id: ps
                text: "Pseudo-Sinusoidal"
                checked: true
                onCheckedChanged: { if (checked) console.info ( "PS Checked!") }
            }

            SGRadioButton {
                id: trap
                text: "Trapezoidal"
                onCheckedChanged: { if (checked) console.info ( "Trap Checked!") }
            }

            SGRadioButton {
                id: square
                text: "Square"
                onCheckedChanged: { if (checked) console.info ( "Square Checked!") }
            }
        }
    }

    SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: demoLabel.bottom
            topMargin: 20
        }
        text: "Everything enabled"
        checked: true
    }
}
