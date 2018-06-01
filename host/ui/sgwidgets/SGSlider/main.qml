import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGSlider Example")

    ColumnLayout{

        SGSlider {
            id: sgSlider
            width: 400              // Default: 200
            height: 50              // Default: 28 - slider is centered in height box
            stepSize: 2.0           // Default: 1.0
            value: 0.0              // Default: 0.0
            minimumValue: 0.0       // Default: 0.0
            maximumValue: 100000.0  // Default: 100.0
            startLabel: "0"         // Default: "0"
            endLabel: "100"         // Default: "100"
            decimalPlaces: 0        // Default: 0
            showDial: true          // Default: true
        }

        SGSlider {
            id: sgSlider1
        }
    }
}
