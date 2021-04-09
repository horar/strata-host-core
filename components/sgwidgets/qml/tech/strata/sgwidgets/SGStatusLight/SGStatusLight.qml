import QtQuick 2.12
import QtGraphicalEffects 1.12


Item {
    id: root

    property string status: "off"
    property string label: ""
    property bool labelLeft: true
    property real lightSize : 50
    property alias overrideLabelWidth: labelText.width
    property color textColor : "black"

    implicitHeight: labelLeft ? Math.max(labelText.height, lightSize) : labelText.height + lightSize + statusLight.anchors.topMargin
    implicitWidth: labelLeft ? labelText.width + lightSize + statusLight.anchors.leftMargin : Math.max(labelText.width, lightSize)

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.label === "" ? 0 : root.labelLeft ? statusLight.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (statusLight.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
    }

    Rectangle {
        id: lightColorLayer
        anchors.centerIn: statusLight
        width: Math.min(statusLight.width, statusLight.height) * 0.8
        height: width
        radius: width/2
        color: {
            switch (root.status) {
            case "yellow": return "yellow"
            case "green": return "limegreen"
            case "orange": return "orange"
            case "red": return "red"
            default: return "grey"
            }
        }
    }

    Image {
        id: statusLight
        mipmap: true
        anchors {
            left: root.labelLeft ? labelText.right : labelText.width > root.lightSize ? undefined : labelText.left
            horizontalCenter: root.labelLeft ? undefined : labelText.width > root.lightSize ? labelText.horizontalCenter : undefined
            top: root.labelLeft ? labelText.top : labelText.bottom
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }
        width: root.lightSize
        height: root.lightSize

        source: {
            switch (root.status) {
            case "off": return "qrc:/sgimages/status-light-off.svg"
            default: return "qrc:/sgimages/status-light-transparent.svg"
            }
        }
    }
}
