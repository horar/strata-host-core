import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ListView {
    id: root
    implicitWidth: contentItem.childrenRect.width
    implicitHeight: contentItem.childrenRect.height
    model: ["Option 1", "Option 2", "Option 3"]
    interactive: false

    property alias model: root.model
    property alias exclusive: buttonGroup.exclusive

    property color textColor: "#000000"
    property color radioColor: "#000000"
    property color highlightColor: "transparent"
    property color backgroundColor: "#ffffff"

    delegate: RadioDelegate {
        id: radioDelegate
        text: model.name
        checked: model.checked
        enabled: !model.disabled
        ButtonGroup.group: buttonGroup

        contentItem: Text {
            anchors.left: radioDelegate.indicator.right
            leftPadding: radioDelegate.spacing
            rightPadding: radioDelegate.spacing *2
            text: radioDelegate.text
            font: radioDelegate.font
            opacity: enabled ? 1.0 : 0.3
            color: root.textColor
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        indicator: Rectangle {
            implicitWidth: 26
            implicitHeight: 26
            x: radioDelegate.spacing
            y: parent.height / 2 - height / 2
            radius: 13
            color: "transparent"
            opacity: enabled ? 1.0 : 0.3
            border.color: radioDelegate.down ? radioColor : radioColor

            Rectangle {
                width: 14
                height: 14
                x: 6
                y: 6
                radius: 7
                opacity: enabled ? 1.0 : 0.3
                color: radioDelegate.down ? radioColor : radioColor
                visible: radioDelegate.checked
            }
        }

        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 40
            visible: radioDelegate.down || radioDelegate.highlighted
            color: highlightColor
        }
    }

    ButtonGroup {
        id: buttonGroup
    }

    Rectangle {  // Background for whole item
        z: -1
        anchors {
            fill: parent
        }
        color: root.backgroundColor
    }
}
