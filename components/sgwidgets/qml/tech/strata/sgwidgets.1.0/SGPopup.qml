/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Popup {
    id: popup

    /*one of: Item.Top, Item.Right, Item.Bottom, Item.Left, Item.Center*/
    property int position: Item.Top

    property Item originItem: parent

    padding: 2

    x: {
        /* this is to trigger calculation when positions changes */
        var calculatePositionAgain = originItem.x + originItem.width

        var deltaX = 0
        if (position === Item.Top || position === Item.Bottom || position === Item.Center) {
            deltaX = (originItem.width - popup.width) / 2
        } else if (position === Item.Left) {
            deltaX = -popup.width
        } else if (position === Item.Right) {
            deltaX = originItem.width
        }

        //adjust position to fit into window
        if (Overlay.overlay) {
            var globalPos = originItem.mapToItem(Overlay.overlay, deltaX, 0)
            if (globalPos.x < 0) {
                deltaX += -globalPos.x
            } else if (globalPos.x + popup.width > Overlay.overlay.width) {
                deltaX -= globalPos.x + popup.width - Overlay.overlay.width
            }
        }

        var pos = originItem.mapToItem(popup.parent, deltaX, 0)
        return  pos.x
    }

    y: {
        /* this is to trigger calculation when position changes */
        var calculatePositionAgain = originItem.y + originItem.height

        var deltaY = 0

        if (position === Item.Top) {
            deltaY = -popup.height
        } else if (position === Item.Bottom) {
            deltaY = originItem.height
        } else if (position === Item.Left || position === Item.Right || position === Item.Center) {
            deltaY = (originItem.height - popup.height) / 2
        }

        //adjust position to fit into window
        if (Overlay.overlay) {
            var globalPos = originItem.mapToItem(Overlay.overlay, 0, deltaY)
            if (globalPos.y < 0) {
                deltaY += -globalPos.y
            } else if (globalPos.y + popup.height > Overlay.overlay.height) {
                deltaY -= globalPos.y + popup.height - Overlay.overlay.height
            }
        }

        var pos = originItem.mapToItem(popup.parent, 0, deltaY)
        return  pos.y
    }

    Control {
        id: dummyControl
    }

    background: Item {
        RectangularGlow {
            id: effect
            anchors {
                fill: parent
                topMargin: position === Item.Bottom ? glowRadius - 2 : 0
                bottomMargin: position === Item.Top ? glowRadius - 2 : 0
                leftMargin: position === Item.Right ? glowRadius - 2 : 0
                rightMargin: position === Item.Left ? glowRadius - 2 : 0
            }
            glowRadius: 8
            color: dummyControl.palette.mid
        }

        Rectangle {
            anchors.fill: parent
            color: "white"
            border.color: dummyControl.palette.mid
            border.width: 1
        }
    }
}
