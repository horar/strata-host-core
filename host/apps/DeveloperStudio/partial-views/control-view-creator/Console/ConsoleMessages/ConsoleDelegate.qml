import QtQuick 2.12
import QtQml 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

Item{
    id: root
    height: consoleMessage.height
    width: consoleLogs.width
    anchors.bottomMargin: 5
    property alias delegateText: consoleMessage.msgText
    state: model.state
    signal deselect()


    onDeselect: {
        console.log("hit")
        delegateText.deselect()
        dropArea.start = -1
    }

    function startSelection(mouse) {
        consoleLogs.indexDragStarted = index
        model.state = "someSelected"
        var composedY = -(consoleDelegate.y - mouse.y - consoleDelegate.ListView.view.contentY) - delegateText.y
        var composedX = -(consoleDelegate.x - mouse.x - consoleDelegate.ListView.view.contentX) - delegateText.x
        dropArea.start = delegateText.positionAt(composedX, composedY)
    }

    onStateChanged: {
        switch(state){
            case "noneSelected":
                deselect()
            break;
            case "someSelected":
                if (model.selectionStart !== delegateText.selectionStart || model.selectionEnd !== delegateText.selectionEnd) {
                    delegateText.select(model.selectionStart, model.selectionEnd);
                }
            break;
            case "allSelected": delegateText.selectAll()
            break;
        }
    }


    states: [
        State {
            name: "noneSelected"
        },
        State {
            name: "someSelected"
        },
        State {
            name: "allSelected"
        }

    ]

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
        selection: model.selection
        selectionStart: model.selectionStart
        selectionEnd: model.selectionEnd
    }

    DropArea {
        id: dropArea
        anchors {
            fill: parent
        }
        property int start:-1
        property int end:-1

        onEntered: {
            if (index > consoleLogs.indexDragStarted) {
                start = 0
            } else if (index < consoleLogs.indexDragStarted){
                start = delegateText.length
            }

            root.state = "someSelected"
            consoleLogs.selectInBetween(index)
        }

        onPositionChanged: {
            end = delegateText.positionAt(drag.x - (consoleTime.width + consoleTypes.width + 20), drag.y)

            delegateText.select(start, end)
        }
    }
}

