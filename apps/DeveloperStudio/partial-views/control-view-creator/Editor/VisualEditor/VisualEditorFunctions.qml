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
        loader.setSource(visualEditor.file)

        if (loader.children[0] && loader.children[0].objectName === "UIBase") {
            visualEditor.fileValid = true
            unload(false)
        } else {
            loadError()
        }
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

            loader.setSource(visualEditor.file)

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
        let regex = new RegExp("([\\s\\S]*)(\})","gm")  // insert text before ending '}' in file
        fileContents = fileContents.replace(regex, "$1\n" + text + "$2");
        // console.log("fileContents:", fileContents)
        saveFile()
    }

    function removeControl(uuid) {
        fileContents = fileContents.replace(captureComponentByUuidRegex(uuid), "");

        saveFile(file, fileContents)
    }

    function duplicateControl(uuid){
        let copy = getObjectFromString(uuid)
        if (copy === "") {
            return
        }

        let type = getType(uuid)
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
        let column = getObjectPropertyValueInString(newUuid, "layoutInfo.xColumns", copy)
        let row = getObjectPropertyValueInString(newUuid, "layoutInfo.yRows", copy)
        if (column !== "" && row !== "") {
            row = parseInt(row)
            column = parseInt(column)
            if (row < visualEditor.loader.item.rowCount - 1) {
                row++
                copy = replaceObjectPropertyValueInString(newUuid, "layoutInfo.yRows", row, copy)
            }
            if (column < visualEditor.loader.item.columnCount - 1) {
                column++
                copy = replaceObjectPropertyValueInString(newUuid, "layoutInfo.xColumns", column, copy)
            }
        } else {
            console.warn("Problem detected with layoutInfo in object " + newUuid)
        }

        insertTextAtEndOfFile(copy)
    }

    function bringToFront(uuid){
        let copy = getObjectFromString(uuid)
        if (copy === "") {
            return
        }
        fileContents = fileContents.replace(captureComponentByUuidRegex(uuid), "");
        insertTextAtEndOfFile(copy)
    }

    function captureComponentByUuidRegex(uuid) {
        // captures lines with start and end uuid tags, as well as those between and pre- and post-line breaks
        return new RegExp("(\\s.*start_"+ uuid +"[\\s\\S]*end_"+ uuid +"\\s)")
    }

    /*
        Given a <string>, find start and end tags for <uuid>, within those tags find the first
        instance of <prop> and replace its value with <value>
    */
    function replaceObjectPropertyValueInString (uuid, prop, value, string = fileContents) {
        // total regex: (start_42e89[\\s\\S]*?yRows\\s*:\\s*)(.*)([\\s\\S]*?end_42e89)
        // explanation: find "yRows" prop, only occurring between start and end uuid tags, replace anything following with value

        // regex notes:
        // \\s\\S is "space or not space" ,aka wildcard, since 's' flag does not work in qml
        // *? is lazy find, i.e. stop after first find, otherwise catches last match instead
        // all 3 groups are captured for replacement as it is impossible to replace only one group that is matched
        let capture1 = "(start_" + uuid + "[\\s\\S]*?" + prop + "\\s*:\\s*)"
        let capture2 = "(.*)"
        let capture3 = "([\\s\\S]*?end_" + uuid + ")"
        let regex = new RegExp(capture1 + capture2 + capture3, "gm")
        return string.replace(regex, "$1" + value + "$3");
    }

    /*
        Given a <string>, find start and end tags for <uuid>, within those tags find the first
        instance of <prop> and return its value. Only works for one-line properties.
    */
    function getObjectPropertyValueInString(uuid, propertyName, string = fileContents) {
        let objectString = getObjectFromString(uuid, string)
        if (objectString === "") {
            return ""
        }

        propertyName = propertyName.replace(".", "\\.")
        // regex: matches line starting with whitespace before 'propertyName: ' and captures anything that follows,
        // stoping at end of line and disregarding trailing whitespace
        const regex = new RegExp("^\\s*" + propertyName + ":\\s*(.*)\\s*$","m")
        let value
        try {
            value = objectString.match(regex)[1]
        } catch (e) {
            value = ""
            console.warn("No match for " + propertyName + " found in object " + uuid +", may be malformed")
        }
        return value;
    }

    function getObjectFromString(uuid, string = fileContents) {
        let objectString
        try {
            objectString = string.match(captureComponentByUuidRegex(uuid))[0]
        } catch (e) {
            objectString = ""
            console.warn("No match for " + uuid + " found, object start/end tags may be malformed or does not exist")
        }
        return objectString;
    }

    function getId(uuid) {
        let capture1 = "start_" + uuid + "[\\s\\S]*?id:\\s*"
        let capture2 = "(.*)"
        let capture3 = "[\\s\\S]*?end_" + uuid + ""
        const regex = new RegExp(capture1 + capture2 + capture3)
        let id
        try {
            id = fileContents.match(regex)[1]
        } catch (e) {
            id = ""
            console.warn("No match for uuid '" + uuid + "' found, start/end tags may be malformed")
        }
        return id;
    }

    function getType(uuid) {
        const capture1 = "([A-Za-z0-9_]+)" // qml object type, e.g. Rectangle
        const capture2 = "\\s*{\\s*\/\/\\s*start_" + uuid
        const regex = new RegExp(capture1 + capture2)
        let type
        try {
            type = fileContents.match(regex)[1]
        } catch (e) {
            type = ""
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
}
