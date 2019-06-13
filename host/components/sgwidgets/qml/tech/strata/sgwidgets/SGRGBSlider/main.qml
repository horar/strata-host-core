import QtQuick 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGHueSlider Demo")

    SGRGBSlider{
        id: rgbSlider

        // Optional Configuration:
        label: "<b>Color Picker:</b>"   // Default: "" (if not entered, label will not appear)
        labelLeft: false                // Default: true
        width: 300                      // Default: 300 (includes label, if present)

        // Useful Signals:
         onValueChanged: console.log("Color:", color, "Color_Value:", color_value)
    }
}
