import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Image {
        id: onLogo
        x: 262
        y: 183
        width: 100
        height: 100
        source: "OnLogo.png"

        ScaleAnimator {
                id: increaseOnLogoSize
                target: onLogo;
                from: 1;//onLogo.scale;
                to: 1.2;
                duration: 500
                running: false
            }

        ScaleAnimator {
                id: decreaseOnLogoSize
                target: onLogo;
                from: 1.2;//onLogo.scale;
                to: 1;
                duration: 500
                running: false
            }

        MouseArea {
                id: buttonMouse
                anchors.fill: parent
                hoverEnabled: true
                onEntered:{
                    increaseOnLogoSize.start()
                }
                onExited:{
                    decreaseOnLogoSize.start()
                }
            }
    }


}
