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
        label: "Switch:"
        checkedLabel: "On"
        uncheckedLabel: "Off"
        labelsInside: true



        Rectangle {
            color: "tomato"
            opacity: .1
            anchors {
                fill: parent
            }
            z:20
            Component.onCompleted: console.log("height: " + height + "\n     width:  " + width)
        }
    }

    Button {
       text: "whatever"
       y:100
       onClicked: {
           //sgSwitch.vertical = !sgSwitch.vertical

       }
    }
}
