import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

import "../components"
import "../Console"

Item {
    id: consoleLog

    property real rectWidth: width
    property real rectHeight : height

    property int warningCount: 0
    property int errorCount: 0

    anchors.bottom: parent.bottom
    anchors.right: parent.right

    Rectangle {
        id: resizeRect
        width: rectWidth
        height: rectHeight
        anchors.bottom: parent.bottom
        anchors.top: topWall.bottom
        color: "#eee"
    }

    Item {
        id: topWall
        x: 0
        y: 0
        width: rectWidth + 5
        height: 4
    }

    MouseArea {
        anchors.fill: topWall
        drag.target: topWall
        drag.minimumY: 0 - (controlViewCreatorRoot.height - (consoleLog.height + clickPos.y) + 5)
        drag.maximumY: 166
        drag.minimumX: 0
        drag.maximumX: 0
        cursorShape: Qt.SplitVCursor
        property var clickPos: "0,0"
        z:3
        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }
        onPositionChanged: {
            console.log("x",x)
        }
    }

    ConsoleContainer {
        anchors.fill: resizeRect
        onClicked: {
            viewConsoleLog.visible = false
        }
    }
}
