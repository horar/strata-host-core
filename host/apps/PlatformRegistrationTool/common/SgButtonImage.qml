import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

Item {
    id: buttonImage

    property bool pressed: false
    property bool checked: false
    property int radius: 4
    property color color: dummyControl.palette.button

    /* These properties are useful for SgButtonRow */
    property bool hasLeftBorder: true
    property bool hasRightBorder: true
    property bool hasDelimeter: false

    clip: true

    Control {
        id: dummyControl
    }

    Rectangle {
        anchors.fill: parent
        anchors.bottomMargin: buttonImage.pressed ? 0 : -1
        color: "#10000000"
        radius: buttonImage.radius
    }

    Rectangle {
        id: base

        anchors {
            fill: parent
            leftMargin: hasLeftBorder ? 0 : -4
            rightMargin: hasRightBorder ? 0 : -4
        }

        property color baseColor: {
            if (buttonImage.checked) {
                return Qt.darker(buttonImage.color, 2.2)
            }

            return buttonImage.color
        }

        radius: buttonImage.radius
        border.width: 1
        border.color: "#999999"

        gradient: Gradient {
            id: gradient
            property color startColor: {
                if (buttonImage.pressed) {
                    return Qt.darker(base.baseColor, 1.32)
                } else {
                    return Qt.lighter(base.baseColor,1.13)
                }
            }
            property color endColor: {
                if (buttonImage.pressed) {
                    return Qt.darker(base.baseColor, 1.1)
                } else {
                    return base.baseColor
                }
            }

            GradientStop {
                position: 0.0
                color: gradient.startColor
            }
            GradientStop {
                position: buttonImage.pressed ? 0.1 : 1.0
                color: gradient.endColor
            }
        }
    }

    Rectangle {
        id: delimeter
        anchors {
            top: buttonImage.top
            bottom: buttonImage.bottom
            left: buttonImage.left
        }

        width: 1
        color: base.border.color
        visible: hasDelimeter
    }
}
