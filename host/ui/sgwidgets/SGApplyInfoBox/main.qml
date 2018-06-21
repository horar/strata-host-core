import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGApplyInfoBox Demo")


    SGApplyInfoBox {
        id: applyInfoBox

        input: "6"    // String to this to be displayed in box
        infoBoxWidth: 80            // Must be set by user based on their needs

        // Optional configuration:
        label: "Voltage (volts):"       // Default: "" (if not entered, label will not appear)
        labelLeft: true                 // Default: true (if false, label will be on top)
        infoBoxColor: "#eee"            // Default: "#eeeeee" (light gray)
        infoBoxBorderColor: "#999"      // Default: "#999999" (dark gray)
        infoBoxBorderWidth: 1           // Default: 1 (assign 0 for no border)
        realNumberValidation: true      // Default: false (set true to restrict enterable values to real numbers)

        // Useful Signals:
        onApplied: console.log("Applied string value is " + value)
    }
}
