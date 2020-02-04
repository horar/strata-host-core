import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
Item {
    anchors.fill: parent

    SGAlignedLabel{
        id: demoLabel
        target: slider
        text: "Slider"
        //font.bold: true
        fontSizeMultiplier: 1.3
        enabled: editEnabledCheckBox.checked

        SGSlider {
            id: slider

            // Optional configuration:
            width: 400
            // height: 50
            // value: .5                        // Default: average of from and to
            // from: 0                          // Default: 0.0
            // to: 1                            // Default: 1
            // grooveColor: "#bbb"              // Default: "#bbb"
            // fillColor: "#21be2b"             // Default: "#21be2b"
            // textColor: "black"               // Default: "black"
            // stepSize: .1                     // Default: .1
            // orientation: Qt.Vertical         // Default: Qt.Horizontal
            // mirror: false                    // Default: false (mirrors tickmark/label locations)
            // handleSize: 10                   // Default: -1 (overrides default handle width/height if set)
            // startLabel: "0"                  // Default: from
            // endLabel: "1"                    // Default: to
            // showLabels: false                // Default: true
            // showInputBox: false              // Default: true
            // showToolTip: false               // Default: true
            // showTickmarks: false             // Default: true
            // live: false                      // Default: false (will only send valueChanged signal when slider is released)
            // fontSizeMultiplier: 1            // Default: 1

            // Signals:
            onValueChanged: console.info("Slider value is now:", value)  // Signals on any value change (both user and programmatic changes)
            onUserSet: console.info("Slider set by user to:", value)     // Signals when user sets value

            // Functions:
            // slider.userSetValue(value)   // For custom connections to other user controls: set value as a user, userSet() signal will be called
        }
    }

    SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: demoLabel.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
        onCheckedChanged:  {
            if(checked)
                demoLabel.opacity = 1.0
            else demoLabel.opacity = 0.5
        }

    }
}
