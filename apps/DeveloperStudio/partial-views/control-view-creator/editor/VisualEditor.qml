/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.sglayout 1.0
import tech.strata.fonts 1.0
import tech.strata.commoncpp 1.0

import "visual-editor/layout-overlay"
import "visual-editor"

ColumnLayout {
    id: visualEditor
    spacing: 0
    enabled: fileValid

    property bool fileValid: false
    property bool hasErrors: false
    property bool layoutDebugMode: true
    property var overlayObjects: []
    property string file: ""
    property string fileContents: ""

    // multi-item selection/dragging/resizing
    property var selectedMultiObjectsUuid: []
    signal multiObjectsDragged(string objectInitiated, var x, var y)
    signal multiObjectsResizeDragged(string objectInitiated, var width, var height)
    signal multiObjectsDeselectAll()

    onMultiObjectsDeselectAll: {
        selectedMultiObjectsUuid = []
    }

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

    MouseArea {
        id: loaderContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        onClicked: {
            if ((mouse.modifiers & Qt.ShiftModifier) == false) {
                multiObjectsDeselectAll()
            }
        }

        Loader {
            id: loader
            anchors {
                fill: parent
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
                // these will be fetched when moused over for the first time
                overLayObject.objectName = ""
                overLayObject.type = ""

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
        target: treeModel
        enabled: cvcUserSettings.reloadViewExternalChanges && visualEditor.fileValid

        onFileChanged: {
            if (path == visualEditor.file) {
                functions.unload(true)
            }
        }
    }

    Connections {
        target: sdsModel.visualEditorUndoStack
        enabled: visualEditor.fileValid

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
                functions.insertTextAtEndOfFile(objectString)
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
        enabled: visualEditor.fileValid

        onTextEditorSavedFile: {
            console.log("Visual Editor undo/redo reset: detected saved changes in Text Editor to " + SGUtilsCpp.urlToLocalFile(visualEditor.file))
            sdsModel.visualEditorUndoStack.clearStack(visualEditor.file)
        }
    }

    Connections {
        target: treeModel
        enabled: visualEditor.fileValid

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
