import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Column {
    anchors.fill: parent

    RowLayout {
        spacing: 10

        SGAlignedLabel {
            id: demoLabel
            target: sgComboBox
            text: "Default Combo Box"
            enabled: editEnabledCheckBox.checked
            fontSizeMultiplier: 1.3

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
                // textRole: "yourRoleName"                     // Default: undefined (must be set when using a ListModel instead of an array)

                // Useful Signals:
                onActivated: console.info("item " + index + " activated")
                //onCurrentTextChanged: console.log(currentText)
                //onCurrentIndexChanged: console.log(currentIndex)
                //onPressedChanged: console.log("pressedchanged")
                //onDownChanged: console.log("downchanged")
            }
        }

        Button {
            // Example button setting the index of the SGComboBox
            // - note that it does not trigger an activated signal
            text: "Select 3rd Entry"
            onClicked:{
                sgComboBox.currentIndex = 2
            }
        }
    }

    SGCheckBox {
        id: editEnabledCheckBox
        text: "Everything enabled"
        checked: true
    }
}
