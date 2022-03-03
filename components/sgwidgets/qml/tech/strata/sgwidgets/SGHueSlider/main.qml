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

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGHueSlider Demo")

    Column {
        spacing: 20

        SGAlignedLabel {
            id: demoLabel
            target: hueSlider
            text: "Default Hue Slider:"
            fontSizeMultiplier: 1.3

            SGHueSlider{
                id: hueSlider

                // Optional Configuration:
                // width: 300    // Default: 300
                // height: 28    // Default: 28
                // value: 128    // Default: 128 (0-255 representation of hue - divide by 255 and multiply by 360 to get hue value for HSV or HSL)

                // Useful Signals:
                onValueChanged: {
                    console.log("HSL/HSV hue value:", (360 * (value/255)).toFixed(0) + "°")
                }
            }
        }

        SGAlignedLabel {
            id: outputLabel
            target: outputText
            text: "Output Values:"
            fontSizeMultiplier: 1.3

            SGText {
                id: outputText
                color: "grey"
                text: {
                    "HSL/HSV hue value: " + (360 * (hueSlider.value/255)).toFixed(0) + "°\n" + // H is the same for HSL and HSV
                    "Complete HSV representation: "+ (360 * (hueSlider.value/255)).toFixed(0) + "° 100% 100%\n" + // S and V are both 100% for pure HSV hues
                    "Complete HSL representation: "+ (360 * (hueSlider.value/255)).toFixed(0) + "° 100% 50%\n" + // S is 100% and L is 50% for pure HSL hues
                    "2 color RGB representation: "+ hueSlider.color1 + ": " + hueSlider.color_value1 + " " + hueSlider.color2 + ": " + hueSlider.color_value2 + "\n" + // pure hues only contain 2 of R, G, and B - the third is always 0
                    "Complete RGB representation: "+ hueSlider.rgbArray
                }
            }
        }

        Button {
            text: "Set Hue to 60° (yellow)"
            onClicked: {
                let yellowHue = 60
                hueSlider.value = (yellowHue/360)*255
            }
        }
    }
}
