import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {
    visible: true
    width: 300
    height: 300
    title: qsTr("SGOutputLogBox Demo")

    SGOutputLogBox{
        // Anchors fill parent by default.
        id: logBox

        input: data.stream

        // Optional SGOutputLogBox Settings:
        title: "Message Log"            // Default: "" (title bar will not be visible when empty string)
        titleTextColor: "#000000"       // Default: "#000000" (black)
        titleBoxColor: "#eeeeee"        // Default: "#eeeeee" (light gray)
        titleBoxBorderColor: "#dddddd"  // Default: "#dddddd" (light gray)
        outputTextColor: "#777777"      // Default: "#000000" (black)
        outputBoxColor: "#ffffff"       // Default: "#ffffff" (white)
        outputBoxBorderColor: "#dddddd" // Default: "#dddddd" (light gray)
    }

    // Send demo data to output box on a timed interval
    Timer {
        id: data
        property string stream
        property real count: 0
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            count += interval;
            stream = Date.now() + " Message " + count/100;
        }
    }
}
