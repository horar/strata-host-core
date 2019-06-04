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
        labelLeft: false            // Default: true
        width: 500                  // Default: 200
        stepSize: 1.0               // Default: 1.0
        value: 5000                 // Default: average of from and to
        from: 0                     // Default: 0.0
        to: 10000                   // Default: 100.0
        startLabel: "0"             // Default: from
        endLabel: "10000"           // Default: to
        showToolTip: true           // Default: true
        toolTipDecimalPlaces: 0     // Default: number of decimal places in stepSize
        grooveColor: "#ddd"         // Default: "#dddddd"
        grooveFillColor: "lightgreen"// Default: "#888888"
        live: false                 // Default: false (will only send valueChanged signal when slider is released)
        labelTopAligned: false       // Default: false (only applies to label on left of slider, decides vertical centering of label)
        inputBox: true              // Default: true

        // Useful signals:
        onValueChanged: console.log("Slider value is now:", value) // Signals on any value change (both user and programmatic changes)
        onUserSet: console.log("Slider set by user to:", value)  // Signals when user sets value
        onProgrammaticallySet: console.log("Slider programmatically set to:", value) // Signals when value is set externally with SGSlider.setValue(value)
        //onPressedChanged: console.log("Slider pressed changed")
        //onMoved: console.log("Slider moved")  // Signals for every user movement, unaffected by live, not very useful
    }

    Button {
        anchors {
            top: sgSliderCustom.bottom
            topMargin: 40
        }
        text: "Programatically set slider to 500"
        onClicked: sgSliderCustom.setValue(500)
    }
}
