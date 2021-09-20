/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import "./CanvasShapes.js" as CanvasShapesJS

Item {
    id: arrow
    implicitWidth: canvas.width + 2*padding
    implicitHeight: canvas.height + 2*padding

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
            } else if (orientation === Item.Left) {
                return Qt.point(0, Math.round(height/2))
            } else if (orientation === Item.Bottom) {
                return Qt.point(Math.round(width/2), Math.round(height))
            }

            //top
            return Qt.point(Math.round(width/2), 0)
        }

        onPaint: {
            if (arrow.visible === false) {
                return
            }

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
