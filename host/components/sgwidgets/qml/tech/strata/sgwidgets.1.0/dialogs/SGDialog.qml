import QtQuick.Controls 2.12
import QtQuick 2.12
import QtGraphicalEffects 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Dialog {
    id: dialog

    property bool destroyOnClose: false
    property alias headerBgColor: headerBg.color
    property color bgColor: implicitBgColor
    property color implicitBgColor: "#eeeeee"
    property url headerIcon: ""
    property bool hasTitle: true

    x: parent ? Math.round((parent.width - width) / 2) : 0
    y: parent ? Math.round((parent.height - height) / 2) : 0

    Component.onCompleted: {
        SGWidgets.SGDialogJS.openedDialogs.push(dialog)
    }

    onClosed: {
        if (destroyOnClose) {
            SGWidgets.SGDialogJS.destroyComponent(dialog)
        }
    }

    header: Item {
        implicitHeight: hasTitle > 0 ? label.paintedHeight + 16 : 0
        implicitWidth: label.x + label.paintedWidth

        Rectangle {
            id: headerBg
            anchors.fill: parent
            color: Theme.palette.blue
        }

        SGWidgets.SGIcon {
            id: icon
            anchors {
                left: parent.left
                leftMargin: 5
                verticalCenter: parent.verticalCenter
            }

            source: headerIcon
            height: Math.floor(parent.height - 10)
            width: height
            iconColor: "white"
        }

        SGWidgets.SGText {
            id: label
            anchors {
                left: headerIcon && headerIcon.toString() ? icon.right : parent.left
                leftMargin: headerIcon ? 5 : 12
                verticalCenter: parent.verticalCenter
            }

            text: dialog.title
            fontSizeMultiplier: 1.5
            font.bold: true
            alternativeColorEnabled: true
        }
    }

    background: Item {
        RectangularGlow {
            id: effect
            anchors {
                fill: parent
            }

            glowRadius: 8
            cornerRadius: 4
            color: "black"
            opacity: 0.2
        }

        Rectangle {
            anchors.fill: parent
            color: bgColor
        }
    }
}
