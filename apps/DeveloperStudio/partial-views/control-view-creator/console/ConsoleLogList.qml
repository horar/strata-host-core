/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.logger 1.0

import "console-messages"

ListView {
    id: consoleLogs
    anchors.fill: parent
    model: consoleItems
    clip: true
    spacing: 0

    property int indexDragStarted: -1
    property bool selecting: false
    property bool isActiveSelecting: false

    signal selectInBetween(int indexDragEnded)
    signal deselectAll()

    onDeselectAll: {
        for (var i = 0; i < consoleModel.count; i++) {
            consoleModel.get(i).state = "noneSelected"
        }
        contextMenu.copyEnabled = false
    }

    onSelectInBetween: {
        var start
        var end
        if (indexDragEnded > indexDragStarted) {
            start = indexDragStarted + 1
            end = indexDragEnded
        } else {
            start = indexDragEnded + 1
            end = indexDragStarted
        }

        for (var i = 0; i < consoleLogs.model.count; i++) {
            var listElement = consoleModel.get(consoleLogs.model.mapIndexToSource(i));
            if (listElement < 0) {
                console.error(Logger.devStudioCategory, "index out of range")
                return
            }
            if (i >= start && i < end) {
                listElement.state = "allSelected"
            } else if (i < start - 1 || i > end) {
                listElement.state = "noneSelected"
            }
        }
    }

    function logAdded() {
        // if user is at end of list +/- 10px, scroll to end of list to focus on new logs
        if (contentY >= (contentHeight - height) - 10){
            positionViewAtEnd()
        }
    }

    ScrollBar.vertical: ScrollBar {
        active: true
    }

    delegate: ConsoleDelegate {
        id: consoleDelegate
    }

    MouseArea {
        id: consoleMouseArea
        anchors.fill: consoleLogs
        drag.target: dragitem
        cursorShape: Qt.IBeamCursor
        propagateComposedEvents: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: {
            if (mouse.button === Qt.LeftButton) {
                consoleLogs.deselectAll()
                var clickedDelegate = consoleLogs.itemAt(mouse.x + consoleLogs.contentX, mouse.y + consoleLogs.contentY)
                if (clickedDelegate) {
                    clickedDelegate.startSelection(mouse)
                } else {
                    consoleLogs.indexDragStarted = consoleLogs.model.count
                }
                consoleLogs.forceActiveFocus()
            } else if (mouse.button === Qt.RightButton) {
                contextMenu.contextMenuEdit.popup(null)
            }
        }

        onDoubleClicked: {
            if (mouse.button === Qt.LeftButton) {
                consoleLogs.deselectAll()
                var clickedIndex = consoleLogs.indexAt(mouse.x + consoleLogs.contentX, mouse.y + consoleLogs.contentY)
                var sourceIndex = consoleItems.mapIndexToSource(clickedIndex)
                if (clickedIndex > -1 && sourceIndex > -1) {
                    contextMenu.copyEnabled = true
                    consoleModel.get(sourceIndex).state = "allSelected"
                }
            }
        }

        onPositionChanged: {
            // Scroll up or down to select more when user is close to edges of list
            if (consoleMouseArea.pressed) {
                if (mouse.y > consoleMouseArea.height * .95) {
                    consoleLogs.flick(0, -200)
                } else if (mouse.y < consoleMouseArea.height * .05 && consoleLogs.contentY > 0) {
                    consoleLogs.flick(0, 200)
                }
            }
        }
    }

    Item {
        id: dragitem
        x: consoleMouseArea.mouseX
        y: consoleMouseArea.mouseY
        width: 1
        height: 1
        Drag.active: consoleMouseArea.drag.active
        Component.onCompleted: dragitem.parent = consoleMouseArea
    }

    ContextMenu {
        id: contextMenu
    }
}
