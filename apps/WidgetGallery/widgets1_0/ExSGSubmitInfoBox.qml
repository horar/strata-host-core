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
        target: applyInfoBox
        text: "Default Submit Info Box"
        enabled: editEnabledCheckBox.checked
        fontSizeMultiplier: 1.3

        SGSubmitInfoBox {
            id: applyInfoBox
            width: 250

            // Optional configuration:
            buttonText: "Apply"             // Default: "" (empty string causes button to not appear)
            unit: "unit"                       // Default: "" (empty string causes unit to not appear)
            placeholderText: "0 - 100"     // Default: "" (empty string causes placeholderText to not appear)
            validator: DoubleValidator {    // Default: no input validator - you may assign your own configured DoubleValidator, IntValidator or RegExpValidator
                bottom: 0
                top: 100
            }
            fontSizeMultiplier: 1.3
            // text: ""                     // Default: "" (initial string in box)
            // textColor: "black"           // Default: "black" (colors unit as well as text in box)
            // invalidTextColor: "red"      // Default: "red" (colors box text when an optional validator determines it is invalid)
            // fontSizeMultiplier: 1        // Default: 1.0
            // boxColor: "#eee"             // Default: readOnly ? "#F2F2F2" : "white"
            // boxBorderColor: "#999"       // Default: "#CCCCCC"
            // boxBorderWidth: 1            // Default: 1 (assign 0 for no border)
            // buttonImplicitWidth: 50      // Default: implicitWidth of button
            // readOnly: false              // Default: false
            // horizontalAlignment: Text.AlignRight // Default: Text.AlignRight (aligns text in box)
            // infoBoxHeight: 100           // Default: infoBox.implicitHeight (sets Layout.preferredHeight for infoBox)

            // Useful Signals:
            onAccepted: console.info("Accepted: Applied string is " + text)                  // Called when enter key pressed or applyButton pressed
            onEditingFinished: console.info("EditingFinished: Applied string is " + text)    // Called when enter key pressed, applyButton pressed, or box loses focus

            // Useful functions:
            // applyInfoBox.forceActiveFocus    // forces active focus in text box (see Component.onCompleted below)
        }
    }

    Component.onCompleted: applyInfoBox.forceActiveFocus()

    SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: demoLabel.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
        onCheckedChanged:  {
            if(checked)
                applyInfoBox.opacity = 1.0
            else applyInfoBox.opacity = 0.5
        }
    }
}
