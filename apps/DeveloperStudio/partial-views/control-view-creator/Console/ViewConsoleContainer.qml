import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import QtQml 2.0


import "../components"
import "../Console"

Item {
    id: consoleLog

    property real rectHeight : 200

    anchors.bottom: parent.bottom
    anchors.right: parent.right

    property alias consoleLogParent: resizeRect

    Rectangle {
        id: resizeRect
        width: parent.width
        anchors.bottom: parent.bottom
        color: "#eee"
        height: Math.min(parent.height, rectHeight)
    }

    Item {
        id: topWall
        x: 0
        width: parent.width + 5
        height: 4
        z:3

        Binding {
            target: topWall
            property: "y"
            value: consoleLog.height - resizeRect.height - topWall.height
            when: mouseArea.drag.active === false

        }
        onYChanged: {
            if(mouseArea.drag.active) {
                rectHeight = parent.height - y
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: topWall
        drag.target: topWall
        drag.minimumY: 0
        drag.maximumY: (parent.height - 30)
        drag.minimumX: 0
        drag.maximumX: 0
        cursorShape: Qt.SplitVCursor
    }
}
