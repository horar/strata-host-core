import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGOutputLogBox Demo")

    SGOutputLogBox{
        // Anchors fill parent by default.
        id: logBox
        title: ""   // Default: "" (title bar will not be visible with this string)


    }

    // Debug button to start/stop data flow
    Button {
        text: data.running ? "stop" : "start"
        anchors.right: parent.right
        checkable: true
        onClicked: data.running = !data.running
    }

    // Spit out data to output box on a timed interval
    Timer {
        id: data
        property real stream
        property real count: 0
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            logBox.input = Date.now() + " Message " + count;
        }
    }
}
