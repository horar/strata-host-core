import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGSlider Example")

    SGSlider {
        id: sgSlider
        width: 400              // Default: 200
        stepSize: 2.0           // Default: 1.0
        value: 0.0              // Default: 0.0
        minimumValue: 0.0       // Default: 0.0
        maximumValue: 100.0     // Default: 100.0
        startLabel: "0"         // Default: "0"
        endLabel: "100"         // Default: "100"
        decimalPlaces: 1        // Default: 0
    }
}
