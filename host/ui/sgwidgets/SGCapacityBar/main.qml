import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGCapacityBar Demo")

    SGCapacityBar {
        id: capacityBar

        // Optional Configuration:
        label: "<b>Load Capacity:</b>"  // Default: "" (if not entered, label will not appear)
        labelLeft: true                 // Default: true
        textColor: "black"              // Default: "black"
        showThreshold: true             // Default: false
        thresholdValue: 80              // Default: maximumValue
        minimumValue: 0                 // Default: 0
        maximumValue: 100               // Default: 100
        barWidth: 300                   // Default: 300

        gaugeElements: Row {
            id: container
            property real totalValue: childrenRect.width // Necessary for over threshold detection signal

            SGCapacityBarElement{
                color: "#7bdeff"
                value: graphData.stream1
            }

            SGCapacityBarElement{
                color: "#c6e78f"
                value: graphData.stream2
            }
        }

        // Usable Signals:
        onOverThreshold: console.log("Over Threshold!")
    }

    // Sends demo data stream with adjustible timing interval output
    Timer {
        id: graphData
        property real stream1
        property real stream2
        property real count: 0
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream1 = Math.sin(count/500)*10+50;
            stream2 = Math.sin((count-800)/500)*10+25;
        }
    }
}
