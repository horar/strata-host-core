import QtQuick 2.7
import QtQuick.Controls 2.0

Item {
     id: container

     property alias icon: iconImage.source
     property alias text: statisticText.text

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

    Label {
        id: statisticText
        width:container.width; height: container.height
        anchors{ left:iconImage.right; leftMargin: 10; verticalCenter: iconImage.verticalCenter; verticalCenterOffset:2}
        font.pointSize: Qt.platform.os === "osx" ? width/1.5 +1: Label.Fit
    }


}


