import QtQuick 2.9
import QtQuick.Window 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGLabelledInfoBox Example")

    SGLabelledInfoBox {
        id: customColoredLabelledInfoBox

        info: data.stream + " v"        // String to this to be displayed in box
        infoBoxWidth: 3 * infoBoxHeight // Must be set based on user needs, can be dynamic (3 * infoBoxHeight) or hard-coded (30)

        // Optional configuration:
        label: "Voltage:"               // Default: "" (if not entered, label will not appear)
        labelLeft: false                // Default: true (if false, label will be on top)
        labelPixelSize: 14              // Default: 14
        infoBoxColor: "lightgreen"      // Default: "#eeeeee" (light gray)
        infoBoxBorderColor: "green"     // Default: "#cccccc" (light gray)
        infoBoxBorderWidth: 1           // Default: 1 (assign 0 for no border)
        infoBoxHeight: 2 * textPixelSize// Default: textPixelSize * 2.5
        textColor: "black"              // Default: "black" (colors label as well as text in box)
        textPixelSize: 14               // Default: 14
        textPadding: 6                  // Default: .5 * textPixelSize
        // overrideLabelWidth: 100      // For aligning labels and boxes in a column regardless of label width when labelLeft is true
    }

    SGLabelledInfoBox {
        id: responsiveScalingLabelledInfoBox
        label: "Speed:"
        info: "40 rpm"
        infoBoxWidth: 2 * infoBoxHeight
        textPixelSize: parent.width/10
        labelPixelSize: textPixelSize

        anchors {
            top: customColoredLabelledInfoBox.bottom
            topMargin: 20
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
