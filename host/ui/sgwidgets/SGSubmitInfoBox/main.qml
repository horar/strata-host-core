import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGSubmitInfoBox Demo")

    SGSubmitInfoBox {
        id: applyInfoBox

        value: "6"                  // Default string to be displayed in box
        infoBoxWidth: 80            // Must be set by user based on their needs

        // Optional configuration:
        label: "Voltage (volts):"       // Default: "" (if not entered, label will not appear)
        labelLeft: false                // Default: true (if false, label will be on top)
        infoBoxColor: "#eee"            // Default: "#eeeeee" (light gray)
        infoBoxBorderColor: "#999"      // Default: "#999999" (dark gray)
        infoBoxBorderWidth: 1           // Default: 1 (assign 0 for no border)
        realNumberValidation: true      // Default: false (set true to restrict enterable values to real numbers)
        textColor: "black"              // Default: "black" (colors label as well as text in box
        enabled: true                   // Default: true
        buttonText: "Apply"             // Default: "submit"
        showButton: true                // Default: false
        unit: "V"                       // Default: ""
//        overrideLabelWidth: 100       // Default: label contents width - this is useful for lining up lots of these vertically, set them all to the same value

        // Useful Signals:
        onApplied: console.log("Applied string value is " + value)
    }
}
