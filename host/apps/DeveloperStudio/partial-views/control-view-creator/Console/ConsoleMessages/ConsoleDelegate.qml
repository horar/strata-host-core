import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

RowLayout{
    id: row

    height: consoleItems.filterAcceptsRow(model.index) ? SGSettings.fontPixelSize * fontMultiplier : 0
    visible: consoleItems.filterAcceptsRow(model.index)
    spacing: 5

    Item {
        id: root
        Layout.fillWidth: true
        Layout.fillHeight: true

        ConsoleTime {
            id: consoleTime
            time: model.time
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
        }

        ConsoleTypes {
            id: consoleTypes
            type: model.type
            anchors.left: consoleTime.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
        }

        ConsoleMessage {
            id: consoleMessage
            msg: model.msg
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.leftMargin: 10
        }
    }
}
