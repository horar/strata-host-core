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
        id: green
        y: 200
        text: "Green"
        onClicked: sgStatusLight.status = "green"
    }

    Button {
        id: red
        anchors {
            top: green.bottom
        }
        text: "Red"
        onClicked: sgStatusLight.status = "red"
    }

    Button {
        id: yellow
        anchors {
            top: red.bottom
        }
        text: "Yellow"
        onClicked: sgStatusLight.status = "yellow"
    }

    Button {
        id: orange
        anchors {
            top: yellow.bottom
        }
        text: "Orange"
        onClicked: sgStatusLight.status = "orange"
    }

    Button {
        id: off
        anchors {
            top: orange.bottom
        }
        text: "Off"
        onClicked: sgStatusLight.status = "off"
    }
}
