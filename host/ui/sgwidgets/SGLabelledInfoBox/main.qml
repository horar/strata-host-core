import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGLabelledInfoBox Example")

    SGLabelledInfoBox {
        id: labelledInfoBox

        info: data.stream + " v"
        infoBoxWidth: 80            // Must be set by user based on their needs

        // Optional configuration:
        label: "Voltage:"               // Default: ""
        infoBoxColor: "#eeeeee"         // Default: "#eeeeee" (light gray)
        infoBoxBorderColor: "#cccccc"   // Default: "#cccccc" (light gray)
        infoBoxBorderWidth: 1           // Default: 1 (assign 0 for no border)
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
