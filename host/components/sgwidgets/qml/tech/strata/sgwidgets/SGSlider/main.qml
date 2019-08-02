import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGSlider Example")

    SGAlignedLabel{
        id: demoLabel
        target: sgSlider
        text: "Slider:"

        SGSlider {
            id: sgSlider

            // Optional configuration:
            width: 500                      // Default: 200
            // grooveColor: "#ddd"             // Default: "#dddddd"
            // grooveFillColor: "lightgreen"   // Default: "#888888"
            // textColor: "black"           // Default: "black"
            // stepSize: 1                  // Default: 1
            // value: 50                    // Default: average of from and to
            // from: 0                      // Default: 0.0
            // to: 100                      // Default: 100.0
            // startLabel: "0"              // Default: from
            // endLabel: "100"              // Default: to
            // showToolTip: true            // Default: true
            // toolTipDecimalPlaces: 0      // Default: number of decimal places in stepSize
            // live: false                  // Default: false (will only send valueChanged signal when slider is released)
            // inputBox: true               // Default: true
            // fontSizeMultiplier: 1        // Default: 1

            // Useful signals:
            onValueChanged: console.log("Slider value is now:", value) // Signals on any value change (both user and programmatic changes)
            onUserSet: console.log("Slider set by user to:", value)  // Signals when user sets value
            onProgrammaticallySet: console.log("Slider programmatically set to:", value) // Signals when value is set externally with SGSlider.setValue(value)
            //onPressedChanged: console.log("Slider pressed changed")
            //onMoved: console.log("Slider moved")  // Signals for every user movement, unaffected by live, not very useful
        }
    }

    Button {
        anchors {
            top: demoLabel.bottom
            topMargin: 40
        }
        text: "Programatically set slider to 50"
        onClicked: sgSlider.setValue(50)
    }
}
