import QtQuick 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGLabelledInfoBox Example")

    SGLabelledInfoBox {
        id: customLabelledInfoBox

        info: data.stream + " v"    // String to this to be displayed in box
        infoBoxWidth: 80            // Must be set by user based on their needs

        // Optional configuration:
        label: "Voltage:"               // Default: "" (if not entered, label will not appear)
        labelLeft: false                // Default: true (if false, label will be on top)
        infoBoxColor: "lightgreen"      // Default: "#eeeeee" (light gray)
        infoBoxBorderColor: "green"     // Default: "#cccccc" (light gray)
        infoBoxBorderWidth: 1           // Default: 1 (assign 0 for no border)
        textColor: "black"              // Default: "black" (colors label as well as text in box
    }

    SGLabelledInfoBox {
        id: defaultLabelledInfoBox
        infoBoxWidth: 70
        label: "Speed:"
        info: "40 rpm"

        anchors {
            top: customLabelledInfoBox.bottom
            topMargin: 20
        }
    }

    // Sends demo data stream to infoBox
    Timer {
        id: data
        property real stream
        property real count: 0
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = (Math.sin(count/500)*3+10).toFixed(2);
        }
    }
}
