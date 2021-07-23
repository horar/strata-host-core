import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sglayout 1.0

// "layout mode" overlay that appears on top of handled objects

LayoutContainer {
    id: layoutOverlayRoot
    visible: layoutDebugMode

    property string type: ""
    property var sourceItem  // Item that this overlay represents

    contentItem: Item {

        MouseArea {
            id: dragMouseArea
            width: parent.width
            height: parent.height
            drag.target: this  // determines which object will be moved in a drag
            Drag.active: drag.active
            Drag.hotSpot.x: width/2
            Drag.hotSpot.y: height/2
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true

            property point startPoint

            onPressedChanged: {
                if (pressed){
                    startPoint = Qt.point(mouseX, mouseY)
                }
            }

            onClicked: {
                if (mouse.button == Qt.RightButton) {
                    contextLoader.active = true

                    // if popup will spawn past edge of window, place it on the opposite side of the click
                    if (contextLoader.item.height + mouse.y + layoutOverlayRoot.y > layoutOverlayRoot.parent.height) {
                        contextLoader.item.y = mouse.y - contextLoader.item.height
                    } else {
                        contextLoader.item.y = mouse.y
                    }

                    if (contextLoader.item.width + mouse.x + layoutOverlayRoot.x > layoutOverlayRoot.parent.width) {
                        contextLoader.item.x = mouse.x - contextLoader.item.width
                    } else {
                        contextLoader.item.x = mouse.x
                    }

                    contextLoader.item.open()
                }
            }

            onReleased: {
                // todo: this runs if off by >=1 pixel, should only run if a different row/column is achieved
                // todo: invalid placement can be achieved outside layout

                // if moved, edit file
                let position = dragMouseArea.mapToItem(layoutOverlayRoot, x, y)
                if (position.x !== 0 || position.y !==0 ) {
                    console.log("Moved:", layoutOverlayRoot.objectName)
                    let newPosition = layoutOverlayRoot.mapToItem(overlayContainer, rect.x, rect.y)
                    let colRow = Qt.point(Math.round(newPosition.x / overlayContainer.columnSize), Math.round(newPosition.y / overlayContainer.rowSize))

                    fileContents = visualEditor.functions.setObjectProperty(layoutOverlayRoot.layoutInfo.uuid, "layoutInfo.xColumns",  colRow.x)
                    fileContents = visualEditor.functions.setObjectProperty(layoutOverlayRoot.layoutInfo.uuid, "layoutInfo.yRows",  colRow.y)

                    visualEditor.functions.saveFile(file, fileContents)
                }
            }

            onPositionChanged: {
                if (pressed) {
                    // determine mouse pointer position within mouseArea and how it relates to the overlayContainer, converted to row/column API
                    let newPoint = dragMouseArea.mapToItem(overlayContainer, mouse.x-startPoint.x, mouse.y-startPoint.y)
                    let newX = Math.round(newPoint.x/overlayContainer.columnSize) * overlayContainer.columnSize
                    let newY = Math.round(newPoint.y/overlayContainer.rowSize) * overlayContainer.rowSize
                    newX = Math.max(0, newX) // constrain positional movement to only rows/columns >=0
                    newY = Math.max(0, newY)

                    let newPosition = overlayContainer.mapToItem(layoutOverlayRoot, newX, newY)

                    rect.x = newPosition.x
                    rect.y = newPosition.y
                }
            }

            onWheel: wheel.accepted = true // do not propagate wheel events to objects below overlay (e.g. sggraph zoom)

            onContainsMouseChanged: {
                if (containsMouse) {
                    // fetch type and id of object when mousing over
                    // overlay's object name is equivalent to the id of the item since id's are not accessible at runtime
                    if (layoutOverlayRoot.objectName === "") {
                        layoutOverlayRoot.objectName = functions.getObjectPropertyValue(layoutOverlayRoot.sourceItem.layoutInfo.uuid, "id")
                        layoutOverlayRoot.type = functions.getType(layoutOverlayRoot.sourceItem.layoutInfo.uuid)
                    }
                }
            }
        }

        Rectangle {
            id: rect
            opacity: .25
            color: dragMouseArea.drag.active || resizeMouseArea.drag.active ? "red" : "white"
            border.width: 1
            width: parent.width
            height: parent.height
        }

        Rectangle {
            id: border
            color: "transparent"
            border.width: 2
            border.color: "#00A6CC"
            visible: dragMouseArea.containsMouse && (dragMouseArea.drag.active || resizeMouseArea.drag.active) === false
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
                drag.target: this     //this determines which object will be moved in a drag
                Drag.active: drag.active
                Drag.hotSpot.x: width/2
                Drag.hotSpot.y: height/2

                property point startPoint

                onPressedChanged: {
                    if (pressed){
                        startPoint = Qt.point(mouseX, mouseY)
                    }
                }

                onReleased: {
                    let newPoint = resizeMouseArea.mapToItem(overlayContainer, mouse.x-startPoint.x, mouse.y-startPoint.y)
                    let newX = Math.round(newPoint.x/overlayContainer.columnSize) * overlayContainer.columnSize
                    let newY = Math.round(newPoint.y/overlayContainer.rowSize) * overlayContainer.rowSize
                    let newPosition = overlayContainer.mapToItem(layoutOverlayRoot, newX, newY)

                    let colRow = Qt.point(Math.round(newPosition.x / overlayContainer.columnSize), Math.round(newPosition.y / overlayContainer.rowSize))
                    colRow = Qt.point(Math.max(colRow.x, 1), Math.max(colRow.y, 1))

                    if (colRow.x !== layoutOverlayRoot.layoutInfo.columnsWide || colRow.y !== layoutOverlayRoot.layoutInfo.rowsTall) {
                        // if actually resized, edit file
                        fileContents = visualEditor.functions.setObjectProperty(layoutOverlayRoot.layoutInfo.uuid, "layoutInfo.columnsWide",  colRow.x)
                        fileContents = visualEditor.functions.setObjectProperty(layoutOverlayRoot.layoutInfo.uuid, "layoutInfo.rowsTall",  colRow.y)

                        visualEditor.functions.saveFile(file, fileContents)
                    } else {
                        // reset mousearea position when it was dragged out of place but not enough to trigger above resize
                        x = 0
                        y = 0
                    }
                }

                onPositionChanged: {
                    if (pressed) {
                        let newPoint = resizeMouseArea.mapToItem(overlayContainer, mouse.x-startPoint.x, mouse.y-startPoint.y)
                        let newX = Math.round(newPoint.x/overlayContainer.columnSize) * overlayContainer.columnSize
                        let newY = Math.round(newPoint.y/overlayContainer.rowSize) * overlayContainer.rowSize
                        let newPosition = overlayContainer.mapToItem(layoutOverlayRoot, newX, newY)

                        rect.width = Math.max(newPosition.x, overlayContainer.columnSize) // size must be >= one column, 1 row. no 0x0 or negative sizes
                        rect.height = Math.max(newPosition.y, overlayContainer.rowSize)
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
