import QtQuick 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGInfoBox Example")

    SGAlignedLabel {
        id: demoLabel
        target: infoBox
        text: "Voltage:"

        SGInfoBox {
            id: infoBox
            text: data.stream                           // String to this to be displayed in box

            // Optional configuration:
            unit: "V"                                   // Default: ""
            // width: 200                               // Default: 100
            // height: 26                               // Default: 26 * fontSizeMultiplier
            // horizontalAlignment: Text.AlignHCenter   // Default: Text.AlignRight (sets alignment of text in box)
            // textColor: "black"                       // Default: "black" (affects text and unit)
            // fontSizeMultiplier: 2.0                  // Default: 1.0 (affects text and unit)
            // boxColor: "lightgreen"                   // Default: "#eeeeee" (light gray)
            // boxBorderColor: "green"                  // Default: "#cccccc" (light gray)
            // boxBorderWidth: 1                        // Default: 1 (assign 0 for no border)
        }
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
