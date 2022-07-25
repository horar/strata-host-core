/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQml 2.12
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
    property int tickmarkDecimalPlaces: gauge.decimalPlacesFromStepSize

    property alias minimumValue: gauge.minimumValue
    property alias maximumValue: gauge.maximumValue
    property alias tickmarkStepSize : gauge.tickmarkStepSize
    property alias unitText: unitLabel.text
    property alias gaugeObject: gauge

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

        property real tickMarkStepRange: 10
        property real tickmarkStepSize: (maximumValue - minimumValue)/tickMarkStepRange
        property int decimalPlacesFromStepSize: {
                return (Math.floor(gauge.tickmarkStepSize) === gauge.tickmarkStepSize) ?  0 :
                        gauge.tickmarkStepSize.toString().split(".")[1].length || 0
                }

        style : CircularGaugeStyle {
            id: gaugeStyle
            needle: null
            tickmarkInset: -gauge.width / 34
            labelInset: -gauge.width / (12.8 - Math.max((root.maximumValue+ "").length, (root.minimumValue + "").length))  // Base label distance from gauge center on max/minValue
            minimumValueAngle: -145
            maximumValueAngle: 145
            tickmarkStepSize: gauge.tickmarkStepSize
            minorTickmark: null

            readonly property int maxSlices: 40
            property var center: { "x": outerRadius, "y": outerRadius}
            property real lineWidth: outerRadius * 0.45
            property real radius: outerRadius - lineWidth/2
            property real ratio: Math.max(0, Math.min((root.value - root.minimumValue)/(root.maximumValue - root.minimumValue), 1)) // bound to 0, 1

            tickmarkLabel:  SGText {
                                text: (gauge.minimumValue + (gaugeStyle.tickmarkStepSize * styleData.index)).toFixed(root.tickmarkDecimalPlaces)
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

            background: Canvas {
                id: background

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()

                    ctx.beginPath()
                    ctx.strokeStyle = gaugeBackgroundColor
                    ctx.lineWidth = lineWidth

                    const angleStart = (Math.PI * .695)
                    const angleEnd = (Math.PI * 1.614) + angleStart

                    ctx.arc(center.x, center.y, radius, angleStart, angleEnd)
                    ctx.stroke()
                }
            }

            foreground: Canvas {
                id: foreground

                onPaint: {
                    let ctx = getContext("2d")
                    ctx.reset()
                    ctx.lineWidth = lineWidth;

                    const rawSlices = ratio * maxSlices
                    const totalSlices = Math.ceil(rawSlices)
                    const partialSlice = rawSlices - (totalSlices -1)

                    let slices = [];

                    // Build slice model.
                    for (let k = 0; k < totalSlices; k++) {
                        let buildSlice = {
                                       // ((80.7% of circle to match min/maximumValueAngle) * (slice size)) + (offset to angle notch down)
                            "angleStart": ((Math.PI * 1.614) * (k/maxSlices) -.01) + (Math.PI * .695), // -.01 for small overlap, otherwise can see seams
                        }

                        if (k === totalSlices-1) { // partial slice at end of arc
                            buildSlice.angleEnd = ((Math.PI * 1.614) * ((k+partialSlice)/maxSlices)) + (Math.PI * .695)
                            buildSlice.colorStops = [
                                        { "stop": 0, "color": lerpColor(gaugeFillColor1, gaugeFillColor2, (k/maxSlices)) },
                                        { "stop": 1, "color": lerpColor(gaugeFillColor1, gaugeFillColor2, ((k+partialSlice)/maxSlices)) }
                                    ]
                        } else {
                            buildSlice.angleEnd = ((Math.PI * 1.614) * ((k+1)/maxSlices)) + (Math.PI * .695)
                            buildSlice.colorStops = [
                                        { "stop": 0, "color": lerpColor(gaugeFillColor1, gaugeFillColor2, (k/maxSlices)) },
                                        { "stop": 1, "color": lerpColor(gaugeFillColor1, gaugeFillColor2, ((k+1)/maxSlices)) }
                                    ]
                        }

                        buildSlice.x1 = center.x + radius * Math.cos(buildSlice.angleStart)
                        buildSlice.y1 = center.y + radius * Math.sin(buildSlice.angleStart)
                        buildSlice.x2 = center.x + radius * Math.cos(buildSlice.angleEnd)
                        buildSlice.y2 = center.y + radius * Math.sin(buildSlice.angleEnd)

                        slices.push(buildSlice)
                    }

                    // Draw arc slices.
                    for (let i = 0; i < slices.length; ++i) {
                        const slice = slices[i];
                        let gradient = ctx.createLinearGradient(slice.x1, slice.y1, slice.x2, slice.y2);
                        for (let j = 0; j < slice.colorStops.length; ++j) {
                            let cs = slice.colorStops[j];
                            gradient.addColorStop(cs.stop, cs.color);
                        }
                        ctx.beginPath();
                        ctx.arc(center.x, center.y, radius, slice.angleStart, slice.angleEnd);
                        ctx.strokeStyle = gradient;
                        ctx.stroke();
                    }
                }

                Connections {
                    target: gauge

                    onValueChanged: {
                        foreground.requestPaint()
                    }
                }
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
