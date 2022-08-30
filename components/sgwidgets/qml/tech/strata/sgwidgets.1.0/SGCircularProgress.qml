/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {
    id: circle
    implicitWidth: 80
    implicitHeight: 80

    property color baseColor: TangoTheme.palette.aluminium2
    property color highlightColor: TangoTheme.palette.chameleon2
    property alias textColor: infoText.color

    /* from 0 to 1 */
    property real value: 0.0

    onBaseColorChanged: canvas.requestPaint()
    onHighlightColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors. fill: parent

        property int percentageValue: Math.floor(value*100)
        property int baseThickness: Math.max(1, Math.round(height/12))
        property int highlightThickness: baseThickness > 2 ? baseThickness + 2 : baseThickness
        property real centerX: width/2
        property real centerY: height/2
        property real radius: Math.min(width - highlightThickness, height- highlightThickness) / 2
        property real angle: 2 * Math.PI * Math.min(1, Math.max(0, percentageValue/100))
        property real angleOffset: -Math.PI / 2

        antialiasing: true

        onAngleChanged: requestPaint()
        onBaseThicknessChanged: requestPaint()
        onHighlightThicknessChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.save();

            ctx.clearRect(0, 0, width, height);

            //base line
            ctx.beginPath()
            ctx.lineWidth = baseThickness
            ctx.strokeStyle = baseColor
            ctx.arc(centerX,
                    centerY,
                    radius,
                    angleOffset + angle,
                    angleOffset + 2*Math.PI)

            ctx.stroke()

            //progress line
            ctx.beginPath();
            ctx.lineWidth = highlightThickness;
            ctx.strokeStyle = highlightColor;
            ctx.arc(centerX,
                    centerY,
                    radius,
                    angleOffset,
                    angleOffset + angle);
            ctx.stroke();

            ctx.restore();
        }
    }

    SGWidgets.SGText {
        id: infoText
        anchors.centerIn: parent
        font.bold: true
        font.pixelSize: Math.floor(parent.height/4)
        color: "#666666"
        text: canvas.percentageValue + "%"
        font.family: "monospace"
    }
}
