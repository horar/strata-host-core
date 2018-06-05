import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGLabelledInfoBox Example")

    SGLabelledInfoBox {
        id: labelledInfoBox

        label: "Voltage:"
        info: data.stream + " v"
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
