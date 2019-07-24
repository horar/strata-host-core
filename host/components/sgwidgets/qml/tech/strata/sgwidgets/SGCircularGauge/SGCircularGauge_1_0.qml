import QtQuick 2.12
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import tech.strata.fonts 1.0

Item {
    id: root
    implicitWidth: 256
    implicitHeight: 256

    property real value: 0
    property color gaugeFillColor1: "#0cf"
    property color gaugeFillColor2: "red"
    property color gaugeBackgroundColor: "#E5E5E5"
    property color centerTextColor: "black"
    property color outerTextColor: "#808080"
    property real unitTextFontSizeMultiplier: 1.0
    property real outerTextFontSizeMultiplier: 1.0
    property int valueDecimalPlaces: tickmarkDecimalPlaces
    property int tickmarkDecimalPlaces: ticksBackground.decimalPlacesFromStepSize

    property alias unitText: unitLabel.text
    property alias maximumValue: ticksBackground.maximumValue
    property alias minimumValue: ticksBackground.minimumValue
    property alias tickmarkStepSize : ticksBackground.tickmarkStepSize

    CircularGauge {
        id: gauge
        value: (root.value-root.minimumValue)/(root.maximumValue-root.minimumValue)*200 // Normalize incoming values against 200 tickmarks
        width: root.width > root.height ? root.height *.7 : root.width *.7
        height: root.height > root.width ? root.width *.7 : root.height *.7
        anchors {
            horizontalCenter: root.horizontalCenter
            verticalCenter: root.verticalCenter
            verticalCenterOffset: 0.05 * root.height
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
                color: styleData.value >= gauge.value ? root.gaugeBackgroundColor : lerpColor(root.gaugeFillColor1, root.gaugeFillColor2, styleData.value/gauge.maximumValue)
                width: gauge.width / 68.26
                height: gauge.width / 4.26
                antialiasing: true
            }
        }

        SGText {
            id: gaugeValue
            text: root.value.toFixed(root.valueDecimalPlaces)
            color: root.centerTextColor
            anchors { centerIn: gauge }
            font.family: Fonts.digitalseven
            fontSizeMultiplier: {
                // Auto scales value to fit inside gauge
                (6 -                                        // base font multiplier
                (gaugeValueHelper.contentWidth / 10)) *     // scale of base font vs necessary space
                (gauge.height / (root.implicitHeight *.7))  // scaled to current gauge size
            }
            renderType: Text.NativeRendering

            SGText {
                id: gaugeValueHelper
                text: gaugeValue.text
                color: root.centerTextColor
                visible: false
                width: 0
                height: 0
                font.family: Fonts.digitalseven
            }
        }

        SGText {
            id: unitLabel
            color: root.centerTextColor
            anchors {
                top: gaugeValue.bottom
                topMargin: - gauge.width / 25.6
                horizontalCenter: gaugeValue.horizontalCenter
            }
            fontSizeMultiplier: (gauge.width / 256) * unitTextFontSizeMultiplier
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
            minimumValue: 0
            maximumValue: 100
            property real tickmarkStepSize: (maximumValue - minimumValue)/10

            property int decimalPlacesFromStepSize: {
                return (Math.floor(ticksBackground.tickmarkStepSize) === ticksBackground.tickmarkStepSize) ?  0 :
                       ticksBackground.tickmarkStepSize.toString().split(".")[1].length || 0
            }

            style : CircularGaugeStyle {
                id: gaugeStyle2
                tickmarkStepSize: ticksBackground.tickmarkStepSize
                needle: null
                foreground: null
                minorTickmark: null
                tickmarkInset: -ticksBackground.width / 34
                labelInset: -ticksBackground.width / (12.8 - Math.max((root.maximumValue+ "").length, (root.minimumValue + "").length))  // Base label distance from gauge center on max/minValue
                minimumValueAngle: -145.25
                maximumValueAngle: 145.25

                tickmarkLabel:  SGText {
                    text: styleData.value.toFixed(root.tickmarkDecimalPlaces)
                    color: root.outerTextColor
                    antialiasing: true
                    fontSizeMultiplier: root.outerTextFontSizeMultiplier * (outerRadius * (1/100))
                }

                tickmark: Rectangle {
                    color: root.outerTextColor
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
