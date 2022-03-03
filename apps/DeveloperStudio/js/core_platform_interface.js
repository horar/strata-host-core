/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.import tech.strata.logger 1.0 as LoggerModule
.import "qrc:/js/navigation_control.js" as NavigationControl
.import QtQml 2.12 as QtQml
// Use caution when updating this file; older platform control_views rely on the original API

var device_id

function init() {
    device_id = NavigationControl.context.device_id
}

// -------------------------
// Data Source Handler
//
// Parses and routes payload object to matching PlatformInterface property
//
// Payload example:
// {
//     "device_id": "s01234567",
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
                if (notification.hasOwnProperty("value")) {
                    var notification_key = notification.value
                    if (platformInterface.apiVersion && platformInterface.apiVersion > 1) {

                        if (!platformInterface["notifications"].hasOwnProperty(notification_key)) {
                            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "PlatformInterface.qml doesn't recognize the notification '" + notification_key + "'. Ignoring...")
                            return;
                        }

                        // before iterating on the payload, confirm it exists, and is an object
                        if (notification.hasOwnProperty("payload") && typeof notification["payload"] === 'object' && notification["payload"] !== null){
                            // loop through payload keys and set platformInterface[notification_key][payload_key] = payload_value
                            for (const key of Object.keys(notification["payload"])) {
                                if (!platformInterface["notifications"][notification_key].hasOwnProperty(key)) {
                                    console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Attempted to assign invalid property '", key, "' to platform interface notification '" + notification_key + "'")
                                    continue;
                                }

                                const payloadObj = notification["payload"][key]
                                let platformInterfaceObj = platformInterface["notifications"][notification_key][key]

                                if (typeof payloadObj === "object" && isQtObject(platformInterfaceObj)) {
                                    // if payload is an object or array, and platform interface object is a QtObject, recurse
                                    setNotification(platformInterfaceObj, payloadObj);
                                } else {
                                    // directly assign value; either basic types or JS objects/arrays
                                    platformInterface["notifications"][notification_key][key] = payloadObj;
                                }
                            }
                        }

                        // Emit the notificationFinished signal
                        platformInterface["notifications"][notification_key].notificationFinished()
                    } else {
                        // Notifications using old API must include "payload" key
                        if (notification.hasOwnProperty("payload")){
                            platformInterface[notification_key] = Object.create(notification["payload"]);
                        } else {
                            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Notification Error. Notification is malformed:", JSON.stringify(notification));
                        }
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
        // console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "send: ", JSON.stringify(command));
        coreInterface.sendNotification("platform_message", { "device_id": device_id, "message": JSON.stringify(command) })
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
function setNotification(platformInterfaceObject, payloadValue) {
    let type
    let iterable

    if (Array.isArray(payloadValue)) {
        type = "array"
        iterable = payloadValue
    } else if (typeof payloadValue === "object") {
        type = "object"
        iterable = Object.keys(payloadValue)
    } else {
        platformInterfaceObject = payloadValue
        return
    }

    for (let i = 0; i < iterable.length; i++) {
        let key
        let index

        if (type === "array") {
            key = `index_${i}`;
            index = i
        } else {
            key = iterable[i];
            index = key
        }

        if (!platformInterfaceObject.hasOwnProperty(key)) {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Attempted to assign invalid index:", index, "to array: '" + key + "'")
            continue;
        }

        if (isQtObject(platformInterfaceObject[key])) {
            setNotification(platformInterfaceObject[key], payloadValue[index])
        } else {
            platformInterfaceObject[key] = payloadValue[index]
        }
    }

}

function isQtObject(obj) {
    try {
        let result = (obj instanceof QtQml.QtObject);
        return result;
    } catch (e) {
        return false;
    }
}

init()
