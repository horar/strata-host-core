import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGSwitch Demo")

    SGSwitch {
        id: sgSwitch

        // Optional Configuration:
        label: "<b>Switch:</b>"
        checkedLabel: "Switch On"
        uncheckedLabel: "Switch Off"
        labelsInside: true
        switchWidth: 84                 // Default: 52 (change for long custom checkedLabels when labelsInside)
        textColor: "black"
        handleColor: "white"
        grooveColor: "#ccc"
        grooveFillColor: "#0cf"
        labelLeft: false
    }
}
