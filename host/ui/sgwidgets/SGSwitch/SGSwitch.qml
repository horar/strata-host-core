import QtQuick 2.9
import QtQuick.Controls 2.0

Slider {
    id: root
    value: 0
    // SnapOnRelease bug in 5.10/5.11 that forces Slider.SnapAlways if a stepsize is set,
    // SnapOnRelease is simulated by onPressedChanged which should be removed if this ever works later.
//    snapMode: Slider.SnapOnRelease
//    stepSize: 1

    onPressedChanged: {
        if (!pressed){
            value > .5 ? value = 1: value = 0;
        }
    }

    Behavior on value { NumberAnimation { duration: 100 } }

    from: 0
    to: 1
    padding: 0

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 52
        implicitHeight: 26
        width: root.availableWidth
        height: implicitHeight
        radius: height/2
        color: "#bdbdbd"

        Text {
            id: offText
            color: "white"
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 5
            }
            font.pixelSize: 10
            text: qsTr("Off")
        }

        Rectangle {
            width: ((root.visualPosition * parent.width) + (1-root.visualPosition) * handle.width) - 0.01 * parent.width
            height: parent.height
            color: "#0cf"
            radius: height/2

            Text {
                id: onText
                color: "white"
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 5
                }
                font.pixelSize: 10
                text: qsTr("On")
            }
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        color: root.pressed ? "#f0f0f0" : "#f6f6f6"
        border.color: "#bdbdbd"
    }
}
