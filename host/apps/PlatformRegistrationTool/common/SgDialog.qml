import QtQuick.Controls 2.12
import QtQuick 2.12

import "./Colors.js" as Colors

Dialog {
    id: dialog

    property bool destroyOnClose: false
    property alias headerBgColor: headerBg.color
    property alias bgColor: bg.color
    property color implicitBgColor: "#eeeeee"
    property url headerIcon: ""

    header: Item {
        implicitHeight: label.paintedHeight + 16

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
            sourceSize.height: Math.floor(parent.height - 10)
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

    background: Rectangle {
        id: bg
        color: implicitBgColor
    }

    onClosed: {
        if (destroyOnClose) {
            dialog.destroy()
        }
    }
}
