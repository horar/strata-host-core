import QtQuick 2.12
import QtQuick.Extras 1.4
import QtQuick.Extras.Private 1.0
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
    property int tickmarkDecimalPlaces: gauge.decimalPlacesFromStepSize

    property alias minimumValue: gauge.minimumValue
    property alias maximumValue: gauge.maximumValue
    property alias tickmarkStepSize : gauge.tickmarkStepSize
    property alias unitText: unitLabel.text

    CircularGauge {
        id: gauge
        value: root.value
        width: root.width > root.height ? root.height *.7 : root.width *.7
        height: root.height > root.width ? root.width *.7 : root.height *.7
        anchors {
            horizontalCenter: root.horizontalCenter
            verticalCenter: root.verticalCenter
            verticalCenterOffset: 0.05 * root.height
        }
        maximumValue: 100
        minimumValue: 0

        signal update()

        property real tickMarkStepRange: 10

        property real tickmarkStepSize: (maximumValue - minimumValue)/tickMarkStepRange
        property int decimalPlacesFromStepSize: {
                return (Math.floor(gauge.tickmarkStepSize) === gauge.tickmarkStepSize) ?  0 :
                        gauge.tickmarkStepSize.toString().split(".")[1].length || 0
                }

       onValueChanged: {
            update()
       }

        style : CircularGaugeStyle {
            id: gaugeStyle
            needle: null
            minimumValueAngle: -145
            maximumValueAngle: 145

            function degreesToRadians(deg){
                return deg * (Math.PI / 180)
            }

            function toDecimalPoint(value) {
                const decimalPlaces = countDecimalPlaces(root.maximumValue)
                return value * Math.pow(10,decimalPlaces)
            }

            function countDecimalPlaces(value){
                // found this on stack overflow for a simple decimal counter
                if(Math.floor(value.valueOf()) === value.valueOf()) return 0
                return value.toString().split(".")[1].length || 0
            }

            function scaleAngleValue(value, index){
                const decimalPlaces = countDecimalPlaces(value)
                return index * Math.pow(10, -decimalPlaces)
            }

            function getOffset() {
                const decimalValue = toDecimalPoint(root.maximumValue)
                return Math.ceil(decimalValue / 100)
            }

            background: Canvas {
                id: background

                onPaint: {
                    var ctx = getContext("2d")
                    var overCtx = getContext("2d")
                    ctx.reset()
                    overCtx.reset()

                    ctx.beginPath()
                    ctx.strokeStyle = gaugeBackgroundColor
                    ctx.lineWidth = outerRadius * 0.5

                    ctx.arc(outerRadius, outerRadius, outerRadius - ctx.lineWidth/2, degreesToRadians(valueToAngle(root.minimumValue) - 90), degreesToRadians(valueToAngle(root.maximumValue) - 90))
                    ctx.stroke()

                    for(var i = root.minimumValue; i < toDecimalPoint(gauge.value); i += getOffset()){
                        const currVal = scaleAngleValue(root.maximumValue,i);
                        const nextVal = scaleAngleValue(root.maximumValue, i + getOffset())

                        overCtx.beginPath()
                        overCtx.lineWidth = ctx.lineWidth
                        overCtx.strokeStyle  = lerpColor(gaugeFillColor1,gaugeFillColor2,currVal/root.maximumValue)
                        overCtx.arc(outerRadius, outerRadius, outerRadius - overCtx.lineWidth/2,degreesToRadians(valueToAngle(currVal) - 90),degreesToRadians(valueToAngle(nextVal) - 90))
                        overCtx.stroke()
                    }

                }

                Connections {
                    target: gauge

                    onUpdate: {
                        background.requestPaint()
                    }
                }

            }

            minorTickmark: null
            tickmarkLabel: null
            tickmark: null
            foreground: null

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
