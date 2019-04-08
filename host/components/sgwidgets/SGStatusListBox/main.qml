import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

Window {
    visible: true
    width: 300
    height: 300
    title: qsTr("SGStatusListBox Demo")

    SGStatusListBox{
        id: logBox
        model: demoModel

        // Demo Anchors
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        // Optional Configuration:
        title: "Status List"            // Default: "" (title bar will not be visible when empty string)
        titleTextColor: "#000000"       // Default: "#000000" (black)
        titleBoxColor: "#eeeeee"        // Default: "#eeeeee" (light gray)
        titleBoxBorderColor: "#dddddd"  // Default: "#dddddd" (light gray)
        statusTextColor: "#777777"      // Default: "#000000" (black)
        statusBoxColor: "#ffffff"       // Default: "#ffffff" (white)
        statusBoxBorderColor: "#dddddd" // Default: "#dddddd" (light gray)
    }

    ListModel {
        id: demoModel
        ListElement {
            status: "Port 1 Temperature: 71°C"
        }
    }

    Button{
        id: debugButton
        text: "add to model"
        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        onClicked: {
            demoModel.append({ "status" : Date.now() + " fault" });
        }
    }

    Button{
        text: "remove from model"
        x: 200
        anchors {
            bottom: debugButton.bottom
            left: debugButton.right
        }
        onClicked: {
            if (demoModel.count > 0) {
                demoModel.remove(demoModel.count-1);
            }
        }
    }
}
