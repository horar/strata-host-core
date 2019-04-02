import QtQuick.Controls 2.12
import QtQuick 2.12

import "./Colors.js" as Colors

Dialog {
    id: dialog

    header: Item {
        implicitHeight: label.paintedHeight + 16

        Rectangle {
            anchors.fill: parent
            color: Colors.STRATA_BLUE
        }

        SgText {
            id: label
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }

            text: dialog.title
            fontSizeMultiplier: 1.2
            hasAlternativeColor: true
        }
    }

    background: Rectangle {
        color: "#eeeeee"
    }
}
