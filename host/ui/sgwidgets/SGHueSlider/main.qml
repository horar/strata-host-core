import QtQuick 2.9
import QtQuick.Window 2.2

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
        onValueChanged: console.log("Slider stopped at: ", value)
    }
}
