/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0

import "../"

QtObject {
    // All deprecated functions needed for PIG
    property DeprecatedFunctions deprecatedFunctions: DeprecatedFunctions { }
    
    /**
      * checkForAllValid checks if all fields are valid (no empty or duplicate entries)
    **/
    function checkForAllValid() {
        // First loop through each command / notification and make sure there are no duplicate commands / notification names
        // Then recursively go through each property to ensure that there are no duplicate object property names
        for (let i = 0; i < finishedModel.count; i++) {
            let commands = finishedModel.get(i).data
            for (let k = 0; k < commands.count; k++) {
                let valid = true
                if (commands.get(k).name === "") {
                    commands.setProperty(k, "valid", false)
                    console.error("Empty", i === 0 ? "command" : "notification", "name at index", k)
                    return false
                }

                for (let j = 0; j < commands.count; j++) {
                    if (j !== k && commands.get(k).name === commands.get(j).name) {
                        commands.setProperty(j, "valid", false)
                        console.error("Duplicate", i === 0 ? "command" : "notification", "'" + commands.get(j).name + "' found")
                        return false
                    }
                }

                if (!checkForDuplicatePropertyNames(i, k, true)) {
                    return false
                }
            }
        }
        return true
    }

    /**
      * checkForDuplicatePropertyNames checks for valid and duplicate property names in a command / notification
    **/
    function checkForDuplicatePropertyNames(typeIndex, commandIndex, shortCircuit = false) {
        let commands = finishedModel.get(typeIndex).data
        let payload = commands.get(commandIndex).payload

        let allValid = true
        for (let i = 0; i < payload.count; i++) {
            let valid = true

            if (payload.get(i).name === "") {
                payload.setProperty(i, "valid", false)
                allValid = false
                if (shortCircuit) {
                    console.error("Empty payload name at index", i)
                    return false
                }

                continue
            }

            for (let j = 0; j < payload.count; j++) {
                if (j !== i && payload.get(i).name === payload.get(j).name) {
                    valid = false
                    allValid = false
                    if (shortCircuit) {
                        console.error("Duplicate payload key '" + payload.get(j).name + "' found")
                        return false
                    }
                    break
                }
            }

            // If the payload property is an object, check to make sure there are no duplicate keys in that object
            if (valid && payload.get(i).type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                let objectPropertiesModel = payload.get(i).object
                for (let k = 0; k < objectPropertiesModel.count; k++) {
                    let tmpValid = checkForDuplicateObjectPropertyNames(objectPropertiesModel, k)
                    if (!tmpValid) {
                        allValid = false
                        objectPropertiesModel.setProperty(k, "valid", false)

                        if (shortCircuit) {
                            console.error("Duplicate or empty property key in payload property '" + payload.get(i).name + "' found")
                            return false
                        }
                    }
                }
            } else if (valid && payload.get(i).type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                if (!checkForArrayValid(payload.get(i).array)) {
                    valid = false
                    allValid = false

                    console.error("Duplicate or empty property key in payload property '" + payload.get(i).name + "' found")

                    if (shortCircuit) {
                        return false
                    }
                }
            }

            payload.setProperty(i, "valid", valid)
        }
        return allValid
    }

    /**
      * checkForDuplicateObjectPropertyNames checks for duplicate keys in a given payload property that is of 'object' type
    **/
    function checkForDuplicateObjectPropertyNames(objectPropertiesModel, index) {
        let key = objectPropertiesModel.get(index).name

        if (key === "") {
            return false
        }

        for (let i = 0; i < objectPropertiesModel.count; i++) {
            if (i !== index) {
                let item = objectPropertiesModel.get(i)
                if (item.name === key) {
                    return false
                }
            }
        }

        // Now recurse through any children that are objects or arrays
        for (let j = 0; j < objectPropertiesModel.count; j++) {
            let item = objectPropertiesModel.get(j)

            if (item.type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                for (let k = 0; k < item.array.count; k++) {
                    if (item.array.get(k).type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                        if (!checkForArrayValid(item.array.get(k).array)) {
                            return false
                        }
                    } else if (item.array.get(k).type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                        let subObject = item.array.get(k).object
                        for (let m = 0; m < subObject.count; m++) {
                            if (!checkForDuplicateObjectPropertyNames(subObject, m)) {
                                return false
                            }
                        }
                    }
                }
            } else if (item.type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                for (let k = 0; k < item.object.count; k++) {
                    if (item.object.get(k).type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                        if (!checkForArrayValid(item.object.get(k).array)) {
                            return false
                        }
                    } else if (item.object.get(k).type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                        let subObject = item.object.get(k).object
                        for (let m = 0; m < subObject.count; m++) {
                            if (!checkForDuplicateObjectPropertyNames(subObject, m)) {
                                return false
                            }
                        }
                    }
                }
            }
        }

        return true
    }

    /**
      * checkForArrayValid checks if array/object is valid
    **/
    function checkForArrayValid(arrayModel) {
        for (let i = 0; i < arrayModel.count; i++) {
            if (arrayModel.get(i).type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                if (!checkForArrayValid(arrayModel.get(i).array)) {
                    return false
                }
            } else if (arrayModel.get(i).type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                let subObject = arrayModel.get(i).object
                for (let m = 0; m < subObject.count; m++) {
                    if (!checkForDuplicateObjectPropertyNames(subObject, m)) {
                        return false
                    }
                }
            }
        }

        return true
    }

    /**
      * checkForDuplicateIds checks for duplicate ids in either the "commands" or "notifications" array. Note that there can be duplicates between the commands and notifications.
      * E.g.: Commands can have a cmd with name "test" and so can the notifications
    **/
    function checkForDuplicateIds(index) {
        let commands = finishedModel.get(index).data
        let allValid = true
        for (let i = 0; i < commands.count; i++) {
            let valid = true
            for (let j = 0; j < commands.count; j++) {
                if (j !== i && commands.get(i).name === commands.get(j).name) {
                    valid = false
                    allValid = false
                    break
                }
            }
            finishedModel.get(index).data.setProperty(i, "valid", valid)
        }

        return allValid
    }

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
            commandObject["payload"] = []
            commandObject["editing"] = false

            commandsModel.append(commandObject)

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
                    payloadPropObject["indexSelected"] = -1
                    if (type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC &&
                            type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                        payloadPropObject["value"] = String(payloadProperty.value)
                    }

                    payloadModel.append(payloadPropObject)

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
      * createModelFromJson creates the model from a JSON object (used when importing a JSON file)
    **/
    function createModelFromJson(jsonObject) {
        let topLevelKeys = Object.keys(jsonObject) // This contains "commands" / "notifications" arrays

        finishedModel.modelAboutToBeReset()
        finishedModel.clear()

        parseCommandNotification("notifications", jsonObject)
        parseCommandNotification("commands", jsonObject)

        alertToast.hide()
        alertToast.text = "Successfully imported JSON model." + (modelPopulated() ? "" : " Note: imported list of commands/notifications is empty.")
        alertToast.textColor = "white"
        alertToast.color = "green"
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
            let obj = {"name": object[i].name, "type": type, "indexSelected": -1, "valid": true, "array": [], "object": [], "parent": parentListModel, "value": ""}

            if (type !== sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC &&
                    type !== sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                obj["value"] = String(object[i].value)
            }

            parentListModel.append(obj)

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
            return parseInt(value)
        case "double":
            return parseFloat(value)
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
            alertToast.color = "#D10000"
            alertToast.interval = 0
        } else if (sdsModel.platformInterfaceGenerator.lastError.length > 0) {
            alertToast.text = "Generation Succeeded, but with warnings: " + sdsModel.platformInterfaceGenerator.lastError
            alertToast.textColor = "black"
            alertToast.color = "#DFDF43"
            alertToast.interval = 0
            SGUtilsCpp.atomicWrite(jsonInputFilePath, JSON.stringify(jsonObject, null, 4))
        } else {
            alertToast.text = "Successfully generated PlatformInterface.qml"
            alertToast.textColor = "white"
            alertToast.color = "green"
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
                        alertToast.color = "goldenrod"
                        alertToast.interval = 0
                        alertToast.show()
                        deprecatedFunctions.createModelFromJsonAPIv0(jsonObject)
                    }
                } else {
                    alertToast.text = "The JSON file is improperly formatted"
                    alertToast.textColor = "white"
                    alertToast.color = "#D10000"
                    alertToast.interval = 0
                    alertToast.show()
                }
            } catch (e) {
                console.error(e)
                alertToast.text = "Failed to parse input JSON file: " + e
                alertToast.textColor = "white"
                alertToast.color = "#D10000"
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
