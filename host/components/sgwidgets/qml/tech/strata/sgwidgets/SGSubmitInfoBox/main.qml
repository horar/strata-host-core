import QtQuick 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGSubmitInfoBox Demo")

    SGAlignedLabel{
        id: demoLabel
        target: applyInfoBox
        text: "Voltage"

        SGSubmitInfoBox {
            id: applyInfoBox

            // Optional configuration:
            buttonText: "Apply"             // Default: "" (empty string causes button to not appear)
            unit: "V"                       // Default: "" (empty string causes unit to not appear)
            placeholderText: "0 - 10.0"     // Default: "" (empty string causes placeholderText to not appear)
            validator: DoubleValidator {    // Default: no input validator - you may assign your own configured DoubleValidator, IntValidator or RegExpValidator
                bottom: 0
                top: 10
            }
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
            onAccepted: console.log("Accepted: Applied string is " + text)                  // Called when enter key pressed or applyButton pressed
            onEditingFinished: console.log("EditingFinished: Applied string is " + text)    // Called when enter key pressed, applyButton pressed, or box loses focus

            // Useful functions:
            // applyInfoBox.forceActiveFocus    // forces active focus in text box (see Component.onCompleted below)
        }
    }

    Component.onCompleted: applyInfoBox.forceActiveFocus()
}
