/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: root
    width: 500
    height: 200

    SGAlignedLabel {
        id: demoLabel
        target: rgbSlider
        text: "Default RGB Color Picker"
        fontSizeMultiplier: 1.3
        enabled: editEnabledCheckBox.checked

        SGRGBSlider {
            id: rgbSlider
            // Optional Configuration:
            // width: 300      // Default: 300
            // height: 28      // Default: 28

            // Useful Signals:
            onValueChanged: console.info("Color:", color, "\nColor_Value:", color_value)
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
        onCheckedChanged: {
            if(checked)
                rgbSlider.opacity = 1.0
            else rgbSlider.opacity = 0.5
        }
    }
}
