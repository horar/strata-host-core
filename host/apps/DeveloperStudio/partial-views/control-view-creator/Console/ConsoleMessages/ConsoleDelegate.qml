import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item{
    id: root
    height: consoleMessage.height
    width: consoleLogs.width
    anchors.bottomMargin: 5

    ConsoleTime {
        id: consoleTime
        time: model.time
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 5
        current: model.current
    }

    ConsoleTypes {
        id: consoleTypes
        type: model.type
        anchors.left: consoleTime.right
        anchors.top: parent.top
        anchors.leftMargin: 5
        current: model.current
    }

    ConsoleMessage {
        id: consoleMessage
        msg: model.msg
        anchors.top: parent.top
        anchors.left: consoleTypes.right
        anchors.right: parent.right
        anchors.leftMargin: 10
        current: model.current
    }
}

