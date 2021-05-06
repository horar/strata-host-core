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
    //200
    property alias topWallY: topWall.y
    property real rectWidth: width
    property real rectHeight : height

    property int warningCount: 0
    property int errorCount: 0

    anchors.bottom: parent.bottom
    anchors.right: parent.right
    property var clickPos: "0,0"
    property var setResize: -(controlViewCreatorRoot.height - (consoleLog.height - clickPos.y) + 5)

    onSetResizeChanged: {
        console.log("height2",controlViewCreatorRoot.height, setResize, clickPos.y)
//        if(setResize < -(controlViewCreatorRoot.height - (consoleLog.height - clickPos.y))) {
//            setResize =  -(controlViewCreatorRoot.height - (consoleLog.height - clickPos.y))
//            console.log("height",controlViewCreatorRoot.height, setResize)
//        }
    }

    Rectangle {
        id: resizeRect
        width: rectWidth
        height: rectHeight
        anchors.bottom: parent.bottom
        anchors.top: topWall.bottom
        color: "#eee"

    }

    Rectangle {
        id: topWall
        x: 0
//        y: 0
        width: rectWidth + 5
        height: 4
        color: "red"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: topWall
        drag.target: topWall
        drag.minimumY: setResize
        drag.maximumY: 166
        drag.minimumX: 0
        drag.maximumX: 0
        cursorShape: Qt.SplitVCursor
        z:3


        onPressed: {
            clickPos  = Qt.point(mouse.x,mouse.y)
        }
        //        onYChanged: {
        //            if(y > setResize) {
        //              //  y = setResize
        //                console.info("y", y , controlViewCreatorRoot.y, setResize)
        //            }
        //        }

    }

    ConsoleContainer {
        anchors.fill: resizeRect
        onClicked: {
            viewConsoleLog.visible = false
        }
    }
}
