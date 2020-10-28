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
                            let obj = notification["payload"][key];
                            if (Array.isArray(obj)) {
                                // Loop through each value in array and set according property in platforminterface
                                for (let i = 0; i < obj.length; i++) {
                                    let idxName = `${key}_${i}`;
                                    platformInterface["notifications"][notification_key][key][idxName] = obj[i];
                                }
                            } else {
                                platformInterface["notifications"][notification_key][key] = notification["payload"][key]
                            }
                        }
                        
                    } else {
                        platformInterface[notification_key] = Object.create(notification["payload"]);
                    }
                    //console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "data_source_handler: signalling -> notification key:", notification_key);
                } else {
                    console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Notification Error. Notification is malformed:", JSON.stringify(notification));
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

init()
