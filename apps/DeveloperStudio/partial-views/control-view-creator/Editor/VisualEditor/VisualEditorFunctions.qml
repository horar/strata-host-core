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
        if (fileUrl.startsWith("file")) {
            fileUrl = SGUtilsCpp.urlToLocalFile(fileUrl)
        }
        // console.log("readFileContents:", fileUrl)

        let fileContent = SGUtilsCpp.readTextFileContent(fileUrl)
        // console.log("content:", fileContent)
        return fileContent
    }

    function saveFile(fileUrl = file, text = fileContents) {
        // todo: potentially clean up empty lines in file before save, e.g. more than 2 empty lines in a row -> 1 empty line
        SGUtilsCpp.atomicWrite(SGUtilsCpp.urlToLocalFile(fileUrl), text)
        unload(true)
    }

    function checkFile() {
        if (visualEditor.file.toLowerCase().endsWith(".qml")){
            sdsModel.qtLogger.visualEditorReloading = true
            loader.setSource(visualEditor.file)
            sdsModel.qtLogger.visualEditorReloading = false

            if (loader.children[0] && loader.children[0].objectName === "UIBase") {
                visualEditor.fileValid = true
                unload(false)
                return
            }
        }
        loadError()
    }

    function unload(reload = false) {
        loader.setSource("")
        for (let i = 0; i < overlayObjects.length; i++) {
            overlayObjects[i].destroy()
        }
        overlayObjects = []
        destructionTimer.reload = reload
        destructionTimer.start()
    }

    function load() {
        if (visualEditor.file.toLowerCase().endsWith(".qml")){
            fileContents = readFileContents(visualEditor.file)
            sdsModel.qtLogger.visualEditorReloading = true
            loader.setSource(visualEditor.file)
            sdsModel.qtLogger.visualEditorReloading = false

            if (loader.children[0] && loader.children[0].objectName === "UIBase") {
                overlayContainer.rowCount = loader.children[0].rowCount
                overlayContainer.columnCount = loader.children[0].columnCount
                identifyChildren(loader.children[0])
                visualEditor.fileValid = true
            } else {
                loadError()
            }
        } else {
            visualEditor.fileValid = false
            visualEditor.error = "Visual Editor supports QML files only"
        }
    }

    function loadError() {
        unload(false)
        loader.setSource("qrc:/partial-views/SGLoadError.qml")
        if (loader.children[0] && loader.children[0].objectName !== "UIBase") {
            console.log("Visual Editor disabled: file '" + visualEditor.file + "' does not derive from UIBase")
            loader.item.error_intro = "Unable to display file"
            loader.item.error_message = "File does not derive from UIBase. UIBase must be root object to use visual editor."
            visualEditor.fileValid = false
            visualEditor.error = "Visual Editor supports files derived from UIBase only"
        } else {
            loader.item.error_intro = "Unable to display file"
            loader.item.error_message = "Build error, see logs"
        }
    }

    function identifyChildren(item){
        // console.log("Item:", item.uuid)
        if (item.hasOwnProperty("layoutInfo")){
            overlayContainer.createOverlay(item)
        }

        for (let i = 0; i < item.children.length; i++) {
            if (item.children[i].objectName !== "UIBase") { // don't examine children made up of a separate UIBase (e.g. composite widgets also created in VisualEditor)
                identifyChildren(item.children[i])
            }
        }
    }

    function addControl(controlPath){
        // console.log("addControl:", controlPath)
        let testComponent = readFileContents(controlPath)
        testComponent = testComponent.arg(create_UUID()) // replace all instances of %1 with uuid

        insertTextAtEndOfFile(testComponent)

        if (!layoutDebugMode) {
            layoutDebugMode = true
        }
    }

    function insertTextAtEndOfFile(text) {
        let regex = new RegExp(endOfObjectRegexString("uibase"))  // insert text before file ending '} // end_uibase'
        let endOfFile = fileContents.match(regex)
        if (endOfFile === null) {
            return
        }
        fileContents = fileContents.replace(endOfFile, "\n" + text + "\n" + endOfFile);
        // console.log("fileContents:", fileContents)
        saveFile()
    }

    function removeControl(uuid) {
        const objectString = getObjectFromString(uuid)
        if (objectString === null) {
            return
        }
        fileContents = fileContents.replace(objectString, "\n");

        saveFile(file, fileContents)
    }

    function duplicateControl(uuid){
        let copy = getObjectFromString(uuid)
        if (copy === null) {
            return
        }

        let type = getType(uuid)
        if (type === null) {
            return
        }
        type = type.charAt(0).toLowerCase() + type.slice(1); // lowercase the first letter of the type
        const newUuid = create_UUID()

        // replace old uuid in tags
        const allInstancesOfUuidRegex = new RegExp(uuid, "g")
        copy = copy.replace(allInstancesOfUuidRegex, newUuid)

        // capture lines that of the format "    id: somePropertyName" as key and value groups
        const idRegex = new RegExp("(^\\s*id:\\s*)([a-zA-Z0-9_]*)", "gm")
        var first = true

        // duplicate object's id replaced with "<type>_<newUuid>"
        // append "_<uuid>" to nested id's, to prevent collision
        copy = copy.replace(idRegex, function(match, idKey, idValue){
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

        insertTextAtEndOfFile(copy)
    }

    function bringToFront(uuid){
        let copy = getObjectFromString(uuid)
        if (copy === null) {
            return
        }
        fileContents = fileContents.replace(copy, "\n");
        insertTextAtEndOfFile(copy)
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
        return value;
    }

    function getObjectFromString(uuid, string = fileContents) {
        let objectString
        try {
            objectString = string.match(captureObjectByUuidRegex(uuid))[0]
        } catch (e) {
            objectString = null
            console.warn("No match for " + uuid + " found, object start/end tags may be malformed or does not exist")
        }
        return objectString;
    }

    function setObjectPropertyAndSave(uuid, propertyName, value) {
        fileContents = setObjectProperty(uuid, propertyName, value, fileContents)
        saveFile()
    }

    /*
        Sets <propertyName> to <value> in object with <uuid>
        If <propertyName> is not found, it will be appended as a new property above the first child or end of object
        ** Only works on properties declared above children - see getObjectContents
    */
    function setObjectProperty(uuid, propertyName, value, string = fileContents) {
        const objectString = getObjectFromString(uuid, string)
        if (objectString === null) {
            return
        }

        const objectContents = getObjectContents(objectString)
        if (objectContents === null) {
            return
        }

        let newObjectContents
        let propertyMatch = getPropertyFromString(propertyName, objectContents)
        if (propertyMatch !== null) {
            // property found in objectContents, replace its value
            let propertyLine = propertyMatch[0]
            let propertyValue = propertyMatch[1]
            let newPropertyLine = propertyLine.replace(propertyValue, value)
            newObjectContents = objectContents.replace(propertyLine, newPropertyLine)
        } else {
            // property not currently assigned in objectContents, append property to end
            newObjectContents = objectContents + getIndentLevel(objectContents) + propertyName +": " + value +"\n"
        }

        let newObjectString = objectString.replace(objectContents, newObjectContents);
        return string.replace(objectString, newObjectString);
    }

    // returns object contents between tags
    // and if removeChildren, return object contents that occur before first child
    function getObjectContents(objectString, removeChildren = true) {
        let captureContentsRegex = new RegExp(startOfObjectRegexString() + "([\\S\\s]*(?:\\r\\n|\\r|\\n))" +  endOfObjectRegexString())
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

    function create_UUID(){
        var dt = new Date().getTime();
        var uuid = 'xxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c =='x' ? r :(r&0x3|0x8)).toString(16);
        });
        return uuid;
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
}
