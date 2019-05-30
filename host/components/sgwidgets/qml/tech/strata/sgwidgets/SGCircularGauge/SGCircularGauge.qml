import QtQuick 2.12
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

import tech.strata.fonts 1.0

Item {
    id: root

    property real value: 0
    property real maximumValue: 100
    property real minimumValue: 0
    property color gaugeRearColor: "#ddd"
    property color centerColor: "black"
    property color outerColor: "#bbb"
    property color gaugeFrontColor1: Qt.rgba(0,.75,1,1)
    property color gaugeFrontColor2: gaugeFrontColor1
    property real tickmarkStepSize : 10
    property string unitLabel: "RPM"

    implicitWidth: 256
    implicitHeight: 256

    CircularGauge {
        id: gauge
        value: (root.value-root.minimumValue)/(root.maximumValue-root.minimumValue)*200 // Normalize incoming values against 200 tickmarks
        width: root.width > root.height ? root.height *.7 : root.width *.7
        height: root.height > root.width ? root.width *.7 : root.height *.7
        anchors {
            centerIn: root
        }

        maximumValue: 200
        minimumValue: 0

        style : CircularGaugeStyle {
            id: gaugeStyle
            needle: null
            foreground: null
            tickmarkLabel: null
            tickmarkStepSize: 1
            minorTickmark: null
            tickmark: Rectangle {
                id: tickmarks
//                color: styleData.value > gauge.value ? root.gaugeRearColor : (styleData.value > gauge.value-1 ? "red" : "root.gaugeFrontColor")
                color: styleData.value >= gauge.value ? root.gaugeRearColor : lerpColor(root.gaugeFrontColor1, root.gaugeFrontColor2, styleData.value/gauge.maximumValue)
                width: gauge.width / 68.26
                height: gauge.width / 4.26
                antialiasing: true
            }
        }

        Text {
            id: gaugeValue
            text: root.value.toFixed(0)
            color: root.centerColor
            anchors { centerIn: gauge }
            font.family: Fonts.digitalseven
            font.pixelSize: Math.min(gauge.width / 3, gauge.width/Math.max((root.maximumValue+ "").length, (root.minimumValue + "").length)) // Scale the gauge font based on what the largest or smallest number that might be displayed
            renderType: Text.NativeRendering
        }
        Text {
            id: gaugeLabel
            text: unitLabel
            color: root.centerColor
            anchors {
                top: gaugeValue.bottom
                topMargin: - gauge.width / 25.6
                horizontalCenter: gaugeValue.horizontalCenter

            }
            font.pixelSize: gauge.width / 21.3
            font.italic: true
        }

        CircularGauge {
            id: ticksBackground
            z: -1
            width: gauge.width
            height: gauge.height
            anchors {
              centerIn: gauge
            }
            minimumValue: root.minimumValue
            maximumValue: root.maximumValue

            style : CircularGaugeStyle {
                tickmarkStepSize: root.tickmarkStepSize
                id: gaugeStyle2
                needle: null
                foreground: null
                minorTickmark: null
                tickmarkInset: -ticksBackground.width / 34
                labelInset: -ticksBackground.width / (12.8 - Math.max((root.maximumValue+ "").length, (root.minimumValue + "").length))  // Base label distance from gauge center on max/minValue
                minimumValueAngle: -145.25
                maximumValueAngle: 145.25
                tickmarkLabel:  Text {
                    font.pixelSize: Math.max(1, outerRadius * 0.125)
                    text: styleData.value
                    color: root.outerColor
                    antialiasing: true
                }
                tickmark: Rectangle {
                    color: root.outerColor
                    width: gauge.width / 100
                    height: gauge.width / 30
                    antialiasing: true
                }
            }
        }
    }

    function lerpColor (color1, color2, x){
        if (Qt.colorEqual(color1, color2)){
            return color1;
        } else {
            return Qt.hsva(
                color1.hsvHue * (1 - x) + color2.hsvHue * x,
                color1.hsvSaturation * (1 - x) + color2.hsvSaturation * x,
                color1.hsvValue * (1 - x) + color2.hsvValue * x, 1
                );
        }
    }
}
