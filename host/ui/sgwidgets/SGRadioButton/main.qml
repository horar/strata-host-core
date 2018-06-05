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
        exclusive: true             // Default: true
//        orientation: Qt.Horizontal  // Default: Qt.vertical
        textColor: "#000000"        // Default: "#000000" (black)
        radioColor: "#000000"       // Default: "#000000" (black)
        backgroundColor: "salmon"   // Default: "#ffffff" (white)
        highlightColor: "tomato"    // Default: "transparent"

        Rectangle{
            anchors.fill: parent
            color: "#eeeeee"
            z:-10
        }

        ListModel {
            id: radioModel

            ListElement {
                name: "Trapezoidal"
                checked: true
            }

            ListElement {
                name: "Pseudo-Sinusoidal"
//                disabled: true
            }

            ListElement {
                name: "Exponential"
            }
        }
    }

    // Debug Text
    Text {
        anchors {
            top: radioButtons.bottom
        }
        id: text
        text: qsTr("width:" + radioButtons.width + " height:" + radioButtons.height)
    }
}
