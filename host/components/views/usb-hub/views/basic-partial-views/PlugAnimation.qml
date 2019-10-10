import QtQuick 2.9
import "qrc:/views/usb-pd-multiport/views/basic-partial-views"

AnimatedImage {
    id: root
    property bool pluggedIn: false
    source: "../images/cord.gif"
//    width: 81 * ratioCalc
//    height: 350 * ratioCalc
    width: 50
    height:200
    playing: false
    onCurrentFrameChanged: {
        if (currentFrame === frameCount-1) {
            playing = false
        }
    }

//    Rectangle {
//        id: coverup1
//        width: 8 * ratioCalc
//        height: 50 * ratioCalc
//        color: "#bab9bc"
//        anchors {
//            left: root.left
//            leftMargin: 10 * ratioCalc
//            bottom: root.bottom
//            bottomMargin: 0
//        }

//        Rectangle {
//            color: "black"
//            opacity: .3
//            width: 2 * ratioCalc
//            height: 23 * ratioCalc
//            anchors {
//                left: coverup1.right
//                verticalCenter: coverup1.verticalCenter
//                verticalCenterOffset: 2
//            }
//        }

//        Rectangle {
//            id: coverup2
//            width: 9 * ratioCalc
//            height: 50 * ratioCalc
//            color: "#d1d1d4"
//            anchors {
//                right: coverup1.left
//                verticalCenter: coverup1.verticalCenter
//            }
//        }
//    }
}
