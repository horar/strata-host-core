import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id:root
    width: 500
    height: 200

    Column {
        spacing: 20

        SGAlignedLabel {
            id: demoLabel
            target: hueSlider
            text: "Default Hue Slider:"
            fontSizeMultiplier: 1.3
            enabled: editEnabledCheckBox.checked

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

        SGCheckBox {
            id: editEnabledCheckBox
            text: "Slider enabled"
            checked: true
        }
    }
}
