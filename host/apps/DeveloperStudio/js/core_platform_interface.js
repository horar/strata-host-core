.import tech.strata.logger 1.0 as LoggerModule
.import "qrc:/js/navigation_control.js" as NavigationControl

// Use caution when updating this file; older platform control_views rely on the original API

var device_id

function init() {
    device_id = parseInt(NavigationControl.context.device_id)
}

// -------------------------
// Data Source Handler
//
// Parses and routes payload object to matching PlatformInterface property
//
// Payload example:
// {
//     "device_id": -1088988335,
//     "message":"{\"notification\":{\"value\":\"sensor_value\",\"payload\":{\"value\":\"touch\"}}}"
// }

function data_source_handler (payload) {
    try {
        var deviceWrapper= JSON.parse(payload)
        //console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "payload: ", payload)
        if (deviceWrapper.device_id === device_id) {
            let message = JSON.parse(deviceWrapper.message)

            if (message.hasOwnProperty("notification")) {
                let notification = message.notification
                if (notification.hasOwnProperty("value") && notification.hasOwnProperty("payload")) {
                    var notification_key = notification.value
                    if (platformInterface.apiVersion && platformInterface.apiVersion > 1) {
                        // loop through payload keys and set platformInterface[notification_key][payload_key] = payload_value
                        for (const key of Object.keys(notification["payload"])) {
                            let obj = notification["payload"][key]
                            if (!platformInterface["notifications"][notification_key][key]) {
                                console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Attempted to assign invalid property", key, "to platform interface notification '" + notification_key + "'")
                                continue;
                            }

                            if (Array.isArray(obj)) {
                                if (Array.isArray(platformInterface["notifications"][notification_key][key])) {
                                    // Property is a dynamic array
                                    platformInterface["notifications"][notification_key][key] = obj;
                                } else {
                                    if (isQtObject(platformInterface["notifications"][notification_key][key])) {
                                        setNotification(platformInterface["notifications"][notification_key], key, obj);
                                    }
                                }
                            } else if (typeof obj === "object") {
                                if (isQtObject(platformInterface["notifications"][notification_key][key])) {
                                    setNotification(platformInterface["notifications"][notification_key], key, obj);
                                } else {
                                    platformInterface["notifications"][notification_key][key] = obj;
                                }
                            } else {
                                platformInterface["notifications"][notification_key][key] = obj;
                            }
                        }
                    } else {
                        platformInterface[notification_key] = Object.create(notification["payload"]);
                    }
                    //console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "data_source_handler: signalling -> notification key:", notification_key);
                } else {
                    console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Notification Error. Notification is malformed:", JSON.stringify(notification));
                }
            } else if (message.hasOwnProperty("payload") && message.hasOwnProperty("ack")) {
                // We are receiving negative acknowledgement
                let payloadPart = message.payload;
                if (payloadPart.hasOwnProperty("return_value") && payloadPart.return_value === false) {
                    if (payloadPart.hasOwnProperty("return_string")) {
                        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Notification Error. Ack returned '" + payloadPart.return_string + "' when receiving command: '" + message.ack + "'");
                    } else {
                        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Notification Error. Ack returned false when receiving command '" + message.ack + "'");
                    }
                }
            }
        }

        // Ignore messages from other devices, ack messages
        return
    }
    catch (e) {
        if (e instanceof SyntaxError){
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Notification Error. Ignoring invalid notification JSON:", payload)
        }
    }
}

// -------------------------
// Helper functions
// -------------------------
function send (command) {
    if (device_id) {
        command.device_id = device_id
        console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "send: ", JSON.stringify(command));
        coreInterface.sendCommand(JSON.stringify(command))
    }
    else {
        console.warn(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Device_id not set, command not sent: ", JSON.stringify(command));
    }
}

function show (command) {
    console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "show: ", JSON.stringify(command));
}

function injectDebugNotification(notification) {
    let message = {
        "notification": notification
    }
    let wrapper = {
        "device_id": device_id,
        "message": JSON.stringify(message)
    }
    data_source_handler(JSON.stringify(wrapper))
}

/*
  Recursively set the notification property for QtObjects
 */
function setNotification(parentObject, key, payloadValue) {
    if (Array.isArray(payloadValue)) {
        for (let i = 0; i < payloadValue.length; i++) {
            let idxName = `index_${i}`;

            if (Array.isArray(parentObject[key][idxName])) {
                parentObject[key][idxName] = payloadValue[i];
                break;
            } else if (typeof parentObject[key][idxName] === "object") {
                if (isQtObject(parentObject[key][idxName])) {
                    setNotification(parentObject[key], idxName, payloadValue[i])
                } else {
                    parentObject[key][idxName] = payloadValue[i]
                }
            } else {
                parentObject[key][idxName] = payloadValue[i]
            }
        }
    } else if (typeof payloadValue === "object") {
        let payloadValueKeys = Object.keys(payloadValue);
        for (let i = 0; i < payloadValueKeys.length; i++) {
            setNotification(parentObject[key], payloadValueKeys[i], payloadValue[payloadValueKeys[i]])
        }
    } else {
        parentObject[key] = payloadValue
    }
}

function isQtObject(obj) {
    let parsedObject = JSON.parse(JSON.stringify(obj));
    if (parsedObject.hasOwnProperty("objectName") && (parsedObject["objectName"] === "array" || parsedObject["objectName"] === "object")) {
        return true
    }
    return false
}

init()
