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
        labelLeft: false             // Default: true (if false, label will be on top)
        exclusive: true             // Default: true (modifies exclusivity of the checked property)
        orientation: Qt.Horizontal  // Default: Qt.vertical
        textColor: "#000000"        // Default: "#000000" (black)
        radioColor: "#000000"       // Default: "#000000" (black)
        highlightColor: "lightgrey" // Default: "transparent"

        onButtonSelected: console.log(selected, "is selected")

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

    // Example button showing one method to iterate through and lock/unlock radio buttons
    Button {
        anchors {
            top: radioButtons.bottom
            topMargin: 20
        }
        text: checked ? "Locked" : "Unlocked"
        checked: true
        checkable: true
        onCheckedChanged: {
            for (var i=0; i<radioModel.count; i++){
                if (radioModel.get(i).name === "Pseudo-Sinusoidal"){
                    radioModel.get(i).disabled = !radioModel.get(i).disabled;
                }
            }
        }
    }
}
