import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {
    id: circle
    implicitWidth: 80
    implicitHeight: 80

    property color baseColor: Theme.palette.lightGray
    property color highlightColor: Theme.palette.green
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
