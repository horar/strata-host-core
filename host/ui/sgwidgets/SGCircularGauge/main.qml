import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 400
    height: 400
    title: qsTr("Hello World")

    SGCircularGauge {
        id: sgCircularGauge
        value: data.stream

        anchors {
            fill: parent
        }

        // Optional Configuration:
        minimumValue: 0
        maximumValue: 100
        tickmarkStepSize: 10
        gaugeRearColor: "#ddd"
        centerColor: "black"
        outerColor: "#999"
        gaugeFrontColor1: Qt.rgba(0,.75,1,1)
        gaugeFrontColor2: Qt.rgba(1,0,0,1)
        unitLabel: "RPM"                        // Default: "RPM"
    }

    // Sends demo data stream with adjustible timing interval output
    Timer {
        id: data
        property real stream
        property real count: 0
        interval: 32  // 32 = 30fps
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/1000)*49+50;
        }
    }
}
