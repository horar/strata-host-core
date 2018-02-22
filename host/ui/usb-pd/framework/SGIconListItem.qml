import QtQuick 2.7
import QtQuick.Controls 2.0
import QtGraphicalEffects 1.0

Item {
    id: container

    property alias icon: iconImage.source
    property alias text: statisticText.text

    Image {
        id:iconImage
        width: container.width; height: container.height
        mipmap: true
    }

    DropShadow {
        anchors.fill: iconImage
        horizontalOffset: 1
        verticalOffset: 3
        radius: 6.0
        samples: 12
        color: "#60000000"
        source: iconImage
    }

    ScaleAnimator {
        id: increaseOnMouseEnter
        target: iconImage;
        from: 1;
        to: 1.2;
        duration: 200
        running: false
    }

    ScaleAnimator {
        id: decreaseOnMouseExit
        target: iconImage;
        from: 1.2;
        to: 1;
        duration: 200
        running: false
    }

    MouseArea {
        id: imageMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered:{
            increaseOnMouseEnter.start()
        }
        onExited:{
            decreaseOnMouseExit.start()
        }
    }

    Label {
        id: statisticText
        width:container.width; height: container.height
        anchors{ left:iconImage.right; leftMargin: 10; verticalCenter: iconImage.verticalCenter; verticalCenterOffset:2}
        font.pointSize: Qt.platform.os === "osx" ? width/1.75 +1: parent.width/1.6
        color:(inAdvancedMode) ? "#D8D8D8":"black"
    }
}


