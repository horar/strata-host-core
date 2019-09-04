import QtQuick 2.12
import QtQuick.Window 2.12
import tech.strata.sgwidgets 1.0

Window {
    id: root
    visible: true
    width: 400
    height: 400

    SGAlignedLabel {
        id: demoLabel
        target: sgCircularGauge
        alignment: SGAlignedLabel.SideBottomCenter
        margin: 0
        anchors.centerIn: parent
        text: "Output Voltage"
        fontSizeMultiplier: 2

        SGCircularGauge {
            id: sgCircularGauge
            value: data.stream

            // Optional Configuration:
            unitText: "Volts"               // Default: ""
            minimumValue: 0                 // Default: 0
            maximumValue: 3.3               // Default: 100
            tickmarkStepSize: .3            // Default: (maxVal-minVal)/10
            // centerTextColor: "black"
            // unitTextFontSizeMultiplier: 1.0
            // outerTextColor: "#999"
            // outerTextFontSizeMultiplier: 1.0
            // width: root.contentItem.width *.5
            // height: root.contentItem.height *.5
            // gaugeFillColor1: "#0cf"
            // gaugeFillColor2: "red"
            // gaugeBackgroundColor: "#ddd"
            // valueDecimalPlaces: 1        // Default: number of decimal places in tickmarkStepSize
            // tickmarkDecimalPlaces: 1     // Default: number of decimal places in tickmarkStepSize

            // You can override the way the colors are mixed by overriding the lerpColor function:
            // (default shows all color values between the colors, this will mix directly one to the other)
            //
            //  function lerpColor (color1, color2, x){
            //      if (Qt.colorEqual(color1, color2)){
            //          return color1;
            //      } else {
            //          return Qt.rgba(
            //              color1.r * (1 - x) + color2.r * x,
            //              color1.g * (1 - x) + color2.g * x,
            //              color1.b * (1 - x) + color2.b * x, 1
            //          );
            //      }
            //  }
        }
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
            stream = Math.sin(count/1000)*1.66+1.66;
        }
    }
}
