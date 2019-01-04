import QtQuick 2.9

AnimatedImage {
    id: root
    property bool pluggedIn: false
    source: "../images/USBCAnim.gif"
    height: 81 * ratioCalc
    width: 319 * ratioCalc
    playing: false
    onCurrentFrameChanged: {
        if (currentFrame === frameCount-1) {
            playing = false
        }
    }

    Image {
        source: "../images/cordTermination.png"
        height: 19 * ratioCalc
        width: height
        anchors {
            right: root.right
            verticalCenter: root.verticalCenter
            verticalCenterOffset: 17 * ratioCalc
        }
    }

//    MouseArea {
//        id: gifdebug
//        anchors {
//            fill: parent
//        }
//        onClicked: {
//            if (!pluggedIn) {
//                source = "../images/USBCAnim.gif"
//                currentFrame = 0
//                playing = true
//                pluggedIn = !pluggedIn
//            } else {
//                source = "../images/USBCAnimReverse.gif"
//                currentFrame = 0
//                playing = true
//                pluggedIn = !pluggedIn
//            }
//        }
//    }
}
