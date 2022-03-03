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
import tech.strata.theme 1.0

Window {
    id: window
    visible: true
    width: 640
    height: 300
    title: qsTr("SGSlider Example")

    SGAlignedLabel{
        id: demoLabel
        target: slider
        text: "Slider:"

        SGSlider {
            id: slider

            // Optional configuration:
            width: 400
            // height: 50
            // value: .5                        // Default: average of from and to
            // from: 0                          // Default: 0.0
            // to: 1                            // Default: 1
            // grooveColor: "#bbb"              // Default: "#bbb"
            // fillColor: "#21be2b"             // Default: "#21be2b"
            // textColor: "black"               // Default: "black"
            // stepSize: .1                     // Default: .1
            // orientation: Qt.Vertical         // Default: Qt.Horizontal
            // mirror: false                    // Default: false (mirrors tickmark/label locations)
            // handleSize: 10                   // Default: -1 (overrides default handle width/height if set)
            // startLabel: "0"                  // Default: from
            // endLabel: "1"                    // Default: to
            // showLabels: false                // Default: true
            // showInputBox: false              // Default: true
            // showToolTip: false               // Default: true
            // showTickmarks: false             // Default: true
            // live: false                      // Default: false (will only send valueChanged signal when slider is released)
            // fontSizeMultiplier: 1            // Default: 1

            // Signals:
            onValueChanged: console.log("Slider value is now:", value)  // Signals on any value change (both user and programmatic changes)
            onUserSet: console.log("Slider set by user to:", value)     // Signals when user sets value

            // Functions:
            // slider.userSetValue(value)   // For custom connections to other user controls: set value as a user, userSet() signal will be called
        }
    }
}
