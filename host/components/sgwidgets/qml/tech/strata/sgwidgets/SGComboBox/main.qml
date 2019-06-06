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

    SGComboBox {
        id: sgComboBox

        model: ["Amps", "Volts", "Watts"]

        // Optional Configuration:
        label: "<b>ComboBox:</b>"   // Default: "" (if not entered, label will not appear)
        labelLeft: false            // Default: true
        comboBoxWidth: 150          // Default: 120 (set depending on model info length)
        textColor: "black"          // Default: "black"
        indicatorColor: "#aaa"      // Default: "#aaa"
        borderColor: "#aaa"         // Default: "#aaa"
        boxColor: "white"           // Default: "white"
        dividers: true              // Default: false
        popupHeight: 300            // Default: 300 (sets max height for popup if model is lengthy)

        // Useful Signals:
        onActivated: console.log("item " + index + " activated")
        //onCurrentTextChanged: console.log(currentText)
        //onCurrentIndexChanged: console.log(currentIndex)
        //onPressedChanged: console.log("pressedchanged")
        //onDownChanged: console.log("downchanged")
    }

    // Example button setting the index of the SGComboBox
    // - note that it does not trigger an activated signal
    Button {
        text: "Select 3rd Entry"
        y: 150
        onClicked: sgComboBox.currentIndex = 2
    }
}
