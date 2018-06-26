import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGCapacityBar Demo")

    SGCapacityBar {
        id: capacityBar

        input: graphData.stream

        // Optional Configuration:
        label: "<b>Load Capacity:</b>"  // Default: "" (if not entered, label will not appear)
        labelLeft: false                // Default: true
        textColor: "black"

        gaugeElements: Rectangle {
            id: container

            SGCapacityBarElement{

            }
        }



        // Usable Signals:
    }


    // Sends demo data stream with adjustible timing interval output
    Timer {
        id: graphData
        property real stream
        property real count: 0
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/500)*30+50;
        }
    }
}
