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
        labelLeft: false                // Default: true
        textColor: "black"
        showThreshold: true
        thresholdValue: 80

        gaugeElements: Row {
            id: container
            width: childrenRect.width


            SGCapacityBarElement{
                color: "#7bdeff"
                value: graphData.stream
            }

            SGCapacityBarElement{
                color: "#c6e78f"
                value: graphData2.stream
            }
        }

        // Usable Signals:
    }

Button {
    onClicked: console.log(capacityBar.gaugeElements.width)
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
            stream = Math.sin(count/500)*10+25;
        }
    }

    Timer {
        id: graphData2
        property real stream
        property real count: 0
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin((count-800)/500)*10+25;
        }
    }
}
