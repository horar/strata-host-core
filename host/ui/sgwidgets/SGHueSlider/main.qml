import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGHueSlider Demo")

    SGHueSlider{
        label: "<b>Color Picker:</b>"
        labelLeft: true
        sliderWidth: 300
        value: 0.5
        onValueChanged: console.log("Slider stopped at: ", value)
    }
}
