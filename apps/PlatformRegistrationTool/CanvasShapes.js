/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library
.import QtQuick 2.12 as QtQuickModule

function drawArrow(
    ctx,
    tip,
    wingWidth,
    wingHeight,
    tailLength,
    orientation,
    color)
{
    ctx.fillStyle = color
    ctx.strokeStyle = color

    ctx.beginPath()

    //head
    ctx.moveTo(tip.x, tip.y)

    if (orientation === QtQuickModule.Item.Bottom) {
        ctx.lineTo(tip.x - wingWidth, tip.y - wingHeight)
        ctx.lineTo(tip.x + wingWidth, tip.y - wingHeight)
    } else if (orientation === QtQuickModule.Item.Top) {
        ctx.lineTo(tip.x - wingWidth, tip.y + wingHeight)
        ctx.lineTo(tip.x + wingWidth, tip.y + wingHeight)
    } else if (orientation === QtQuickModule.Item.Left) {
        ctx.lineTo(tip.x + wingHeight, tip.y - wingWidth)
        ctx.lineTo(tip.x + wingHeight, tip.y + wingWidth)
    } else if (orientation === QtQuickModule.Item.Right) {
        ctx.lineTo(tip.x - wingHeight, tip.y - wingWidth)
        ctx.lineTo(tip.x - wingHeight, tip.y + wingWidth)
    }

    ctx.lineTo(tip.x, tip.y)
    ctx.lineWidth = 1
    ctx.stroke()
    ctx.fill()

    //tail
    ctx.beginPath()
    if (orientation === QtQuickModule.Item.Bottom) {
        ctx.moveTo(tip.x, tip.y - wingHeight)
        ctx.lineTo(tip.x, tip.y - wingHeight - tailLength)
    } else if (orientation === QtQuickModule.Item.Top) {
        ctx.moveTo(tip.x, tip.y + wingHeight)
        ctx.lineTo(tip.x, tip.y + wingHeight + tailLength)
    } else if (orientation === QtQuickModule.Item.Left) {
        ctx.moveTo(tip.x + wingHeight, tip.y)
        ctx.lineTo(tip.x + wingHeight + tailLength, tip.y)
    } else if (orientation === QtQuickModule.Item.Right) {
        ctx.moveTo(tip.x - wingHeight, tip.y)
        ctx.lineTo(tip.x - wingHeight - tailLength, tip.y )
    }

    ctx.lineWidth = 2
    ctx.stroke()
}
