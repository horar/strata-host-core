/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.theme 1.0

Popup {
    id: root
    closePolicy: Popup.NoAutoClose
    z: 100

    property bool arrowOnTop: false
    property string horizontalAlignment: "center"
    property real radius: 5
    property color color: Theme.palette.onsemiLightBlue

    function updateAlignment (){
        triangleArrow.anchors.left = undefined
        triangleArrow.anchors.right = undefined
        triangleArrow.anchors.bottom = undefined
        triangleArrow.anchors.top = undefined
        triangleArrow.anchors.horizontalCenter = undefined

        colorRect.anchors.bottom = undefined
        colorRect.anchors.top = undefined

        if (arrowOnTop) {
            colorRect.anchors.bottom = container.bottom
            triangleArrow.anchors.bottom = colorRect.top
            triangleArrow.rotation = 0
        } else {
            colorRect.anchors.top = container.top
            triangleArrow.anchors.top = colorRect.bottom
            triangleArrow.rotation = 180
        }

        switch (horizontalAlignment) {
        case "left":
            triangleArrow.anchors.left = container.left
            triangleArrow.anchors.leftMargin = 15
            triangleArrow.rotation -= arrowOnTop ? 0 : 90
            break;
        case "right":
            triangleArrow.anchors.right = container.right
            triangleArrow.anchors.rightMargin = 15
            triangleArrow.rotation -= arrowOnTop ? 90 : 0
            break;
        default:
            triangleArrow.anchors.horizontalCenter = container.horizontalCenter
        }
    }

    Component.onCompleted: {
        updateAlignment()
    }

    onVisibleChanged: {
        updateAlignment()
    }

    onHorizontalAlignmentChanged: updateAlignment()
    onArrowOnTopChanged: updateAlignment()

    background:  Item {
        id: container

        Rectangle {
            id: colorRect
            color: root.color
            radius: 15
            anchors.fill: parent
            layer.enabled: true
            layer.effect:  DropShadow {
                horizontalOffset: 1.5
                verticalOffset: 1.5
                samples: 13
                color: "#88000000"
            }
        }

        MouseArea {
            // Blocks clickthroughs
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
        }

        Canvas {
            id: triangleArrow
            width: 10
            height: 10
            contextType: "2d"

            onPaint: {
                var context = getContext("2d")
                context.reset();
                context.beginPath();
                context.moveTo(0, 10);
                context.lineTo(0, 0);
                context.lineTo(10, 10);
                context.lineTo(0, 10);
                context.closePath();
                context.fillStyle = root.color;
                context.fill();
            }
        }
    }
}
