.import tech.strata.logger 1.0 as LoggerModule
.import "qrc:/js/navigation_control.js" as NavigationControl

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
                    platformInterface[notification_key] = Object.create(notification["payload"]);
                    //console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "data_source_handler: signalling -> notification key:", notification_key);
                } else {
                    console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Notification Error. Notification is malformed:", JSON.stringify(notification));
                }
            }
        }

        // Ignore messages from other devices, ack messages
        return
    }
    catch (e) {
        if (e instanceof SyntaxError){
            console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Notification Error. Ignoring invalid notification JSON:", payload)
        }
    }
}

// -------------------------
// Helper functions
// -------------------------
function send (command) {
    command.device_id = device_id
    console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "send: ", JSON.stringify(command));
    coreInterface.sendCommand(JSON.stringify(command))
}

function show (command) {
    console.log(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "show: ", JSON.stringify(command));
}

init()
