import QtQuick 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0

import "../"

/********************************************************************************************
    * All functions below this mark are for APIv0. 
    * This allows deprecated PI.json to function as expected
    * When the user generates again, their PI.json file be updated to APIv1
/*******************************************************************************************/

Item {
    /**
      * This function creates the model from a JSON object (used when importing a JSON file)
    **/
    function createModelFromJsonAPIv0(jsonObject) {
        let topLevelKeys = Object.keys(jsonObject); // This contains "commands" / "notifications" arrays

        finishedModel.modelAboutToBeReset()
        finishedModel.clear()

        for (let i = 0; i < topLevelKeys.length; i++) {
            const topLevelType = topLevelKeys[i]
            const arrayOfCommandsOrNotifications = jsonObject[topLevelType]
            let listOfCommandsOrNotifications = {
                "name": topLevelType, // "commands" / "notifications"
                "data": []
            }

            finishedModel.append(listOfCommandsOrNotifications)

            for (let j = 0; j < arrayOfCommandsOrNotifications.length; j++) {
                let commandsModel = finishedModel.get(i).data

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
                let payloadPropertiesArray = []

                if (payload) {
                    let payloadProperties = Object.keys(payload)
                    // sorting pi.json file so the generated files, pi.json & pi.qml, will function as intented prior to APIv1
                    payloadProperties = payloadProperties.sort(); 
                    let payloadModel = commandsModel.get(j).payload
                    for (let k = 0; k < payloadProperties.length; k++) {

                        const key = payloadProperties[k]
                        let type = getType(payload[key])
                        let payloadPropObject = Object.assign({}, templatePayload)
                        payloadPropObject["name"] = key
                        payloadPropObject["type"] = type
                        payloadPropObject["valid"] = true
                        payloadPropObject["indexSelected"] = -1

                        if (type === "int") {
                            payloadPropObject["value"] = "0"
                        } else if (type === "double") {
                            payloadPropObject["value"] = "0"
                        } else if (type === "bool") {
                            payloadPropObject["value"] = "false"
                        } else if (type === "string") {
                            payloadPropObject["value"] = ""
                        }

                        payloadModel.append(payloadPropObject)

                        let propertyArray = []
                        let propertyObject = []

                        if (type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                            generateArrayModelAPIv0(payload[key], payloadModel.get(k).array)
                        } else if (type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                            generateObjectModelAPIv0(payload[key], payloadModel.get(k).object)
                        }
                    }
                }
            }
        }
        finishedModel.modelReset()

        if (inputFilePath == currentCvcProjectJsonUrl) {
            outputFileText.text = findProjectRootDir()
        } else {
            outputFileText.text = SGUtilsCpp.parentDirectoryPath(inputFilePath)
        }
    }

    /**
      * getType called from createModelFromJsonAPIv0(); returns the sdsModel type
    **/
    function getType(item) {
        if (Array.isArray(item)) {
            return sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC
        } else if (item === "array-dynamic") {
            return sdsModel.platformInterfaceGenerator.TYPE_ARRAY_DYNAMIC
        } else if (typeof item === "object") {
            return sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC
        } else if (item === "object-dynamic") {
            return sdsModel.platformInterfaceGenerator.TYPE_OBJECT_DYNAMIC
        } else {
            return item
        }
    }

    /**
      * This function takes an Array and transforms it into an array readable by our delegates
    **/
    function generateArrayModelAPIv0(arr, parentListModel) {
        for (let i = 0; i < arr.length; i++) {
            let type = getType(arr[i])

            let obj = {"type": type, "indexSelected": -1, "array": [], "object": [], "parent": parentListModel, "value": ""}
            
            if (type === "int") {
                obj["value"] = "0"
            } else if (type === "double") {
                obj["value"] = "0"
            } else if (type === "bool") {
                obj["value"] = "false"
            }
            
            parentListModel.append(obj)

            if (type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                generateArrayModelAPIv0(arr[i].value, parentListModel.get(i).array)
            } else if (type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                generateObjectModelAPIv0(arr[i].value, parentListModel.get(i).object)
            }
        }
    }

    /**
      * This function takes an Object and transforms it into an array readable by our delegates
    **/
    function generateObjectModelAPIv0(object, parentListModel) {
        let keys = Object.keys(object)
        for (let i = 0; i < keys.length; i++) {
            const key = keys[i]
            let type = getType(object[key])
            
            let obj = {"type": type, "indexSelected": -1, "array": [], "object": [], "parent": parentListModel, "value": ""}
            
            if (type === "int") {
                obj["value"] = "0"
            } else if (type === "double") {
                obj["value"] = "0"
            } else if (type === "bool") {
                obj["value"] = "false"
            }
            
            parentListModel.append(obj)

            if (type === sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC) {
                generateArrayModelAPIv0(arr[i].value, parentListModel.get(i).array)
            } else if (type === sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC) {
                generateObjectModelAPIv0(arr[i].value, parentListModel.get(i).object)
            }
        }
    }
}