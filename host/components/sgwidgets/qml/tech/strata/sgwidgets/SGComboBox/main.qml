import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGComboBox Demo")

    SGAlignedLabel {
        id: demoLabel
        target: sgComboBox
        text: "Combo Box:"

        SGComboBox {
            id: sgComboBox

            model: ["Amps", "Volts", "Watts"] // demonstration model

            // Optional Configuration:
            dividers: true                              // Default: false
            // width: 150                               // Default: calculated based on longest text in model
            // height: 32 * fontSizeMultiplier          // Default: 32 * fontSizeMultiplier (set depending on model info length)
            // textColor: "black"                       // Default: "black"
            // fontSizeMultiplier: 1                    // Default: 1.0
            // indicatorColor: "#aaa"                   // Default: "#aaa"
            // borderColor: "#aaa"                      // Default: "#aaa"
            // boxColor: "white"                        // Default: "white"
            // popupHeight: 300 * fontSizeMultiplier    // Default: 300 * fontSizeMultiplier (sets max height for popup if model is lengthy)

            // Useful Signals:
            onActivated: console.log("item " + index + " activated")
            //onCurrentTextChanged: console.log(currentText)
            //onCurrentIndexChanged: console.log(currentIndex)
            //onPressedChanged: console.log("pressedchanged")
            //onDownChanged: console.log("downchanged")
        }
    }

    // Example button setting the index of the SGComboBox
    // - note that it does not trigger an activated signal
    Button {
        text: "Select 3rd Entry"
        y: 150
        onClicked:{
            sgComboBox.currentIndex = 2
        }
    }
}
