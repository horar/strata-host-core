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


        maximumValue: 100
        minimumValue: 0
        gaugeRearColor: "#eeeeee"
        gaugeFrontColor: "lightgreen"
        demoColor: true
        Component.onCompleted: console.log(width +  " " + height)
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
