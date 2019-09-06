import QtQuick 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGHueSlider Demo")

    SGLabel {
        id: demoLabel
        target: hueSlider
        text: "Hue Slider:"
        anchors.centerIn: parent

        SGHueSlider{
            id: hueSlider

            // Optional Configuration:
            // width: 300    // Default: 300
            // height: 28    // Default: 28
            // value: 128    // Default: 128 (0-255 for hue as in HSV color profile)

            // Useful Signals:
            onValueChanged: console.log(color1, color_value1, color2, color_value2)
        }
    }
}
