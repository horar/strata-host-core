import QtQuick 2.12
import "./CanvasShapes.js" as CanvasShapesJS

Item {
    id: arrow

    property int cornerRadius: 10
    property int wingWidth: 4
    property int wingHeight: 10
    property int padding: 1
    property color color: "black"

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: parent.width - 2*padding
        height: parent.height - 2*padding

        onPaint: {
            var ctx = getContext("2d")

            var c1 = Qt.point(padding + wingWidth, padding)
            var c2 = Qt.point(width - padding, c1.y)

            CanvasShapesJS.drawArrow(
                        ctx,
                        Qt.point(c1.x, height - padding),
                        wingWidth,
                        wingHeight,
                        height - padding - wingHeight - cornerRadius,
                        Item.Bottom,
                        color)

            //tail
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.moveTo(c1.x, c1.y + cornerRadius)
            ctx.quadraticCurveTo(c1.x, c1.y, c1.x + cornerRadius, c1.y)
            ctx.lineTo(c2.x-cornerRadius, c2.y)
            ctx.quadraticCurveTo (c2.x, c2.y, c2.x, c2.y + cornerRadius)
            ctx.lineTo(c2.x, height - padding)

            ctx.strokeStyle = color
            ctx.stroke()
        }
    }
}
