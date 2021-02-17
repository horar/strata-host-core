import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Popup {
    id: root

    property alias content: content.sourceComponent

    property bool showOn: false
    property bool arrowOnTop: false
    property string horizontalAlignment: "center"
    property real radius: 5
    property color color: "#00ccee"
    contentItem: content.item
    visible: false

    onShowOnChanged: {
        showOn ? showAnimation.start() : hideAnimation.start()
    }

    opacity: 0
    height: container.height
    width: container.width
    onOpened: {
        updateAlignment()
    }

    onHorizontalAlignmentChanged: updateAlignment()
    onArrowOnTopChanged: updateAlignment()

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

    Item {
        id: container
        implicitWidth: content.childrenRect.width + 20
        implicitHeight: content.childrenRect.height + 30  // 30 because 10 padding*2 and 10 for pointer

        Rectangle {
            id: colorRect
            color: root.color
            radius: 15
            height: container.height - 10
            width: container.width

            MouseArea {
                // Blocks clickthroughs
                anchors { fill: colorRect }
                hoverEnabled: true
                preventStealing: true
                propagateComposedEvents: false
            }

            Loader {
                id: content
                anchors {
                    centerIn: colorRect
                }
            }
        }

        Canvas {
            id: triangleArrow

            implicitWidth: 10
            implicitHeight: 10
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

    PropertyAnimation {
        id: showAnimation
        onStarted: root.visible = true
        target: root; properties: "opacity"; from: root.opacity; to: 1; duration: 200
    }

    PropertyAnimation {
        id: hideAnimation
        onStopped: root.visible = false
        target: root; properties: "opacity"; from: root.opacity; to: 0; duration: 100
    }

    DropShadow {
        anchors.fill: container
        horizontalOffset: 1.5
        verticalOffset: 1.5
        radius: 6.0
        samples: 13
        color: "#88000000"
        source: container
        visible: root.visible
        opacity: root.opacity
    }
}

