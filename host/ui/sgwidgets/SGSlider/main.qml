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
        anchors {
            top: parent.top
            topMargin: 40
        }

        // Optional configuration:
        label: "<b>RPM:</b>"        // Default: "" (if not entered, label will not appear)
        textColor: "black"          // Default: "black"
        labelLeft: true             // Default: true
        width: 500                  // Default: 200
        stepSize: 2               // Default: 1.0
        value: 5000                 // Default: 0.0
        from: 0                     // Default: 0.0
        to: 10000                   // Default: 100.0
        startLabel: "0"             // Default: minimumValue
        endLabel: "10000"           // Default: maximumValue
        showToolTip: true           // Default: true
        toolTipDecimalPlaces: 0     // Default: 0
        grooveColor: "#ddd"         // Default: "#dddddd"
        grooveFillColor: "lightgreen"// Default: "#888888"
        live: false                 // Default: false (will only send valueChanged signal when slider is released)

        // Useful signals:
        onValueChanged: console.log("Slider value is now: ", value)
        //onPressedChanged: console.log("Slider pressed"
    }
}
