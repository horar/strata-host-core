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
