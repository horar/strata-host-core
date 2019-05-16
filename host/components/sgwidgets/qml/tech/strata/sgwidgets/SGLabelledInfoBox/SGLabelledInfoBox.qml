import QtQuick 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: root

    property alias overrideLabelWidth: labelText.width
    property alias label: labelText.text
    property alias labelPixelSize: labelText.font.pixelSize
    property bool labelLeft: true

    property alias info: infoText.text
    property alias textPixelSize: infoText.font.pixelSize
    property alias textColor: infoText.color
    property alias textPadding: infoText.padding

    property alias infoBoxWidth: infoContainer.width
    property alias infoBoxHeight: infoContainer.height
    property alias infoBoxColor: infoContainer.color
    property color infoBoxBorderColor: "#cccccc"
    property real infoBoxBorderWidth: 1

    implicitHeight: labelLeft ? infoContainer.height : labelText.height + infoContainer.height + infoContainer.anchors.topMargin
    implicitWidth: labelLeft ? infoBoxWidth + labelText.width + infoContainer.anchors.leftMargin : Math.max(infoBoxWidth, labelText.width)

    Text {
        id: labelText
        text: label
        width: contentWidth
        height: root.label === "" ? 0 : root.labelLeft ? infoContainer.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (infoContainer.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
    }

    Rectangle {
        id: infoContainer
        height: textPixelSize * 2.5
        width: 2 * height
        color: "#eeeeee"
        radius: 2
        border {
            color: root.infoBoxBorderColor
            width: root.infoBoxBorderWidth
        }
        anchors {
            left: root.labelLeft ? labelText.right : labelText.left
            top: root.labelLeft ? labelText.top : labelText.bottom
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }
        clip: true

        TextInput {
            id: infoText
            padding: font.pixelSize * 0.5
            anchors {
                right: infoContainer.right
                verticalCenter: infoContainer.verticalCenter
            }
            text: ""
            selectByMouse: true
            readOnly: true
            font {
              family: "Courier" // Monospaced font for better text width uniformity
            }
            color: "black"
        }
    }
}
