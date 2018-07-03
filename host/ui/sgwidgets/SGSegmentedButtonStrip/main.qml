import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3

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
        activeColorTop: "#bbbbbb"       // Default: "#bbbbbb"
        activeColorBottom: "#999999"    // Default: "#999999"
        inactiveColorTop: "#dddddd"     // Default: "#dddddd"
        inactiveColorBottom: "#aaaaaa"  // Default: "#aaaaaa"
        buttonHeight: 35                // Default: 35
        radius: height/2                // Default: height/2
        exclusive: true                 // Default: true
        textColor: "black"              // Default: "black"
        enabled: true                  // Default: true

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
        }
    }
}
