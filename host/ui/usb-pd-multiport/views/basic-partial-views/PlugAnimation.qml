import QtQuick 2.9
import "qrc:/views/images"
import "qrc:/views/basic-partial-views"

AnimatedImage {
    id: root
    property bool pluggedIn: false
    source: "qrc:/views/images/cord.gif"
    height: 81 * ratioCalc
    width: 350 * ratioCalc
    playing: false
    onCurrentFrameChanged: {
        if (currentFrame === frameCount-1) {
            playing = false
        }
    }

    Rectangle {
        id: coverup1
        width: 8 * ratioCalc
        height: 50 * ratioCalc
        color: "#bab9bc"
        anchors {
            left: root.left
            leftMargin: 10 * ratioCalc
            bottom: root.bottom
            bottomMargin: 0
        }

        Rectangle {
            color: "black"
            opacity: .3
            width: 2 * ratioCalc
            height: 23 * ratioCalc
            anchors {
                left: parent.right
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 2
            }
        }

        Rectangle {
            id: coverup2
            width: 9 * ratioCalc
            height: 50 * ratioCalc
            color: "#d1d1d4"
            anchors {
                right: parent.left
                verticalCenter: parent.verticalCenter
            }
        }
    }
}
