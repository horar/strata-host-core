import QtQuick 2.9
import QtQuick.Controls 2.0

//Switch {
//    id: root
//    text: qsTr("Switch")
//    padding: 0

//    property color textColor: "black"
//    property bool vertical: false

//    indicator: Rectangle {
//        rotation: vertical ? -90 : 0
//        id: groove
//        implicitWidth: 48
//        implicitHeight: 26
//        x: root.leftPadding
//        y: parent.height / 2 - height / 2
//        radius: 13
//        color: handle.x === width - handle.width ? "#17a81a" : "#ffffff"
//        border.color: handle.x === width - handle.width ? "#17a81a" : "#cccccc"

//        Rectangle {
//            id: handle
//            x: root.checked ? parent.width - width : 0
//            width: 26
//            height: 26
//            radius: 13
//            color: root.down ? "#cccccc" : "#ffffff"
//            border.color: handle.x !== width - handle.width ? (root.down ? "#17a81a" : "#21be2b") : "#999999"

//            Behavior on x { NumberAnimation { duration: 50 } }
//        }
//    }

//    contentItem: Text {
//        text: root.text
//        font: root.font
//        opacity: enabled ? 1.0 : 0.3
//        color: root.textColor
//        verticalAlignment: Text.AlignVCenter
//        leftPadding: root.indicator.width + root.spacing
//    }
//}

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
        color: "#bdbebf"

        Rectangle {
            width: ((root.visualPosition * parent.width) + (1-root.visualPosition) * handle.width) - 0.01 * parent.width
            height: parent.height
            color: "#21be2b"
            radius: height/2
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        color: root.pressed ? "#f0f0f0" : "#f6f6f6"
        border.color: "#bdbebf"
    }
}
