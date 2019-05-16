import QtQuick 2.12
import QtQuick.Controls 2.12

RadioButton {
    id: root

    property color textColor: masterTextColor
    property color radioColor: masterRadioColor

    text: "Radio Button"
    implicitWidth: buttonText.implicitWidth + buttonText.anchors.leftMargin + indicator.width
    implicitHeight: Math.max(root.indicator.height, buttonText.height)

    contentItem: buttonText

    Text {
        id: buttonText
        anchors {
            left: root.indicator.right
            leftMargin: 10
        }
        text: root.text
        opacity: enabled ? 1.0 : 0.3
        color: root.textColor
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    indicator: Rectangle {
        id: outerRadio
        implicitWidth: radioButtonSize
        implicitHeight: implicitWidth
//        y: root.height / 2 - height / 2
        radius: width/2
        color: "transparent"
        opacity: enabled ? 1.0 : 0.3
        border.width: 1
        border.color: radioColor

        Rectangle {
            id: innerRadio
            implicitWidth: outerRadio.width * 0.6
            implicitHeight: implicitWidth
            anchors {
                horizontalCenter: outerRadio.horizontalCenter
                verticalCenter: outerRadio.verticalCenter
            }
            radius: width / 2
            opacity: enabled ? 1.0 : 0.3
            color: radioColor
            visible: root.checked
        }
    }
}

