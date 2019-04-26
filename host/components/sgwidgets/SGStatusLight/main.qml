import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGStatusLight Demo")

    SGStatusLight {
        id: sgStatusLight

        // Optional Configuration:
        label: "<b>Status:</b>" // Default: "" (if not entered, label will not appear)
        labelLeft: false        // Default: true
        status: "off"           // Default: "off"
        lightSize: 50           // Default: 50
        textColor: "black"           // Default: "black"

        // Useful Signals:
        onStatusChanged: console.log("Changed to " + status)
    }


    Button {
        id: switchStatus
        anchors {
            top: sgStatusLight.bottom
            topMargin: 50
        }
        property real status: 0
        text: "Switch Status"
        onClicked: {
            if (status > 3) { status = 0 } else { status++ }
            switch (status) {
                case 1:
                    sgStatusLight.status = "green"
                    break;
                case 2:
                    sgStatusLight.status = "yellow"
                    break;
                case 3:
                    sgStatusLight.status = "orange"
                    break;
                case 4:
                    sgStatusLight.status = "red"
                    break;
                default:
                    sgStatusLight.status = "off"
                    break;
            }
        }
    }
}
