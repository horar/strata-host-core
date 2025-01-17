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

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGRGBSlider Demo")

    SGAlignedLabel {
        id: demoLabel
        target: rgbSlider
        text: "<b>RGB Color Picker:</b>"
        anchors.centerIn: parent

        SGRGBSlider {
            id: rgbSlider

            // Optional Configuration:
            // width: 300      // Default: 300
            // height: 28      // Default: 28

            // Useful Signals:
            onValueChanged: console.log("Color:", color, "\nColor_Value:", color_value)
        }
    }
}
