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
    id: root
    anchors.fill: parent

    SGAlignedLabel {
        id: demoLabel
        target: sgSwitch
        text: "Default Switch"
        fontSizeMultiplier: 1.3


        SGSwitch {
            id: sgSwitch
            enabled: editEnabledCheckBox.checked
            // Optional Configuration:
            checkedLabel: "On"                 // Default: "" (if not entered, label will not appear)
            uncheckedLabel: "Off"              // Default: "" (if not entered, label will not appear)
            //width: 100                       // Default: switchRow.implicitWidth
            //height: 25                       // Default: 25 * fontSizeMultiplier
            // labelsInside: false             // Default: true
            // textColor: "white"              // Default: labelsInside ? "white" : "black"
            // handleColor: "white"            // Default: "white"
            // grooveColor: "#ccc"             // Default: "#B3B3B3"
            // grooveFillColor: "#0cf"         // Default: "#0cf"
            // fontSizeMultiplier: 3           // Default: 1.0


            // Usable Signals:
            onCheckedChanged: console.info("Checked toggled")
            onReleased: console.info("Switch released")
            onCanceled: console.info("Switch canceled")
            onClicked: console.info("Switch clicked")
            onPress: console.info("Switch pressed")
            onPressAndHold: console.info("Switch pressed and held")
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
        onCheckedChanged:  {
            if(checked)
                sgSwitch.opacity = 1.0
            else sgSwitch.opacity = 0.5
        }

    }

}

