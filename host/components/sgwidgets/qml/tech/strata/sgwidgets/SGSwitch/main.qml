import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Window {
    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("SGSwitch Demo")

    SGAlignedLabel {
        id: demoLabel
        target: sgSwitch
        text: "<b>Switch:</b>"

        SGSwitch {
            id: sgSwitch

            // Optional Configuration:
            checkedLabel: "Switch On"           // Default: "" (if not entered, label will not appear)
            uncheckedLabel: "Switch Off"        // Default: "" (if not entered, label will not appear)
            // width: 100                       // Default: switchRow.implicitWidth
            // height: 25                       // Default: 25 * fontSizeMultiplier
            // labelsInside: false              // Default: true
            // textColor: "white"               // Default: labelsInside ? "white" : "black"
            // handleColor: "white"             // Default: "white"
            // grooveColor: "#ccc"              // Default: "#B3B3B3"
            // grooveFillColor: "#0cf"          // Default: "#0cf"
            // fontSizeMultiplier: 3            // Default: 1.0

            // Usable Signals:
            onCheckedChanged: console.log("Checked toggled")
            onReleased: console.log("Switch released")
            onCanceled: console.log("Switch canceled")
            onClicked: console.log("Switch clicked")
            onPress: console.log("Switch pressed")
            onPressAndHold: console.log("Switch pressed and held")
        }
    }
}
