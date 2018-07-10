// -------------------------
// Data Source Handler
//
// Parses and routes payload object to matching PlatformInterface property
//
function data_source_handler (payload){
    try {
        var notification = JSON.parse(payload)
        //console.log("payload: ", payload)

        if (notification.hasOwnProperty("payload")){
            var notification_key = notification.value

            for (var platform_idx = 0; platform_idx < Object.keys(platformInterface).length; platform_idx++) {
                var platform_key = Object.keys(platformInterface)[platform_idx]; // convert to string

                // match incoming notification message with installed property binding
                if (platform_key === notification_key) {
                    // PlatformInterface[name] finds Item::PlatformInterface object's property by string name
                    //console.log("notification key:", notification_key, ", platform_key: ", platform_key);
                    platformInterface[platform_key] = Object.create(notification["payload"]);
                }

            }
        } else {
            console.log("Notification Error. Payload is corrupted");
        }
    }
    catch (e) {
        if (e instanceof SyntaxError){
            console.log("Motor Platfrom Notification Error. Notification JSON is invalid, ignoring")
        }
    }
}

// -------------------------
// Helper functions
//
function send (command) {
    console.log("send: ", JSON.stringify(command));
    coreInterface.sendCommand(JSON.stringify(command))
}

function show (command) {
    console.log("show: ", JSON.stringify(command));
}
