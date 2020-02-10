import QtQuick 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id:root
    width: 500
    height: 200
    SGAlignedLabel {
        id: demoLabel
        target: hueSlider
        text: "Default Hue Slider"
        fontSizeMultiplier: 1.3
        enabled: editEnabledCheckBox.checked

        SGHueSlider{
            id: hueSlider

            // Optional Configuration:
            // width: 300    // Default: 300
            // height: 28    // Default: 28
            // value: 128    // Default: 128 (0-255 for hue as in HSV color profile)

            // Useful Signals:
            onValueChanged: console.info(color1, color_value1, color2, color_value2)
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
