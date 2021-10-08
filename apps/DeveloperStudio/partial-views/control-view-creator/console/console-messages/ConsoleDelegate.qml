/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
    id: consoleDelegate
    height: consoleMessage.height
    width: consoleLogs.width

    Component.onCompleted: {
        state = Qt.binding(function() { return model.state })
    }

    function startSelection(mouse) {
        consoleLogs.indexDragStarted = index
        model.state = "someSelected"
        var composedY = -(consoleDelegate.y - mouse.y - consoleDelegate.ListView.view.contentY) - consoleMessage.y
        var composedX = mouse.x - consoleMessage.x
        dropArea.start = consoleMessage.positionAt(composedX, composedY)
    }

    states: [
        State {
            name: "noneSelected"
            StateChangeScript {
                script: {
                    consoleMessage.deselect()
                    dropArea.start = -1
                }
            }
        },
        State {
            name: "someSelected"
            StateChangeScript {
                script: {
                    if (model.selectionStart !== consoleMessage.selectionStart || model.selectionEnd !== consoleMessage.selectionEnd) {
                        consoleMessage.select(model.selectionStart, model.selectionEnd);
                    }
                }
            }
        },
        State {
            name: "allSelected"
            StateChangeScript {
                script: consoleMessage.selectAll()
            }
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
        text: model.msg
        anchors.top: parent.top
        anchors.left: consoleTypes.right
        anchors.right: parent.right
        anchors.leftMargin: 10
        current: model.current
    }

    DropArea {
        id: dropArea
        anchors {
            fill: consoleMessage
        }
        property int start:-1
        property int end:-1

        onEntered: {
            if (index > consoleLogs.indexDragStarted) {
                start = 0
            } else if (index < consoleLogs.indexDragStarted){
                start = consoleMessage.length
            }

            model.state = "someSelected"
            contextMenu.copyEnabled = true
            consoleLogs.selectInBetween(index)
        }

        onPositionChanged: {
            end = consoleMessage.positionAt(drag.x, drag.y)
            consoleMessage.select(start, end)
        }
    }

    Connections {
        target: consoleLogs
        onSelectInBetween:{
            // covers case where drag hasn't triggered before leaving first delegate
            if (index === consoleLogs.indexDragStarted) {
                if (indexDragEnded > consoleLogs.indexDragStarted) {
                    dropArea.end = consoleMessage.length
                    consoleMessage.select(dropArea.start, dropArea.end)
                } else if (indexDragEnded < consoleLogs.indexDragStarted) {
                    dropArea.end = 0
                    consoleMessage.select(dropArea.start, dropArea.end)
                }
            }
        }
    }
}

