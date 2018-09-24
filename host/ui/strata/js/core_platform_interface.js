// -------------------------
// Data Source Handler
//
// Parses and routes payload object to matching PlatformInterface property
//
function data_source_handler (payload) {
    try {
        var notification = JSON.parse(payload)
        //console.log("payload: ", payload)

        if (notification.hasOwnProperty("payload")) {
            var notification_key = notification.value
            platformInterface[notification_key] = Object.create(notification["payload"]);

            //console.log("data_source_handler: signalling -> notification key:", notification_key);

        }
        else {
            console.log("Notification Error. Payload is corrupted");
        }
    }
    catch (e) {
        if (e instanceof SyntaxError){
            console.log("Multiport Notification Error. Notification JSON is invalid, ignoring")
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
