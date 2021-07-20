import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.sglayout 1.0
import tech.strata.fonts 1.0
import tech.strata.commoncpp 1.0

import "VisualEditor/LayoutOverlay"
import "VisualEditor"

ColumnLayout {
    id: visualEditor
    spacing: 0

    property bool fileValid: false
    property string error: ""
    property bool layoutDebugMode: true
    property var overlayObjects: []
    property string file: ""
    property string fileContents: ""

    property alias loader: loader
    property alias functions: functions

    Component.onCompleted: {
        functions.checkFile()
    }

    onVisibleChanged: {
        if (visible) {
            functions.load()
        } else {
            functions.unload(false)
        }
    }

    VisualEditorFunctions {
        id: functions
    }

    Item {
        id: loaderContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        Loader {
            id: loader
            anchors {
                fill: parent
            }

            onStatusChanged: {
                if (loader.status == Loader.Error) {
                    visualEditor.error = "Error occurred checking this file, see logs"
                }
            }
        }

        Item {
            id: gridContainer

            Repeater {
                model: layoutDebugMode ? overlayContainer.columnCount : 0
                delegate: Rectangle {
                    width: 1
                    opacity: .5
                    x: index * overlayContainer.columnSize
                    height: overlayContainer.height
                    color: "lightgrey"
                }
            }

            Repeater {
                model: layoutDebugMode ? overlayContainer.rowCount : 0
                delegate: Rectangle {
                    height: 1
                    opacity: .5
                    y: index * overlayContainer.rowSize
                    width: overlayContainer.width
                    color: "lightgrey"
                }
            }
        }

        Item {
            id: overlayContainer
            anchors {
                fill: parent
            }

            property int columnCount: 0
            property int rowCount: 0
            property real columnSize: width / columnCount
            property real rowSize: height / rowCount

            function createOverlay(item) {
                var overLayObject = overlayComponent.createObject(overlayContainer)

                // overlay's object name is equivalent to the id of the item since id's are not accessible at runtime
                overLayObject.objectName = functions.getObjectPropertyValue(item.layoutInfo.uuid, "id")
                overLayObject.type = functions.getType(item.layoutInfo.uuid)
                if (overLayObject.objectName === null || overLayObject.type === null) {
                    overLayObject.destroy()
                    return
                }
                overLayObject.layoutInfo.uuid = item.layoutInfo.uuid
                overLayObject.layoutInfo.columnsWide = item.layoutInfo.columnsWide
                overLayObject.layoutInfo.rowsTall = item.layoutInfo.rowsTall
                overLayObject.layoutInfo.xColumns = item.layoutInfo.xColumns
                overLayObject.layoutInfo.yRows = item.layoutInfo.yRows
                overLayObject.sourceItem = item

                overlayObjects.push(overLayObject)
            }

            Component {
                id: overlayComponent

                LayoutOverlay {
                    property int columnCount: overlayContainer.columnCount
                    property int rowCount: overlayContainer.rowCount
                    property real columnSize: overlayContainer.columnSize
                    property real rowSize: overlayContainer.rowSize
                }
            }
        }
    }

    Connections {
        target: sdsModel.visualEditorUndoStack

        onUndoCommand: {
            if (visualEditor.file == file) {
                functions.setObjectPropertyAndSave(uuid, propertyName, value, false)
            }
        }

        onUndoItemAdded: {
            if (visualEditor.file == file) {
                functions.removeControl(uuid, false)
            }
        }

        onUndoItemDeleted: {
            if (visualEditor.file == file) {
                functions.addControlWithPremadeObjectString(objectString)
            }
        }

        onUndoItemMoved: {
            if (visualEditor.file == file) {
                functions.moveItem(uuid, x, y, false)
            }
        }

        onUndoItemResized: {
            if (visualEditor.file == file) {
                functions.resizeItem(uuid, x, y, false)
            }
        }
    }

    Connections {
        target: fileContainerRoot

        onTextEditorSavedFile: {
            console.log("Visual Editor undo/redo reset: detected saved changes in Text Editor to " + SGUtilsCpp.urlToLocalFile(visualEditor.file))
            sdsModel.visualEditorUndoStack.clearStack(visualEditor.file)
        }
    }

    Connections {
        target: treeModel

        onFileChanged: {
            if (path == visualEditor.file) {
                if (visualEditor.functions.saveRequestedByVE) {
                    visualEditor.functions.saveRequestedByVE = false
                } else {
                    console.log("Visual Editor undo/redo reset: detected external changes to " + SGUtilsCpp.urlToLocalFile(visualEditor.file))
                    sdsModel.visualEditorUndoStack.clearStack(visualEditor.file)
                }
            }
        }
    }
}
