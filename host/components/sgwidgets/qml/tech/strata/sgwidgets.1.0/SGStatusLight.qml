import QtQuick 2.12

/*
There is a bug in Qt related to enums and qualifiers - QTBUG-76531
As a result, we cannot use qualifier when using enums.
*/
import tech.strata.sgwidgets 1.0

Item {
    id: root
    implicitWidth: 50
    implicitHeight: width
    layer.enabled: true

    property int status: 6
    property color customColor: "white"
    property bool flatStyle: false

    enum IconStatus {
        Blue,
        Green,
        Red,
        Yellow,
        Orange,
        CustomColor,
        Off
    }

    Rectangle {
        id: lightColorLayer
        anchors.centerIn: statusLight
        width: Math.min(statusLight.width, statusLight.height) * (root.flatStyle ? 0.6 : 0.8)
        height: width
        radius: width/2
        color: {
            switch (root.status) {
            case SGStatusLight.Yellow: return "yellow"
            case SGStatusLight.Green: return "limegreen"
            case SGStatusLight.Blue: return "deepskyblue"
            case SGStatusLight.Orange: return "orange"
            case SGStatusLight.Red: return "red"
            case SGStatusLight.CustomColor: return customColor
            default: return "transparent" // case SGStatusLight.Off
            }
        }
    }

    Rectangle {
        id: flatStyleBorder
        width: Math.min(statusLight.width, statusLight.height)
        height: width
        radius: width/2
        color: "transparent"
        border.color: "grey"
        border.width: .06 * width
        visible: root.flatStyle
    }

    Image {
        id: statusLight
        fillMode: Image.PreserveAspectFit
        mipmap: true
        height: root.height
        width: root.width
        visible: !root.flatStyle

        source: {
            switch (root.status) {
            case SGStatusLight.Off: return "qrc:/sgimages/status-light-off.svg"
            default: return "qrc:/sgimages/status-light-transparent.svg"
            }
        }
    }
}
