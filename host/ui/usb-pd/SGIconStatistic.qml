import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
     id: container
     color: "transparent"
     width:container.width; height: container.height
     property alias source: iconImage.source

    Image {
        id:iconImage
        width: container.width; height: container.height
        mipmap: true
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
            from: 1.2;//onLogo.scale;
            to: 1;
            duration: 200
            running: false
        }

    MouseArea {
            id: imageMouse
            anchors.fill: parent
            hoverEnabled: true
            onEntered:{
                increaseOnMouseEnter.start()
            }
            onExited:{
                decreaseOnMouseExit.start()
            }
        }
}


