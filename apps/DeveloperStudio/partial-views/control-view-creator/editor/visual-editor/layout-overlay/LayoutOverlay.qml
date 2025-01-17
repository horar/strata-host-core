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
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sglayout 1.0
import tech.strata.theme 1.0

// "layout mode" overlay that appears on top of handled objects

LayoutContainer {
    id: layoutOverlayRoot
    visible: layoutDebugMode

    property string type: ""
    property var sourceItem // Item that this overlay represents

    // multi-item selection/dragging/resizing
    property bool isSelected: false
    property real multiItemTargetPrevX
    property real multiItemTargetPrevY
    property real multiItemTargetPrevWidth
    property real multiItemTargetPrevHeight
    property var multiItemTargetRectLimits: []

    onSourceItemChanged: {
        if (layoutOverlayRoot.sourceItem && visualEditor.functions.isUuidSelected(layoutOverlayRoot.sourceItem.layoutInfo.uuid)) {
            layoutOverlayRoot.isSelected = true
        }
    }

    Connections {
        target: visualEditor
        enabled: layoutOverlayRoot.isSelected

        onMultiObjectsDeselectAll: {
            layoutOverlayRoot.isSelected = false
        }

        onMultiObjectsDragged: {
            if (objectInitiated != layoutOverlayRoot.objectName) {
                rect.color = Theme.palette.error
                rect.x += x
                rect.y += y
            }
        }

        onMultiObjectsResizeDragged: {
            if (objectInitiated != layoutOverlayRoot.objectName) {
                rect.color = Theme.palette.error
                rect.width += width
                rect.height += height
            }
        }
    }

    contentItem: Item {
        MouseArea {
            id: dragMouseArea
            width: parent.width
            height: parent.height
            drag.target: this // determines which object will be moved in a drag
            Drag.active: drag.active
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true

            property point startPoint

            // multi-item selection/dragging/resizing
            property real dragRectLeftLimit
            property real dragRectRightLimit
            property real dragRectTopLimit
            property real dragRectBottomLimit

            onWheel: {
                wheel.accepted = true // do not propagate wheel events to objects below overlay (e.g. sggraph zoom)
            }

            onPressed: {
                startPoint = Qt.point(mouseX, mouseY)

                if ((mouse.modifiers & Qt.ShiftModifier) == false && layoutOverlayRoot.isSelected === false) {
                    visualEditor.multiObjectsDeselectAll()
                    layoutOverlayRoot.isSelected = true
                    visualEditor.functions.addUuidToMultiObjectSelection(layoutOverlayRoot.sourceItem.layoutInfo.uuid)
                } else if (visualEditor.selectedMultiObjectsUuid.length > 1) {
                    layoutOverlayRoot.multiItemTargetPrevX = rect.x
                    layoutOverlayRoot.multiItemTargetPrevY = rect.y

                    multiItemTargetRectLimits = visualEditor.functions.getMultiItemTargetRectLimits()
                    dragRectLeftLimit = multiItemTargetRectLimits[0] * overlayContainer.columnSize
                    dragRectRightLimit = multiItemTargetRectLimits[1] * overlayContainer.columnSize
                    dragRectTopLimit = multiItemTargetRectLimits[2] * overlayContainer.rowSize
                    dragRectBottomLimit = multiItemTargetRectLimits[3] * overlayContainer.rowSize
                }
            }

            onClicked: {
                if (mouse.button == Qt.RightButton) {
                    contextLoader.active = true
                    contextLoader.item.popup()
                } else if (mouse.button == Qt.LeftButton && mouse.modifiers & Qt.ShiftModifier) {
                    if (layoutOverlayRoot.isSelected) {
                        layoutOverlayRoot.isSelected = false
                        visualEditor.functions.removeUuidFromMultiObjectSelection(layoutOverlayRoot.sourceItem.layoutInfo.uuid)
                    } else {
                        layoutOverlayRoot.isSelected = true
                        visualEditor.functions.addUuidToMultiObjectSelection(layoutOverlayRoot.sourceItem.layoutInfo.uuid)
                    }
                }
            }

            onReleased: {
                // todo: this runs if off by >=1 pixel, should only run if a different row/column is achieved
                // todo: invalid placement can be achieved outside layout

                // if moved, edit file
                const position = dragMouseArea.mapToItem(layoutOverlayRoot, x, y)
                if (position.x !== 0 || position.y !== 0) {
                    const newPosition = layoutOverlayRoot.mapToItem(overlayContainer, rect.x, rect.y)
                    const colRow = Qt.point(Math.round(newPosition.x / overlayContainer.columnSize), Math.round(newPosition.y / overlayContainer.rowSize))

                    if (layoutOverlayRoot.isSelected && visualEditor.selectedMultiObjectsUuid.length > 1) {
                        const xOffset = colRow.x - layoutOverlayRoot.layoutInfo.xColumns
                        const yOffset = colRow.y - layoutOverlayRoot.layoutInfo.yRows
                        if (xOffset !== 0 || yOffset !== 0) {
                            visualEditor.functions.moveGroup(xOffset, yOffset)
                            console.log("Moved selected " + visualEditor.selectedMultiObjectsUuid.length + " items by (" + xOffset + "," + yOffset + ")")
                        } else {
                            visualEditor.functions.unload(true)
                        }
                    } else {
                        visualEditor.functions.moveItem(layoutOverlayRoot.layoutInfo.uuid, colRow.x, colRow.y)
                        console.log("Moved:", layoutOverlayRoot.objectName)
                    }
                }
            }

            onPositionChanged: {
                if (pressed) {
                    // determine mouse pointer position within mouseArea and how it relates to the overlayContainer, converted to row/column API
                    let newPoint = dragMouseArea.mapToItem(overlayContainer, mouse.x - startPoint.x, mouse.y - startPoint.y)
                    let newX = Math.round(newPoint.x / overlayContainer.columnSize) * overlayContainer.columnSize
                    let newY = Math.round(newPoint.y / overlayContainer.rowSize) * overlayContainer.rowSize

                    // constrain positional movement to only rows/columns >=0
                    newX = Math.max(0, newX)
                    newY = Math.max(0, newY)
                    // constrain positional movement to only rows/columns <= total container height/width - object's height/width
                    newX = Math.min(newX, (overlayContainer.columnCount - layoutOverlayRoot.layoutInfo.columnsWide) * overlayContainer.columnSize)
                    newY = Math.min(newY, (overlayContainer.rowCount - layoutOverlayRoot.layoutInfo.rowsTall) * overlayContainer.rowSize)

                    let newPosition = overlayContainer.mapToItem(layoutOverlayRoot, newX, newY)
                    rect.x = newPosition.x
                    rect.y = newPosition.y

                    if (layoutOverlayRoot.isSelected && visualEditor.selectedMultiObjectsUuid.length > 1) {
                        rect.x = Math.max(rect.x, -dragRectLeftLimit)
                        rect.x = Math.min(rect.x, dragRectRightLimit)
                        rect.y = Math.max(rect.y, -dragRectTopLimit)
                        rect.y = Math.min(rect.y, dragRectBottomLimit)

                        const xOffset = rect.x - layoutOverlayRoot.multiItemTargetPrevX
                        const yOffset = rect.y - layoutOverlayRoot.multiItemTargetPrevY
                        if (Math.round(xOffset) !== 0 || Math.round(yOffset) !== 0) {
                            visualEditor.functions.dragGroup(layoutOverlayRoot.objectName, xOffset, yOffset)
                        }

                        layoutOverlayRoot.multiItemTargetPrevX = rect.x
                        layoutOverlayRoot.multiItemTargetPrevY = rect.y
                    }
                }
            }

            onContainsMouseChanged: {
                if (containsMouse) {
                    // fetch type and id of object when mousing over
                    // overlay's object name is equivalent to the id of the item since id's are not accessible at runtime
                    if (layoutOverlayRoot.objectName === "") {
                        layoutOverlayRoot.objectName = visualEditor.functions.getObjectPropertyValue(layoutOverlayRoot.sourceItem.layoutInfo.uuid, "id")
                        layoutOverlayRoot.type = visualEditor.functions.getType(layoutOverlayRoot.sourceItem.layoutInfo.uuid)
                    }
                }
            }
        }

        Rectangle {
            id: rect
            opacity: .25
            color: dragMouseArea.drag.active || resizeMouseArea.drag.active ? Theme.palette.error : "transparent"
            border.width: 1
            width: parent.width
            height: parent.height
        }

        Rectangle {
            id: border
            color: "transparent"
            border.width: 2
            border.color: Theme.palette.onsemiLightBlue
            visible: dragMouseArea.containsMouse && (dragMouseArea.drag.active || resizeMouseArea.drag.active) === false
            width: parent.width
            height: parent.height
        }

        Rectangle {
            id: selectedBorder
            color: "transparent"
            border.width: 3
            border.color: Theme.palette.onsemiDarkBlue 
            visible: layoutOverlayRoot.isSelected
            width: parent.width
            height: parent.height
        }

        Item {
            anchors {
                fill: parent
            }
            clip: dragMouseArea.containsMouse === false
            visible: border.visible

            Rectangle {
                opacity: .85
                anchors {
                    fill: nameString
                }
            }

            ColumnLayout {
                id: nameString
                x: 1
                y: x
                spacing: 2

                Text {
                    font.pixelSize: 10
                    text: layoutOverlayRoot.objectName
                }

                Text {
                    font.pixelSize: 8
                    text: layoutOverlayRoot.type
                    opacity: .5
                }
            }
        }

        Image {
            id: resizeRect
            anchors {
                right: rect.right
                bottom: rect.bottom
            }
            width: 10
            height: width
            source: "resize.svg"

            MouseArea {
                id: resizeMouseArea
                width: parent.width * 1.5
                height: parent.height * 1.5
                cursorShape: Qt.SizeFDiagCursor
                drag.target: this // this determines which object will be moved in a drag
                Drag.active: drag.active
                Drag.hotSpot.x: width / 2
                Drag.hotSpot.y: height / 2

                property point startPoint

                property real dragResizeRectLeftLimit
                property real dragResizeRectRightLimit
                property real dragResizeRectTopLimit
                property real dragResizeRectBottomLimit

                onPressed: {
                    startPoint = Qt.point(mouseX, mouseY)

                    if ((mouse.modifiers & Qt.ShiftModifier) == false && layoutOverlayRoot.isSelected === false) {
                        visualEditor.multiObjectsDeselectAll()
                        layoutOverlayRoot.isSelected = true
                        visualEditor.functions.addUuidToMultiObjectSelection(layoutOverlayRoot.sourceItem.layoutInfo.uuid)
                    } else if (visualEditor.selectedMultiObjectsUuid.length > 1) {
                        layoutOverlayRoot.multiItemTargetPrevWidth = rect.width
                        layoutOverlayRoot.multiItemTargetPrevHeight = rect.height

                        multiItemTargetRectLimits = visualEditor.functions.getMultiItemTargetResizeRectLimits()
                        dragResizeRectLeftLimit = (multiItemTargetRectLimits[0] - 1) * overlayContainer.columnSize
                        dragResizeRectRightLimit = multiItemTargetRectLimits[1] * overlayContainer.columnSize
                        dragResizeRectTopLimit = (multiItemTargetRectLimits[2] - 1) * overlayContainer.rowSize
                        dragResizeRectBottomLimit = multiItemTargetRectLimits[3] * overlayContainer.rowSize
                    }
                }

                onReleased: {
                    let newPoint = resizeMouseArea.mapToItem(overlayContainer, mouse.x - startPoint.x, mouse.y - startPoint.y)
                    let newX = Math.round(newPoint.x / overlayContainer.columnSize) * overlayContainer.columnSize
                    let newY = Math.round(newPoint.y / overlayContainer.rowSize) * overlayContainer.rowSize
                    let newPosition = overlayContainer.mapToItem(layoutOverlayRoot, newX, newY)

                    let colRow = Qt.point(Math.round(newPosition.x / overlayContainer.columnSize), Math.round(newPosition.y / overlayContainer.rowSize))
                    colRow = Qt.point(Math.max(colRow.x, 1), Math.max(colRow.y, 1))

                    // if actually resized, edit file
                    if (colRow.x !== layoutOverlayRoot.layoutInfo.columnsWide || colRow.y !== layoutOverlayRoot.layoutInfo.rowsTall) {
                        if (layoutOverlayRoot.isSelected && visualEditor.selectedMultiObjectsUuid.length > 1) {
                            var xOffset = colRow.x - layoutOverlayRoot.layoutInfo.columnsWide
                            var yOffset = colRow.y - layoutOverlayRoot.layoutInfo.rowsTall
                            if (xOffset !== 0 || yOffset !== 0) {
                                xOffset = Math.max(xOffset, (-multiItemTargetRectLimits[0] + 1))
                                xOffset = Math.min(xOffset, multiItemTargetRectLimits[1])
                                yOffset = Math.max(yOffset, (-multiItemTargetRectLimits[2] + 1))
                                yOffset = Math.min(yOffset, multiItemTargetRectLimits[3])
                                visualEditor.functions.resizeGroup(xOffset, yOffset)
                                console.log("Resized selected " + visualEditor.selectedMultiObjectsUuid.length + " items by (" + xOffset + "," + yOffset + ")")
                            }
                        } else {
                            visualEditor.functions.resizeItem(layoutOverlayRoot.layoutInfo.uuid, colRow.x, colRow.y)
                            console.log("Resized:", layoutOverlayRoot.objectName)
                        }
                    } else {
                        // reset mousearea position when it was dragged out of place but not enough to trigger above resize
                        x = 0
                        y = 0
                        if (layoutOverlayRoot.isSelected && visualEditor.selectedMultiObjectsUuid.length > 1) {
                            visualEditor.functions.unload(true)
                        }
                    }
                }

                onPositionChanged: {
                    if (pressed) {
                        let newPoint = resizeMouseArea.mapToItem(overlayContainer, mouse.x - startPoint.x, mouse.y - startPoint.y)
                        let newX = Math.round(newPoint.x / overlayContainer.columnSize) * overlayContainer.columnSize
                        let newY = Math.round(newPoint.y / overlayContainer.rowSize) * overlayContainer.rowSize
                        let newPosition = overlayContainer.mapToItem(layoutOverlayRoot, newX, newY)

                        rect.width = Math.max(newPosition.x, overlayContainer.columnSize) // size must be >= one column, 1 row. no 0x0 or negative sizes
                        rect.height = Math.max(newPosition.y, overlayContainer.rowSize)

                        if (layoutOverlayRoot.isSelected && visualEditor.selectedMultiObjectsUuid.length > 1) {
                            const originalWidth = layoutOverlayRoot.layoutInfo.columnsWide * overlayContainer.columnSize
                            const originalHeight = layoutOverlayRoot.layoutInfo.rowsTall * overlayContainer.rowSize
                            rect.width = Math.max(rect.width, originalWidth - dragResizeRectLeftLimit)
                            rect.width = Math.min(rect.width, originalWidth + dragResizeRectRightLimit)
                            rect.height = Math.max(rect.height, originalHeight - dragResizeRectTopLimit)
                            rect.height = Math.min(rect.height, originalHeight + dragResizeRectBottomLimit)

                            if (layoutOverlayRoot.objectName === "") {
                                layoutOverlayRoot.objectName = visualEditor.functions.getObjectPropertyValue(layoutOverlayRoot.sourceItem.layoutInfo.uuid, "id")
                                layoutOverlayRoot.type = visualEditor.functions.getType(layoutOverlayRoot.sourceItem.layoutInfo.uuid)
                            }

                            const xOffset = rect.width - layoutOverlayRoot.multiItemTargetPrevWidth
                            const yOffset = rect.height - layoutOverlayRoot.multiItemTargetPrevHeight
                            if (xOffset !== 0 || yOffset !== 0) {
                                visualEditor.functions.resizeDragGroup(layoutOverlayRoot.objectName, xOffset, yOffset)
                            }

                            layoutOverlayRoot.multiItemTargetPrevWidth = rect.width
                            layoutOverlayRoot.multiItemTargetPrevHeight = rect.height
                        }
                    }
                }
            }
        }

        Loader {
            id: contextLoader
            active: false
            sourceComponent: ContextMenu {
                id: contextMenu
            }
        }

        Loader {
            id: menuLoader
            active: false
        }
    }
}
