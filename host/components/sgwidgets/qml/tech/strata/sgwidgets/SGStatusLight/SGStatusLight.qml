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

    Image {
        id: statusLight

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
            switch(root.status) {
                case "green":
                    "qrc:/sgimages/statusLightGreen.svg"
                    break;
                case "red":
                    "qrc:/sgimages/statusLightRed.svg"
                    break;
                case "yellow":
                    "qrc:/sgimages/statusLightYellow.svg"
                    break;
                case "orange":
                    "qrc:/sgimages/statusLightOrange.svg"
                    break;
                case "off":
                    "qrc:/sgimages/statusLightOff.svg"
                    break;
                default:
                    "qrc:/sgimages/statusLightOff.svg"
            }
        }
        mipmap: true
    }
}
