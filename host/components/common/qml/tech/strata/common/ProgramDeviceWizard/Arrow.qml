import QtQuick 2.12
import "./CanvasShapes.js" as CanvasShapesJS

Item {
    id: arrow
    width: canvas.width + 2*padding
    height: canvas.height + 2*padding

    property int cornerRadius: 30
    property int wingWidth: 4
    property int wingHeight: 10
    property int tailLength: 30
    property int padding: 2
    property int orientation: Item.Right
    property color color: "black"

    Canvas {
        id: canvas
        anchors.centerIn: parent
        width: orientation === Item.Left || orientation === Item.Right ? horizontalWidth : horizontalHeight
        height: orientation === Item.Left || orientation === Item.Right ? horizontalHeight : horizontalWidth

        property int horizontalWidth: wingHeight + tailLength
        property int horizontalHeight: 2*wingWidth

        property point tipPoint: {
            if (orientation === Item.Right) {
                return Qt.point(width, Math.round(height/2))
            } else if(orientation === Item.Left) {
                return Qt.point(0, Math.round(height/2))
            } else if (orientation === Item.Bottom) {
                return Qt.point(Math.round(width/2), Math.round(height))
            }

            //top
            return Qt.point(Math.round(width/2), 0)
        }

        onPaint: {
            var ctx = getContext("2d")
            CanvasShapesJS.drawArrow(
                        ctx,
                        tipPoint,
                        wingWidth,
                        wingHeight,
                        tailLength,
                        orientation,
                        color)
        }
    }
}
