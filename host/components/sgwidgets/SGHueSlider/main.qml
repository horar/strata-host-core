import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGHueSlider Demo")

    SGHueSlider{
        id: hueSlider

        // Optional Configuration:
        label: "<b>Color Picker:</b>"   // Default: "" (if not entered, label will not appear)
        labelLeft: false                // Default: true
        width: 300                      // Default: 300 (includes label, if present)
        value: 128                      // Default: 128 (0-255 for hue)

        // Useful Signals:
        onValueChanged: console.log(color1, color_value1, color2, color_value2)
    }
}
