/*
 * Copyright (c) 2018-2021 onsemi.
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
import tech.strata.fonts 1.0
import tech.strata.commoncpp 1.0

QtObject {
    id: functions

    signal passUUID(string uuid)

    property bool saveRequestedByVE: false

    property Timer destructionTimer: Timer {
        interval: 1

        property bool reload

        onTriggered: {
            // Asynchronously wait for loader components to finish destruction before trimComponentCache
            // in order to purge cache and force all files to refresh when reloaded
            sdsModel.resourceLoader.trimComponentCache(visualEditor)

            if (reload) {
                // reload after cleanup in some cases
                reload = false
                load()
            }
        }
    }

    Component.onDestruction: {
        unload(false)
    }

    function readFileContents(fileUrl) {
        if (!SGUtilsCpp.isFile(fileUrl)) {
            fileUrl = SGUtilsCpp.urlToLocalFile(fileUrl)
        }

        if (!SGUtilsCpp.exists(fileUrl)) {
            console.warn("Tried to read non-existent file: " + fileUrl)
            return ""
        }

        return SGUtilsCpp.readTextFileContent(fileUrl)
    }

    function saveFile(fileUrl = file, text = fileContents) {
        saveRequestedByVE = true
        text = sdsModel.visualEditorUndoStack.trimQmlEmptyLines(text)
        SGUtilsCpp.atomicWrite(SGUtilsCpp.urlToLocalFile(fileUrl), text)
        unload(true)
    }

    function checkFile() {
        if (visualEditor.file.toLowerCase().endsWith(".qml")) {
            visualEditor.fileValid = true
        } else {
            visualEditor.fileValid = false
        }
    }

    function unload(reload = false) {
        loader.setSource("")
        overlayContainer.rowCount = 0
        overlayContainer.columnCount = 0
        for (let i = 0; i < overlayObjects.length; i++) {
            overlayObjects[i].destroy()
        }
        overlayObjects = []
        destructionTimer.reload = reload
        destructionTimer.start()
    }

    function load() {
        fileContents = readFileContents(visualEditor.file)
        sdsModel.qtLogger.visualEditorReloading = true
        loader.setSource(visualEditor.file)
        sdsModel.qtLogger.visualEditorReloading = false
        if (loader.children[0] && loader.children[0].objectName === "UIBase") {
            visualEditor.hasErrors = false
            overlayContainer.rowCount = loader.children[0].rowCount
            overlayContainer.columnCount = loader.children[0].columnCount
            identifyChildren(loader.children[0])
        } else {
            if (loader.sourceComponent.errorString().length > 0) {
                loadError(loader.sourceComponent.errorString())
            } else {
                loadError("To use Visual Editor, file must contain UIBase as root object", false)
            }
        }
    }

    function loadError(errorMsg, logError = true) {
        unload(false)
        loader.setSource("qrc:/partial-views/SGLoadError.qml")
        visualEditor.hasErrors = true
        loader.item.error_intro = "Visual Editor is disabled"
        loader.item.error_message = errorMsg
        if (logError) {
            console.error("Visual Editor could not load: "+`${errorMsg}`)
        }
    }

    function identifyChildren(item) {
        if (item.hasOwnProperty("layoutInfo")) {
            overlayContainer.createOverlay(item)
        }

        for (let i = 0; i < item.children.length; i++) {
            if (item.children[i].objectName !== "UIBase") {
                // don't examine children made up of a separate UIBase (e.g. composite widgets also created in VisualEditor)
                identifyChildren(item.children[i])
            }
        }
    }

    function addControl(controlPath) {
        const uuid = create_UUID()
        let objectString = readFileContents(controlPath)
        objectString = objectString.arg(uuid) // replace all instances of %1 with uuid

        insertTextAtEndOfFile(objectString)

        // undo/redo
        sdsModel.visualEditorUndoStack.addItem(file, uuid, objectString)

        if (!layoutDebugMode) {
            layoutDebugMode = true
        }
    }

    function insertTextAtEndOfFile(text, save = true) {
        let regex = new RegExp(endOfObjectRegexString("uibase")) // insert text before file ending '} // end_uibase'
        let endOfFile = fileContents.match(regex)
        if (endOfFile === null) {
            return
        }
        fileContents = fileContents.replace(endOfFile, "\n" + text + "\n" + endOfFile)

        if (save) {
            saveFile()
        }
    }

    function removeControl(uuid, addToUndoCommandStack = true, save = true, deselect = true) {
        const objectString = getObjectFromString(uuid)
        if (objectString === null) {
            return
        }
        fileContents = fileContents.replace(objectString, "\n")

        // undo/redo
        if (addToUndoCommandStack) {
            sdsModel.visualEditorUndoStack.removeItem(file, uuid, objectString)
        }
        if (save) {
            saveFile()
        }
        // remove the deleted item from selected-items array
        if (deselect) {
            removeUuidFromMultiObjectSelection(uuid)
        }
    }

    function removeControlSelected() {
        for (let i = 0; i < visualEditor.selectedMultiObjectsUuid.length; ++i) {
            const selectedUuid = visualEditor.selectedMultiObjectsUuid[i]
            removeControl(selectedUuid, true, false, false)
        }
        saveFile()
        visualEditor.selectedMultiObjectsUuid = []
    }

    function duplicateControl(uuid, save = true) {
        let copy = getObjectFromString(uuid)
        if (copy === null) {
            return
        }

        let type = getType(uuid)
        if (type === null) {
            return
        }
        type = type.charAt(0).toLowerCase() + type.slice(1) // lowercase the first letter of the type
        const newUuid = create_UUID()

        // replace old uuid in tags
        const allInstancesOfUuidRegex = new RegExp(uuid, "g")
        copy = copy.replace(allInstancesOfUuidRegex, newUuid)

        // capture lines that of the format "    id: somePropertyName" as key and value groups
        const idRegex = new RegExp("(^\\s*id:\\s*)([a-zA-Z0-9_]*)", "gm")
        var first = true

        // duplicate object's id replaced with "<type>_<newUuid>"
        // append "_<uuid>" to nested id's, to prevent collision
        copy = copy.replace(idRegex, function(match, idKey, idValue) {
            if (first) {
                first = false
                return `${idKey}${type}_${newUuid}`
            } else {
                return `${idKey}${idValue}_${create_UUID()}`
            }
        })

        // if item-to-be-duplicated is not touching the edge of the layout, offset it by 1 row and 1 column
        let column = getObjectPropertyValue(newUuid, "layoutInfo.xColumns", copy)
        let row = getObjectPropertyValue(newUuid, "layoutInfo.yRows", copy)
        if (column !== null && row !== null) {
            row = parseInt(row)
            column = parseInt(column)
            if (row < visualEditor.loader.item.rowCount - 1) {
                row++
                copy = setObjectProperty(newUuid, "layoutInfo.yRows", row, copy)
            }
            if (column < visualEditor.loader.item.columnCount - 1) {
                column++
                copy = setObjectProperty(newUuid, "layoutInfo.xColumns", column, copy)
            }
        } else {
            console.warn("Problem detected with layoutInfo in object " + newUuid)
        }

        insertTextAtEndOfFile(copy, save)
    }

    function duplicateControlSelected() {
        for (let i = 0; i < visualEditor.selectedMultiObjectsUuid.length; ++i) {
            const selectedUuid = visualEditor.selectedMultiObjectsUuid[i]
            duplicateControl(selectedUuid, false)
        }
        saveFile()
    }

    function bringToFront(uuid, save = true) {
        let copy = getObjectFromString(uuid)
        if (copy === null) {
            return
        }
        fileContents = fileContents.replace(copy, "\n")
        insertTextAtEndOfFile(copy, save)
    }

    function bringToFrontSelected() {
        for (let i = 0; i < visualEditor.selectedMultiObjectsUuid.length; ++i) {
            const selectedUuid = visualEditor.selectedMultiObjectsUuid[i]
            bringToFront(selectedUuid, false)
        }
        saveFile()
    }

    /*
        Given a <string>, find object's start and end tags for <uuid>, within those tags find the first
        instance of <propertyName> and return its value.
            ** Only works for one-line properties.
            ** Only works for properties declared above children - see getObjectContents
    */
    function getObjectPropertyValue(uuid, propertyName, string = fileContents) {
        let objectString = getObjectFromString(uuid, string)
        if (objectString === null) {
            return null
        }

        let objectContents = getObjectContents(objectString)
        if (objectContents === null) {
            return null
        }

        let value
        try {
            value = getPropertyFromString(propertyName, objectContents)[1]
        } catch (e) {
            console.warn("No match for " + propertyName + " found in object " + uuid +", may be malformed")
            value = null
        }
        return value
    }

    function getObjectFromString(uuid, string = fileContents) {
        let objectString
        try {
            objectString = string.match(captureObjectByUuidRegex(uuid))[0]
        } catch (e) {
            objectString = null
            console.warn("No match for " + uuid + " found, object start/end tags may be malformed or does not exist")
        }
        return objectString
    }

    function setObjectPropertyAndSave(uuid, propertyName, value, addToUndoCommandStack = true) {
        fileContents = setObjectProperty(uuid, propertyName, value, fileContents, addToUndoCommandStack)
        saveFile()
    }

    /*
        Sets <propertyName> to <value> in object with <uuid>
        If <propertyName> is not found, it will be appended as a new property above the first child or end of object
        ** Only works on properties declared above children - see getObjectContents
    */
    function setObjectProperty(uuid, propertyName, value, string = fileContents, addToUndoCommandStack = true) {
        if (string == "") {
            string = fileContents
        }

        const objectString = getObjectFromString(uuid, string)
        if (objectString === null) {
            return
        }

        const objectContents = getObjectContents(objectString)
        if (objectContents === null) {
            return
        }

        let undoValue = ""
        let newObjectContents
        let propertyMatch = getPropertyFromString(propertyName, objectContents)
        if (propertyMatch !== null) {
            // property found in objectContents
            let propertyLine = propertyMatch[0]
            let propertyValue = propertyMatch[1]

            if (!value && value !== 0) {
                // new value is empty, so remove the line containing it
                newObjectContents = objectContents.replace(propertyLine, "")
            } else {
                // new value is valid, so replace it
                let newPropertyLine = propertyLine.replace(propertyValue, value)
                newObjectContents = objectContents.replace(propertyLine, newPropertyLine)
                undoValue = propertyValue
            }
        } else {
            // property not currently assigned in objectContents, append property to end
            newObjectContents = objectContents + getIndentLevel(objectContents) + propertyName + ": " + value + "\n"
        }

        // undo/redo
        if (addToUndoCommandStack) {
            sdsModel.visualEditorUndoStack.addCommand(file, uuid, propertyName, value, undoValue)
        }

        let newObjectString = objectString.replace(objectContents, newObjectContents)
        return string.replace(objectString, newObjectString)
    }

    function moveItem(uuid, newX, newY, addToUndoCommandStack = true, save = true) {
        const oldX = getObjectPropertyValue(uuid, "layoutInfo.xColumns")
        const oldY = getObjectPropertyValue(uuid, "layoutInfo.yRows")

        fileContents = setObjectProperty(uuid, "layoutInfo.xColumns", newX, "", false)
        fileContents = setObjectProperty(uuid, "layoutInfo.yRows", newY, "", false)

        // undo/redo
        if (addToUndoCommandStack) {
            sdsModel.visualEditorUndoStack.addXYCommand(file, uuid, "move", newX, newY, oldX, oldY)
        }
        if (save) {
            visualEditor.functions.saveFile(file, fileContents)
        }
    }

    function moveGroup(offsetX, offsetY) {
        for (let i = 0; i < visualEditor.overlayObjects.length; ++i) {
            const obj = visualEditor.overlayObjects[i]
            if (!isUuidSelected(obj.layoutInfo.uuid)) {
                continue
            }
            moveItem(obj.layoutInfo.uuid, obj.layoutInfo.xColumns + offsetX, obj.layoutInfo.yRows + offsetY, true, false)
        }
        saveFile()
    }

    function resizeItem(uuid, newColumnsWide, newRowsTall, addToUndoCommandStack = true, save = true) {
        if (newColumnsWide < 1 || newRowsTall < 1) {
            return
        }

        const oldColumnsWide = getObjectPropertyValue(uuid, "layoutInfo.columnsWide")
        const oldRowsTall = getObjectPropertyValue(uuid, "layoutInfo.rowsTall")

        fileContents = setObjectProperty(uuid, "layoutInfo.columnsWide", newColumnsWide, "", false)
        fileContents = setObjectProperty(uuid, "layoutInfo.rowsTall", newRowsTall, "", false)

        // undo/redo
        if (addToUndoCommandStack) {
            sdsModel.visualEditorUndoStack.addXYCommand(file, uuid, "resize", newColumnsWide, newRowsTall, oldColumnsWide, oldRowsTall)
        }
        if (save) {
            saveFile()
        }
    }

    function resizeGroup(offsetX, offsetY) {
        for (let i = 0; i < visualEditor.overlayObjects.length; ++i) {
            const obj = visualEditor.overlayObjects[i]
            if (!isUuidSelected(obj.layoutInfo.uuid)) {
                continue
            }
            resizeItem(obj.layoutInfo.uuid, obj.layoutInfo.columnsWide + offsetX, obj.layoutInfo.rowsTall + offsetY, true, false)
        }
        saveFile()
    }

    // returns object contents between tags
    // and if removeChildren, return object contents that occur before first child
    function getObjectContents(objectString, removeChildren = true) {
        let captureContentsRegex = new RegExp(startOfObjectRegexString() + "([\\S\\s]*(?:\\r\\n|\\r|\\n))" + endOfObjectRegexString())
        let objectContents

        try {
            objectContents = objectString.match(captureContentsRegex)[1]
        } catch (e) {
            console.warn("Object contents could not be determined, object start/end tags may be malformed")
            return null
        }
        if (removeChildren === false) {
            return objectContents
        }

        let objectNames = getObjectNames(objectContents)
        if (objectNames !== null && objectNames.length > 0) {
            objectContents = objectContents.split(objectNames[0])[0] // split on first child object and keep content before it
        }
        return objectContents;
    }

    // returns match array for propertyName in string - array[0] is whole property line, array[1] is property value match
    // returns null if no match
    // note: meant to operate on a string where only one instance of the property can be found, e.g. after getObjectContents() has been run
    function getPropertyFromString(propertyName, string) {
        propertyName = formatPropertyNameForRegex(propertyName)

        const propertyValueCapture = new RegExp("^\\s*" + propertyName + "\\s*:\\s*(.*)\\s*$","m")
        return string.match(propertyValueCapture)
    }

    // given a string of an object's contents (after getObjectContents()) return the indent level based on its layoutInfo.uuid property
    function getIndentLevel(objectContent) {
        let propertyMatch = getPropertyFromString("layoutInfo.uuid", objectContent)
        if (propertyMatch === null) {
            return ""
        }
        return propertyMatch[0].split("layoutInfo.uuid")[0]
    }

    // in string, find all QML object declaration instances (e.g. 'Rectangle {')
    function getObjectNames(string) {
        const objectDeclarationRegex = new RegExp("^\\s*[A-Z][A-Za-z0-9_]*\\s*{.*$", "gm")
        return string.match(objectDeclarationRegex)
    }

    function getType(uuid) {
        const capture1 = "([A-Z][A-Za-z0-9_]*)" // qml object type, e.g. Rectangle
        const capture2 = "\\s*{\\s*\/\/\\s*start_" + uuid
        const regex = new RegExp(capture1 + capture2)
        let type
        try {
            type = fileContents.match(regex)[1]
        } catch (e) {
            type = null
            console.warn("No match for " + uuid + " found, start/end tags may be malformed")
        }
        return type;
    }

    function alignItem(position, uuid) {
        switch (position) {
            case "horCenter":
                horizontalCenterAlign(uuid)
            break;
            case "verCenter":
                verticalCenterAlign(uuid)
            break;
        }
        saveFile();
    }

    function horizontalCenterAlign(uuid) {
        const horPosition = Math.floor((overlayContainer.columnCount / 2) - getObjectPropertyValue(uuid, "layoutInfo.columnsWide") / 2)
        moveItem(uuid, horPosition, getObjectPropertyValue(uuid, "layoutInfo.yRows"))
    }

    function verticalCenterAlign(uuid) {
        const verPosition = Math.floor((overlayContainer.rowCount / 2) - getObjectPropertyValue(uuid, "layoutInfo.rowsTall") / 2)
        moveItem(uuid, getObjectPropertyValue(uuid, "layoutInfo.xColumns"), verPosition)
    }

    // This will check if item can be exactly centered
    function exactCenterCheck(uuid, horOrVert) {
        if (horOrVert === "horizontal") {
            const calculation = (overlayContainer.columnCount / 2) - (getObjectPropertyValue(uuid, "layoutInfo.columnsWide") / 2)
            const isExact = calculation % 1 === 0
            return isExact
        } else {
            const calculation = (overlayContainer.rowCount / 2) - (getObjectPropertyValue(uuid, "layoutInfo.rowsTall") / 2)
            const isExact = calculation % 1 === 0
            return isExact
        }
    }

    function create_UUID() {
        var dt = new Date().getTime();
        var uuid = 'xxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c =='x' ? r :(r&0x3|0x8)).toString(16);
        });
        return uuid;
    }

    // returns all strings in the current file that contain object ID's
    function getAllObjectIds() {
        const idRegex = new RegExp("^\\s*id:\\s*[a-zA-Z0-9_]*", "gm")
        return fileContents.match(idRegex)
    }

    function formatPropertyNameForRegex(propertyName) {
        return propertyName.replace(".", "\\.") // escape property names with "." for regex (e.g. layoutInfo.rowCount)
    }

    function captureObjectByUuidRegex(uuid) {
        // captures lines with start and end uuid tags, as well as those between and pre- and post-line breaks
        return new RegExp(startOfObjectRegexString(uuid) + "[\\s\\S]*" + endOfObjectRegexString(uuid))
    }

    function uuidRegex() {
        return "[a-z0-9]{5,6}" //{5,6} as either 5 digit uuid or "uibase"
    }

    function startOfObjectRegexString(uuid = uuidRegex()) {
        // matches "   <ObjectName> { // start_<uuid> " where [^\S\r\n] is whitespace-but-not-newline"
        return "[^\S\r\n]*[A-Z][A-Za-z0-9_]*\\s*\\{\\s*\\/\\/\\s*start_" + uuid + ".*"
    }

    function endOfObjectRegexString(uuid = uuidRegex()) {
        // matches "   } // end_<uuid> "
        return "[^\S\r\n]*\\}\\s*\\/\\/\\s*end_" + uuid + ".*"
    }

    // returns whether object uuid is part of multi-item selection
    function isUuidSelected(uuid) {
        return visualEditor.selectedMultiObjectsUuid.includes(uuid)
    }

    // adds object uuid to multi-item selection
    function addUuidToMultiObjectSelection(uuid) {
        if (!isUuidSelected(uuid)) {
            visualEditor.selectedMultiObjectsUuid.push(uuid)
        }
    }

    // removes object uuid from multi-item selection
    function removeUuidFromMultiObjectSelection(uuid) {
        const index = visualEditor.selectedMultiObjectsUuid.indexOf(uuid)
        if (index > -1) {
            visualEditor.selectedMultiObjectsUuid.splice(index, 1)
        }
    }

    // emits multiObjectsDragged signal to all layout items
    function dragGroup(objectInitiated, x, y) {
        visualEditor.multiObjectsDragged(objectInitiated, x, y)
    }

    // emits multiObjectsResizeDragged signal to all layout items
    function resizeDragGroup(objectInitiated, width, height) {
        visualEditor.multiObjectsResizeDragged(objectInitiated, width, height)
    }

    // calculates maximum offsets for multi-item target rectangle for item moving
    function getMultiItemTargetRectLimits() {
        var minX = overlayContainer.columnCount
        var maxX = overlayContainer.columnCount
        var minY = overlayContainer.rowCount
        var maxY = overlayContainer.rowCount

        for (let i = 0; i < visualEditor.overlayObjects.length; ++i) {
            const obj = visualEditor.overlayObjects[i]
            if (!isUuidSelected(obj.layoutInfo.uuid)) {
                continue
            }
            maxX = Math.min(maxX, obj.layoutInfo.xColumns)
            minX = Math.min(minX, overlayContainer.columnCount - obj.layoutInfo.xColumns - obj.layoutInfo.columnsWide)
            maxY = Math.min(maxY, obj.layoutInfo.yRows)
            minY = Math.min(minY, overlayContainer.rowCount - obj.layoutInfo.yRows - obj.layoutInfo.rowsTall)
        }

        return [maxX, minX, maxY, minY]
    }

    // calculates maximum offsets for multi-item target rectangle for item resizing
    function getMultiItemTargetResizeRectLimits() {
        var minX = overlayContainer.columnCount
        var maxX = overlayContainer.columnCount * overlayContainer.columnSize
        var minY = overlayContainer.rowCount
        var maxY = overlayContainer.rowCount * overlayContainer.rowSize

        for (let i = 0; i < visualEditor.overlayObjects.length; ++i) {
            const obj = visualEditor.overlayObjects[i]
            if (!isUuidSelected(obj.layoutInfo.uuid)) {
                continue
            }
            maxX = Math.min(maxX, obj.layoutInfo.columnsWide)
            minX = Math.min(minX, overlayContainer.columnCount - obj.layoutInfo.xColumns - obj.layoutInfo.columnsWide)
            maxY = Math.min(maxY, obj.layoutInfo.rowsTall)
            minY = Math.min(minY, overlayContainer.rowCount - obj.layoutInfo.yRows - obj.layoutInfo.rowsTall)
        }

        return [maxX, minX, maxY, minY]
    }
}
