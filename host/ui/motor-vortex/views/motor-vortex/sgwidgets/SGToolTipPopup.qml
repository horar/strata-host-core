import QtQuick 2.9
import QtGraphicalEffects 1.0

Canvas {
    id: root

    property alias content: content.sourceComponent

    property bool showOn: false
    property real radius: 5
    property color color: "#00ccee"

    onShowOnChanged: {
        showOn ? showAnimation.start() : hideAnimation.start()
    }
    opacity: 0
    visible: false
    width: content.childrenRect.width + 20
    height: content.childrenRect.height + 30  // 30 because 10 padding*2 and 10 for pointer
    contextType: "2d"

    onPaint: {
        context.reset();
        context.beginPath();
//        context.shadowColor = "#000"  // Broken in qml 5.x according to https://qmlbook.github.io/ch07/index.html
//        context.shadowBlur = 3
        context.moveTo(radius, 0);
        context.lineTo(width - radius, 0);
        context.arcTo(width, 0, width, height - radius, radius);
        context.lineTo(width, height - 10 - radius);
        context.arcTo(width, height - 10, width - radius, height - 10, radius);
        context.lineTo(width / 2 + 5, height - 10);
        context.lineTo(width / 2 - 5, height);
        context.lineTo(width / 2 - 5, height - 10);
        context.lineTo(radius, height - 10);
        context.arcTo(0, height - 10, 0, height - 10 -radius, radius);
        context.lineTo(0, radius);
        context.arcTo(0, 0, radius, 0, radius);
        context.closePath();
        context.fillStyle = root.color;
        context.fill();
    }

    Loader {
        id: content
        anchors {
            centerIn: parent
            verticalCenterOffset: -5  // To compensate for pointer
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
}

