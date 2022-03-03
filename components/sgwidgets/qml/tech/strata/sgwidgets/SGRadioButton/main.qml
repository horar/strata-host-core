/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGRadioButton Example")

    SGAlignedLabel{
        id: demoLabel
        target: radioButtons
        text: "Radio Buttons:"

        SGRadioButtonContainer {
            id: radioButtons

            // Optional configuration:
            columns: 1                  // Default: undefined (container is a GridLayout)
            // textColor: "black"       // Default: "black"
            // radioColor: "black"      // Default: "black"
            // exclusive: true          // Default: true (modifies the built-in ButtonGroup)
            // radioSize: 20            // Default: 20 * fontSizeMultiplier (can also be individually set for buttons)
            // columnSpacing: 5         // Default: 5
            // rowSpacing: 5            // Default: 5
            // alignment: SGAlignedLabel.SideRightCenter    // Default: SGAlignedLabel.SideRightCenter (see SGAlignedLabel for alignment enumeration options)
            // fontSizeMultiplier: 1.0  // Default: 1

            SGRadioButton {
                id: ps
                text: "Pseudo-Sinusoidal"
                checked: true
                onCheckedChanged: { if (checked) console.log ( "PS Checked!") }
            }

            SGRadioButton {
                id: trap
                text: "Trapezoidal"
                onCheckedChanged: { if (checked) console.log ( "Trap Checked!") }
                enabled: false
            }

            SGRadioButton {
                id: square
                text: "Square"
                onCheckedChanged: { if (checked) console.log ( "Square Checked!") }
            }
        }
    }
}
