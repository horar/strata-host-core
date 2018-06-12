import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGRadioButton Example")

    SGRadioButton {
        id: radioButtons
        model: radioModel

        // Optional Configuration:
        label: "Radio Buttons:"     // Default: "" (if not entered, label will not appear)
        labelLeft: false            // Default: true (if false, label will be on top)
        exclusive: true             // Default: true (modifies exclusivity of the checked property)
        orientation: Qt.Horizontal  // Default: Qt.vertical
        textColor: "#000000"        // Default: "#000000" (black)
        radioColor: "#000000"       // Default: "#000000" (black)
        highlightColor: "lightgreen"    // Default: "transparent"

        ListModel {
            id: radioModel

            ListElement {
                name: "Trapezoidal"
                checked: true               // One element pre-checked when exclusive
            }

            ListElement {
                name: "Pseudo-Sinusoidal"
                disabled: true              // Option to lock element
            }

            ListElement {
                name: "Exponential"
            }
        }
    }
}
