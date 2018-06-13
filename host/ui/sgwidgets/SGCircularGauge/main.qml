import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    SGCircularGauge {
        id: sgCircularGauge
        value: data.stream

        anchors {
            centerIn: parent
        }

        maximumValue: 100
        minimumValue: 0
        gaugeRearColor: "#eeeeee"
        gaugeFrontColor: "lightgreen"
        demoColor: true
    }


    // Sends demo data stream with adjustible timing interval output
    Timer {
        id: data
        property real stream
        property real count: 0
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Math.sin(count/1000)*49+50;
        }
    }
}
