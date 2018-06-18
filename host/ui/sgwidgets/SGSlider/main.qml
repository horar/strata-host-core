import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGSlider Example")

    SGSlider {
        id: sgSliderCustom

        // Optional configuration:
        label: "Cats:"              // Default: "" (if not entered, label will not appear)
        labelLeft: true             // Default: true
        width: parent.width         // Default: 200
        stepSize: 2.0               // Default: 1.0
        value: 0.0                  // Default: 0.0
        minimumValue: 0.0           // Default: 0.0
        maximumValue: 100000.0      // Default: 100.0
        startLabel: minimumValue    // Default: "0"
        endLabel: maximumValue      // Default: "100"
        decimalPlaces: 0            // Default: 0
        showDial: true              // Default: true
        grooveColor: "lightgreen"   // Default: "#dddddd"
        grooveFillColor: "red"      // Default: "#888888"
    }

    SGSlider {
        id: sgSliderGeneric
        anchors {
            top: sgSliderCustom.bottom
            topMargin: 20
        }
    }
}
