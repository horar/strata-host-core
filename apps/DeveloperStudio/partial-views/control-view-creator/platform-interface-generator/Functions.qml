/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0

import "../"

QtObject {
    // All deprecated functions needed for PIG
    property DeprecatedFunctions deprecatedFunctions: DeprecatedFunctions { }

    // Array containing JavaScript & QML keywords.
    // Used to ensure users do not use a keyword in their naming convention
    readonly property var jsReserved: ["abstract","arguments","await","bool","boolean","break",
        "byte","case","catch","char","class","const","continue","debugger","default","delete",
        "do","double","else","enum","enumeration","eval","export","extends","false","final","finally",
        "float","for","function","get","goto","if","int","implements","import","in","instanceof",
        "int","interface","let","list","long","native","new","null","package","private","protected","public",
        "real","return","set","short","static","string","super","switch","synchronized","this","throw",
        "throws","transient","true","try","typeof","url","var","void","volatile","while","with","yield"]

    // various logs for the 4 errors that can be found. Empty keys, invalid keys, JS keys, and duplicate keys
    property string errorLog: ""
    property var emptyLog: []
    property var jsLog: []
    property var duplicateLog: []
    property var regexLog: []
    property int invalidCount: 0

    /**
      * checkForAllValid checks if all fields are valid (no empty, JS, or duplicate entries)
      * Loop through each command / notification and make sure there are no invalid flags
      * And recursively go through each property using checkAllValidFlag() to ensure that there are no invalid flags
    **/
    function checkForAllValid() {
        // reset logs for each validation check
        errorLog = ""
        emptyLog = []
        jsLog = []
        duplicateLog = []
        regexLog = []
        let allValid = true

        for (let i = 0; i < finishedModel.count; i++) {
            let commands = finishedModel.get(i).data
            if (!checkAllValidFlag(commands)) {
                allValid = false
            }
            for (let k = 0; k < commands.count; k++) {
                let payload = commands.get(k).payload
                if (!checkAllValidFlag(payload)) {
                    allValid = false
                }
            }
        }

        // Update errorLog depending on the types of errors found from recursive checks
        if (emptyLog.length > 0) {
            errorLog += emptyLog.length + " Empty key name(s) found\n"
        }
        if (jsLog.length > 0) {
            errorLog += "JavaScript keyword(s) '" + jsLog + "' found\n"
        }
        if (duplicateLog.length > 0) {
            errorLog += "Duplicate key name(s) '" + duplicateLog + "' found\n"
        }
        if (regexLog.length > 0) {
            errorLog += "Invalid syntax with key name(s) '" + regexLog + "' found\n"
        }

        if (allValid) {
            invalidCount = 0
        }

        return allValid
    }

    /**
      * checkAllValidFlag begins recursive checking of the valid property and updates respective logs
      * deletion is false by default, if set to true, this means the model is being removed.
      * invalid count must be decremented if needed, and the model should be cleared.
    **/
    function checkAllValidFlag(payload, deletion = false) {
        if (!payload) {
            return true
        }

        let allValid = true

        for (let i = 0; i < payload.count; i++) {
            let item = payload.get(i)
            if (!item.valid) {
                if (deletion) {
                    invalidCount--
                } else if (!item.name) {
                    emptyLog.push(i)
                } else if (item.keyword && !jsLog.includes(item.name)) {
                    jsLog.push(item.name)
                } else if (item.duplicate && !duplicateLog.includes(item.name)) { // call includes() to ensure the log only states each duplicate once
                    duplicateLog.push(item.name)
                } else if (!item.valid && !regexLog.includes(item.name) && !item.duplicate && !item.keyword) { // if invalid, and other flags are not set, the regex failed to pass
                    regexLog.push(item.name)
                }
                
                allValid = false
            }
            if (!checkAllValidArrayObject(item, deletion)) { // returns true if not an array/object
                allValid = false
            }
        }

        if (deletion) {
            payload.clear()
        }
        return allValid
    }

    /**
      * checkForValidArrayObject checks if an array/object is valid, and recursively checks its children
    **/
    function checkAllValidArrayObject(model, deletion = false) {
        let staticArray = sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC
        let staticObject = sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC
        let allValid = true

        if (model.type === staticArray) {
            for (let i = 0; i < model.array.count; i++) { // loop to check each array element
                if (!checkAllValidArrayObject(model.array.get(i), deletion)) {
                    allValid = false
                }
            }
        } else if (model.type === staticObject) {
            if (!checkAllValidFlag(model.object, deletion)) {
                allValid = false
            }
        }
        return allValid
    }

    /**
      * checkForKeyword checks if the key name is a JS keyword and sets a flag
    **/
    function checkForKeyword(payload, index) {
        if (jsReserved.includes(payload.get(index).name)) {
            payload.setProperty(index, "keyword", true)
            return false
        }

        payload.setProperty(index, "keyword", false)
        return true
    }

    /**
      * checkForDuplicateKey checks if the the passed index is duplicate with another, and sets a flag
      * The flag is used to minimize looping on the model.
    **/
    function checkForDuplicateKey(payload, index) {
        let valid = true

        for (let i = 0; i < payload.count; i++) {
            if (i !== index && payload.get(index).name === payload.get(i).name) {
                payload.setProperty(i, "duplicate", true)
                payload.setProperty(index, "duplicate", true)
                valid = false
            }
        }
        return valid
    }

    /**
      * checkForValidKey checks if a particular passed index is totally valid
      * Also updates duplicates when they exist or not
      * modelValid is passed to determine if the valid state changed during check
    **/
    function checkForValidKey(payload, index, modelValid) {
        let valid = true
        let changed = false

        // uses else if structure for checks
        // this creates a hierarchy for errors and avoids running checks unnecessarily
        if (!payload.get(index).name) {
            valid = false
        } else if (!checkForKeyword(payload, index)) {
            valid = false
        } else if (!checkForDuplicateKey(payload, index)) {
            changed = true
            valid = false
        } else if (payload.get(index).duplicate) { // if this index is valid, but was a duplicate prior
            changed = true
            payload.setProperty(index, "duplicate", false)
        }

        // invalidCount is incremented or decremented depending on the change
        if (!valid && modelValid) {
            invalidCount++
        } else if (valid && !modelValid) {
            invalidCount--
        }

        payload.setProperty(index, "valid", valid) // valid is true unless it fails one of the above checks

        // only checks for duplicates if a duplicate was involved with this index
        if (changed === true || payload.get(index).duplicate) {
            loopOverDuplicates(payload, index)
        }
        return valid
    }

    /**
      * loopOverDuplicates will only check the indices that are duplicates; optimized checks
    **/
    function loopOverDuplicates(payload, index) {
        for (let i = 0; i < payload.count; i++) {
            let indexValid = payload.get(i).valid
            if (payload.get(i).duplicate && i !== index) {
                if (checkForDuplicateKey(payload, i)) {
                    payload.setProperty(i, "duplicate", false)
                }
            }
            if (!payload.get(i).name || payload.get(i).keyword || payload.get(i).duplicate) {
                payload.setProperty(i, "valid", false)
            } else {
                payload.setProperty(i, "valid", true)
            }

            // invalidCount is incremented or decremented depending on the change
            if (!payload.get(i).valid && indexValid) {
                invalidCount++
            } else if (payload.get(i).valid && !indexValid) {
                invalidCount--
            }
        }
    }

    /**
      * importRegexCheck - on import, every index will be checked to ensure it follows the required syntax
    **/
    function importRegexCheck(payload, index) {
        const regExp = /^[a-z_][a-zA-Z0-9_]*/
        if (!regExp.test(payload.get(index).name)) {
            payload.setProperty(index, "valid", false)
            invalidCount++
        }
    }

    /**
      * parseCommandNotification creates the model from a JSON object and Type (used when importing a JSON file)
    **/
    function parseCommandNotification(topLevelType,jsonObject) {
        const arrayOfCommandsOrNotifications = jsonObject[topLevelType]

        let listOfCommandsOrNotifications = {
            "name": topLevelType, // "commands" / "notifications"
            "data": []
        }

        finishedModel.append(listOfCommandsOrNotifications)

        for (let j = 0; j < arrayOfCommandsOrNotifications.length; j++) {
            let commandsModel = finishedModel.get(finishedModel.count-1).data

            let cmd = arrayOfCommandsOrNotifications[j]
            let commandName
            let commandType
            let commandObject = {}

            if (topLevelType === "commands") {
                // If we are dealing with commands, then look for the "cmd" key
                commandName = cmd["cmd"]
                commandType = "cmd"
            } else {
                commandName = cmd["value"]
                commandType = "value"
            }

            commandObject["type"] = commandType
            commandObject["name"] = commandName
            commandObject["valid"] = true
            commandObject["keyword"] = false
            commandObject["duplicate"] = false
            commandObject["payload"] = []
            commandObject["editing"] = false

            commandsModel.append(commandObject)
            checkForValidKey(commandsModel, j, true)
            importRegexCheck(commandsModel, j)

            const payload = cmd.hasOwnProperty("payload") ? cmd["payload"] : null

            if (payload) {
                let payloadModel = commandsModel.get(j).payload
                for (let k = 0; k < payload.length; k++) {

                    const payloadProperty = payload[k]
                    const type = payloadProperty.type

                    let payloadPropObject = Object.assign({}, templatePayload)
                    payloadPropObject["name"] = payloadProperty.name
                    payloadPropObject["type"] = type
                    payloadPropObject["valid"] = true
                    payloadPropObject["keyword"] = false
                    payloadPropObject["duplicate"] = false
                    payloadPropObject["indexSelected"] = -1
                    if (type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC &&
                            type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                        payloadPropObject["value"] = String(payloadProperty.value)
                    }

                    payloadModel.append(payloadPropObject)
                    checkForValidKey(payloadModel, k, true)
                    importRegexCheck(payloadModel, k)

                    if (type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                        generateArrayModel(payloadProperty.value, payloadModel.get(k).array)
                    } else if (type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                        generateObjectModel(payloadProperty.value, payloadModel.get(k).object)
                    }
                }
            }
        }
    }

    /**
      * createModelFromJson parse/creates the model from a JSON object (used when importing a JSON file)
    **/
    function createModelFromJson(jsonObject) {
        finishedModel.modelAboutToBeReset()
        finishedModel.clear()
        invalidCount = 0 // resets invalid as new file is imported

        parseCommandNotification("notifications", jsonObject)
        parseCommandNotification("commands", jsonObject)

        alertToast.hide()
        alertToast.text = "Successfully imported JSON model." + (modelPopulated() ? "" : " Note: imported list of commands/notifications is empty.")
        alertToast.textColor = "white"
        alertToast.color = Theme.palette.success
        alertToast.interval = 4000
        alertToast.show()

        finishedModel.modelReset()

        if (inputFilePath == currentCvcProjectJsonUrl) {
            outputFileText.text = findProjectRootDir()
        } else {
            outputFileText.text = SGUtilsCpp.parentDirectoryPath(inputFilePath)
        }
    }

    /**
      * modelPopulated checks to see if either the commands or notifications has been populated
    **/
    function modelPopulated() {
        for (let i = 0; i < finishedModel.count; i++) {
            if (finishedModel.get(i).data.count > 0) {
                return true
            }
        }
        return false
    }

    /**
      * generateArrayModel takes an Array and transforms it into an array readable by our delegates
    **/
    function generateArrayModel(arr, parentListModel) {
        for (let i = 0; i < arr.length; i++) {
            const type = arr[i].type
            let obj = {"type": type, "indexSelected": -1, "array": [], "object": [], "parent": parentListModel, "value": ""}

            if (type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC &&
                    type !== sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                obj["value"] = String(arr[i].value)
            }

            parentListModel.append(obj)

            if (type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                generateArrayModel(arr[i].value, parentListModel.get(i).array)
            } else if (type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                generateObjectModel(arr[i].value, parentListModel.get(i).object)
            }
        }
    }

    /**
      * generateObjectModel takes an Object and transforms it into an array readable by our delegates
    **/
    function generateObjectModel(object, parentListModel) {
        for (let i = 0; i < object.length; i++) {
            const type = object[i].type
            let obj = {"name": object[i].name, "type": type, "indexSelected": -1, "valid": true, "keyword": false, "duplicate": false, "array": [], "object": [], "parent": parentListModel, "value": ""}

            if (type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC &&
                    type !== sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                obj["value"] = String(object[i].value)
            }

            parentListModel.append(obj)
            checkForValidKey(parentListModel, i, true)
            importRegexCheck(parentListModel, i)

            if (type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                generateArrayModel(object[i].value, parentListModel.get(i).array)
            } else if (type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                generateObjectModel(object[i].value, parentListModel.get(i).object)
            }
        }
    }

    /**
      * createJsonObject creates the JSON object to output
    **/
    function createJsonObject() {
        let obj = {}

        for (let i = 0; i < finishedModel.count; i++) {
            let type = finishedModel.get(i)
            let commands = []

            for(let j = 0; j < type.data.count; j++) {
                let command = type.data.get(j)
                let commandObj = {}
                commandObj[command.type] = command.name

                if (command.payload.count === 0) {
                    // don't add a payload key if the payload is empty
                    commands.push(commandObj)
                    continue
                } else {
                    commandObj["payload"] = []
                }

                for (let k = 0; k < command.payload.count; k++) {
                    let payloadProperty = command.payload.get(k)
                    let payloadObject = {
                        name: payloadProperty.name,
                        type: payloadProperty.type
                    }

                    if (payloadProperty.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                        payloadObject.value =  createJsonObjectFromModel(payloadProperty.array)
                    } else if (payloadProperty.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                        payloadObject.value = createJsonObjectFromModel(payloadProperty.object)
                    } else if (payloadProperty.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_DYNAMIC
                               || payloadProperty.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_DYNAMIC) {
                        payloadObject.value = []
                    } else {
                        payloadObject.value = getTypedValue(payloadProperty.type, payloadProperty.value)
                    }
                    commandObj["payload"].push(payloadObject)
                }
                commands.push(commandObj)
            }
            obj[type.name] = commands
        }
        return obj
    }

    /**
      * createJsonObjectFromModel creates the JSON object from the model depending on the type and returns it
    **/
    function createJsonObjectFromModel(model) {
        let outputArr = []
        for (let m = 0; m < model.count; m++) {
            let arrayElement = model.get(m)
            let object = {
                name: arrayElement.name,
                type: arrayElement.type
            }

            if (arrayElement.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                object.value =  createJsonObjectFromModel(arrayElement.array)
            } else if (arrayElement.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                object.value = createJsonObjectFromModel(arrayElement.object)
            } else if (arrayElement.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_DYNAMIC) {
                object.value = []
            } else if (arrayElement.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_DYNAMIC) {
                object.value = {}
            } else {
                object.value = getTypedValue(arrayElement.type, arrayElement.value)
            }
            outputArr.push(object)
        }
        return outputArr
    }

    /**
      * Convert string values to typed values
    **/
    function getTypedValue (type, value) {
        switch (type) {
            case "int":
            case "double":
                let textVal = Number(value)
                if (isNaN(textVal)) {
                    console.warn("Unable to parse the input value '" + value + "'")
                    textVal = 0
                }
                return textVal
            case "bool":
                if (value === "false") {
                    return false
                } else {
                    return true
                }
            default: // case "string"
                return value
        }
    }

    /**
      * generatePlatformInterface calls c++ function to generate PlatformInterface from JSON object
    **/
    function generatePlatformInterface() {
        const jsonObject = createJsonObject()
        const jsonInputFilePath = SGUtilsCpp.joinFilePath(outputFileText.text, jsonFileName)
        const result = sdsModel.platformInterfaceGenerator.generate(jsonObject, outputFileText.text)
        if (!result) {
            alertToast.text = "Generation Failed: " + sdsModel.platformInterfaceGenerator.lastError
            alertToast.textColor = "white"
            alertToast.color = Theme.palette.error
            alertToast.interval = 0
        } else if (sdsModel.platformInterfaceGenerator.lastError.length > 0) {
            alertToast.text = "Generation Succeeded, but with warnings: " + sdsModel.platformInterfaceGenerator.lastError
            alertToast.textColor = "black"
            alertToast.color = Theme.palette.warning
            alertToast.interval = 0
            SGUtilsCpp.atomicWrite(jsonInputFilePath, JSON.stringify(jsonObject, null, 4))
        } else {
            alertToast.text = "Successfully generated PlatformInterface.qml"
            alertToast.textColor = "white"
            alertToast.color = Theme.palette.success
            alertToast.interval = 4000
            SGUtilsCpp.atomicWrite(jsonInputFilePath, JSON.stringify(jsonObject, null, 4))
        }
        alertToast.show()

        unsavedChanges = false
    }

    /**
      * importValidationCheck will check if the incoming JSON file is a valid Platform Interface JSON
    **/
    function importValidationCheck(object) {
        if (!object.hasOwnProperty("commands") ||
            !object.hasOwnProperty("notifications") ||
            Object.keys(object).length !== 2) {
            // must contain only commands and notifications
            return false
        }

        const commands = object["commands"]
        const notifications = object["notifications"]

        if (!Array.isArray(commands) || !Array.isArray(notifications)) {
            return false
        }

        for (var i = 0; i < commands.length; i++) {
            const command = commands[i]
            if (!command.hasOwnProperty("cmd")) {
                return false
            }

            if (command.hasOwnProperty("payload") && !Array.isArray(command["payload"])) {
                if (typeof command["payload"] === "object") {
                    apiVersion = "APIv0"
                    return true
                }
            }

            if (!searchLevel1(command)) {
                return false
            }
        }

        for (var i = 0; i < notifications.length; i++) {
            const notification = notifications[i]
            if (!notification.hasOwnProperty("value")) {
                return false
            }

            if (!searchLevel1(notification)) {
                return false
            }
        }
        apiVersion = "APIv1"
        return true
    }

    /**
      * searchLevel1 is the first step of verifying an imported JSON file is valid or not. The API version is determined here as well.
    **/
    function searchLevel1(object) {
        if (object.hasOwnProperty("payload")) {
            if (!Array.isArray(object["payload"])) {
                return false
            }

            for (var i = 0; i < object["payload"].length; i++) {
                const payload = object["payload"][i]
                if (!payload.hasOwnProperty("type") || !payload.hasOwnProperty("value") || !payload.hasOwnProperty("name")) {
                    return false
                }
                if (payload["type"].includes("array-static") || payload["type"].includes("object-known")) {
                    for (var j = 0; j < payload["value"].length; j++) {
                        const obj = payload["value"][j]
                        if (!searchLevel2Recurse(obj)) {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }

    /**
      * searchLevel2Recurse is the next level of file verification and is recursive depending on the size of the array or object.
    **/
    function searchLevel2Recurse(object) {
        if (!object.hasOwnProperty("type") || !object.hasOwnProperty("value")) {
            return false
        }

        if (object["type"].includes("array-static") || object["type"].includes("object-known")) {
            for (var j = 0; j < object["value"].length; j++) {
                const obj = object["value"][j]
                return searchLevel2Recurse(obj)
            }
        }
        return true
    }

    /**
      * loadJsonFile read JSON file and import object
    **/
    function loadJsonFile(url) {
        if (SGUtilsCpp.isFile(url)) {
            inputFilePath = url
        } else {
            inputFilePath = SGUtilsCpp.urlToLocalFile(url)
        }

        if (!SGUtilsCpp.isValidFile(inputFilePath)) {
            console.error("Invalid JSON file: " + inputFilePath)
            return
        }

        if (!unsavedChanges) {
            const fileText = SGUtilsCpp.readTextFileContent(inputFilePath)
            try {
                const jsonObject = JSON.parse(fileText)
                if (importValidationCheck(jsonObject)) {
                    if (apiVersion === "APIv1") {
                        if (alertToast.visible) {
                            alertToast.hide()
                        }
                        createModelFromJson(jsonObject)
                    } else if (apiVersion === "APIv0") {
                        if (alertToast.visible) {
                            alertToast.hide()
                        }
                        alertToast.text = "The imported JSON file uses a deprecated API. If you 'Generate' your code will be updated to the new API."
                        alertToast.textColor = "white"
                        alertToast.color = Theme.palette.warning
                        alertToast.interval = 0
                        alertToast.show()
                        deprecatedFunctions.createModelFromJsonAPIv0(jsonObject)
                    }
                } else {
                    alertToast.text = "The JSON file is improperly formatted"
                    alertToast.textColor = "white"
                    alertToast.color = Theme.palette.error
                    alertToast.interval = 0
                    alertToast.show()
                }
            } catch (e) {
                console.error(e)
                alertToast.text = "Failed to parse input JSON file: " + e
                alertToast.textColor = "white"
                alertToast.color = Theme.palette.error
                alertToast.interval = 0
                alertToast.show()
                return
            }
        } else {
            confirmDeleteInProgress.open()
        }
    }

    /**
      * findProjectRootDir find project root directory given root Qrc file url
    **/
    function findProjectRootDir() {
        return SGUtilsCpp.parentDirectoryPath(SGUtilsCpp.urlToLocalFile(currentCvcProjectQrcUrl))
    }

    /**
      * determines the fileDialog.folder to open depending on recent and current projects
    **/
    function fileDialogFolder() {
        // checks if the user has recently opened a file and uses that path
        // then, if there projects in the recent projects model and uses that dir path
        // else, the user's home directory is opened
        let path = currentCvcProjectJsonUrl
        if (SGUtilsCpp.isValidFile(path)) {
            path = SGUtilsCpp.urlToLocalFile(path)
            path = SGUtilsCpp.parentDirectoryPath(path)
            path = SGUtilsCpp.pathToUrl(path)
            return path
        } else {
            return startContainer.openControlView.fileDialogFolder()
        }
    }
}
