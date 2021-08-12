import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import "qrc:/js/help_layout_manager.js" as Help

Popup {
    id: root
    closePolicy: Popup.NoAutoClose
    z: 100

    property bool arrowOnTop: false
    property string horizontalAlignment: "center"
    property real radius: 5
    property color color: "#00ccee"

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
        }

        DropShadow {
            anchors.fill: colorRect
            horizontalOffset: 1.5
            verticalOffset: 1.5
            radius: 6.0
            samples: 13
            color: "#88000000"
            source: colorRect
            visible: root.visible
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
