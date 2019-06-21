import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGRadioButton Example")

    SGRadioButtonContainer {
        id: buttons

        // Optional configuration:
        label: "Radio Buttons:" // Default: "" (will not appear if not entered)
        labelLeft: true         // Default: true
        textColor: "black"      // Default: "#000000"  (black)
        radioColor: "black"     // Default: "#000000"  (black)
        exclusive: true         // Default: true
        radioButtonSize: 20     // Default: 20 (can also be individually set for buttons)

        radioGroup: GridLayout {
            columnSpacing: 10
            rowSpacing: 10
            columns: 1          // Comment this line for horizontal row layout

            // Optional properties to access specific buttons cleanly from outside (see example button at bottom)
            property alias ps : ps
            property alias trap: trap
            property alias square: square

            SGRadioButton {
                id: ps
                text: "Pseudo-Sinusoidal"
                checked: true
                onCheckedChanged: { if (checked) console.log ( "PS Checked!") }
            }

            SGRadioButton {
                id: trap
                text: "Trapezoidal"
                onCheckedChanged: { if (checked) console.log ( "Trap Checked!") }
                enabled: false
            }

            SGRadioButton {
                id: square
                text: "Square"
                onCheckedChanged: { if (checked) console.log ( "Square Checked!") }
            }
        }
    }

    // Example of how to access/set radio checked properties
    Button {
        text: "Set Square"
        anchors {
            top: buttons.bottom
            topMargin: 20
        }
        onClicked: {
            buttons.radioButtons.square.checked = true
        }
    }
}
