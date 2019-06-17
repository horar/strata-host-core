import QtQuick.Controls 2.12
import QtQuick 2.12
import QtGraphicalEffects 1.12

import "./Colors.js" as Colors

Dialog {
    id: dialog

    property bool destroyOnClose: false
    property alias headerBgColor: headerBg.color
    property color bgColor: implicitBgColor
    property color implicitBgColor: "#eeeeee"
    property url headerIcon: ""
    property bool hasTitle: true

    header: Item {
        implicitHeight: hasTitle > 0 ? label.paintedHeight + 16 : 0

        Rectangle {
            id: headerBg
            anchors.fill: parent
            color: Colors.STRATA_BLUE
        }

        SgIcon {
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

        SgText {
            id: label
            anchors {
                left: headerIcon ? icon.right : parent.left
                leftMargin: headerIcon ? 5 : 12
                verticalCenter: parent.verticalCenter
            }

            text: dialog.title
            fontSizeMultiplier: 1.5
            font.bold: true
            hasAlternativeColor: true
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

    onClosed: {
        if (destroyOnClose) {
            dialog.destroy()
        }
    }
}
