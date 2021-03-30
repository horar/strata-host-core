import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGButtonStrip Example")

    SGSegmentedButtonStrip {
        id: segmentedButtonsExample

        anchors {
            centerIn: parent    // Example anchoring, spec something else for real use
        }

        // Optional configurations:
        label: "Input:"                 // Default: "" (will not appear if not entered)
        labelLeft: false                // Default: true (true: label on left, false: label on top)
        activeColor: "#999"             // Default: "#999"
        inactiveColor: "#ddd"           // Default: "#ddd"
        buttonHeight: 35                // Default: 35
        radius: 5                       // Default: height/2
        exclusive: true                 // Default: true
        textColor: "black"              // Default: "black"
        enabled: true                   // Default: true
        activeTextColor: "white"        // Default: "white"

        segmentedButtons: GridLayout {
            columnSpacing: 2

            SGSegmentedButton{
                text: qsTr("DVD")
                checked: true  // Sets default checked button when exclusive
            }

            SGSegmentedButton{
                text: qsTr("Blu-Ray")
            }

            SGSegmentedButton{
                text: qsTr("VHS")
            }

            SGSegmentedButton{
                text: qsTr("Radio")
            }

            SGSegmentedButton{
                text: qsTr("Betamax")
            }

            SGSegmentedButton{
                text: qsTr("8-track")
            }
        }

        // Helpful signals:
        //onNothingCheckedChanged: console.log("nothingChecked changed!")  // For non-exclusive buttons, alerts when the status of "no buttons are checked" changes
        //onIndexChanged: console.log("index is now", index)  // For exclusive buttons, alerts the index of the last clicked button
    }
}
