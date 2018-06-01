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
        id: seg1

        anchors {
            centerIn: parent    // Example anchoring, spec something else for real use
        }

        // Optional configurations:
        activeColorTop: "#bbbbbb"       // Default: "#bbbbbb"
        activeColorBottom: "#999999"    // Default: "#999999"
        inactiveColorTop: "#dddddd"     // Default: "#dddddd"
        inactiveColorBottom: "#aaaaaa"  // Default: "#aaaaaa"
        height: 35                      // Default: 35
        radius: height/2                // Default: height/2
        exclusive: true                 // Default: true

        segmentedButtons: GridLayout {
            id: grid

            columnSpacing: 2

            SGSegmentedButton{
                id: button1
                text: qsTr("Button1 longer text")
                checked: true  // Sets default checked button when exclusive
            }

            SGSegmentedButton{
                id: button2
                text: qsTr("Button2")
            }

            SGSegmentedButton{
                id: button3
                text: qsTr("Button3")
            }

            SGSegmentedButton{
                id: button4
                text: qsTr("Button4")
            }

            SGSegmentedButton{
                id: button5
                text: qsTr("Button5")
            }

            SGSegmentedButton{
                id: button6
                text: qsTr("Button6")
            }

            SGSegmentedButton{
                id: button7
                text: qsTr("Button7")
            }
        }
    }
}
