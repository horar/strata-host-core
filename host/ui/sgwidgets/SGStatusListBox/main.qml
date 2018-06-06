import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {
    visible: true
    width: 300
    height: 300
    title: qsTr("SGOutputLogBox Demo")

    SGStatusListBox{
        // Anchors fill parent by default.
        id: logBox

        model: demoModel

        // Optional SGOutputLogBox Settings:
        title: "Message Log"            // Default: "" (title bar will not be visible when empty string)
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

    // Send demo data to output box on a timed interval
//    Timer {
//        id: data
//        property string stream
//        property real count: 0
//        interval: 100
//        running: true
//        repeat: true
//        onTriggered: {
//            count += interval;
//            stream = Date.now() + " Message " + count/100;
//        }
//    }

    Button{
        id: butt1
        text: "add to model"
        x: 200
        onClicked: {
            //for (var i = 0; i<100; i++){
                demoModel.append({"status":Date.now() + " fault"});
           // }
        }
    }
    Button{
        text: "remove from model"
        x: 200
        anchors.top: butt1.bottom
        onClicked: {
            //for (var i = 0; i<100; i++){
                if (demoModel.count > 0) {
                    demoModel.remove(demoModel.count-1);
                }
           // }
        }
    }
}
