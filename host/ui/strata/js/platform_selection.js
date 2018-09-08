.pragma library
.import "qrc:/js/navigation_control.js" as NavigationControl

var isInitialized = false
var platformListModel
var coreInterface
var documentManager

function initialize (newModel, newCoreInterface, newDocumentManager) {
    isInitialized = true
    platformListModel = newModel
    coreInterface = newCoreInterface
    documentManager = newDocumentManager
}

function populatePlatforms(platform_list_json) {
    var autoSelectEnabled = true
    var autoSelectedPlatform = null
    var autoSelectedIndex = 0

    // Map out UUID->platform name
    // Lookup table
    //  platform_id -> local qml directory holding interface
    //to enable a new model of board UI to be shown, this list has to be edited
    //the other half of the map will be the name of the directory that will be used to show the initial screen (e.g. usb-pd/Control.qml)


    var uuid_map = {
        "P2.2017.1.1" : "usb-pd",
        "P2.2018.1.1" : "bubu",
        "motorvortex1" : "motor-vortex",
        "SEC.2018.004.1.1" : "usb-pd-multiport",
        "SEC.2018.004.1.0" : "usb-pd-multiport",    //david ralley's new board
        "P2.2018.0.0.0" : "usb-pd-multiport",       //uninitialized board
        "SEC.2017.038.0.0": "usb-pd-multiport",
        "SEC.2018.0.0.0" : "logic-gate"
    }

    platformListModel.clear()
    platformListModel.append({ "text" : "Select a Platform..." })
    // Parse JSON
    try {
        console.log("populatePlaforms: ", platform_list_json)
        var platform_list = JSON.parse(platform_list_json)
        console.log("number of platforms in list:",platform_list.list.length);

        for (var i = 0; i < platform_list.list.length; i ++){

            //extract the platform identifier (without firmware or uuid) for matching
            var pattern = new RegExp('^[A-Z0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+');
            var theString = platform_list.list[i].uuid;
            var platformType = String(theString).match(pattern);
//            console.log("looking at platform ",platform_list.list[i].uuid);
//            if (platformType){
//                console.log("platform name matched pattern:",platformType);
//            }

            // Extract platform verbose name and UUID
            var platform_info = {
                "text" : platform_list.list[i].verbose,
                "verbose" : platform_list.list[i].verbose,
                "name" : uuid_map[platformType],    //this will return the name used to bring up the UI
                "connection" : platform_list.list[i].connection,
                "uuid"  :   platform_list.list[i].uuid
            }

            // Append text to state the type of Connection
            if(platform_info.connection === "remote"){
                platform_info.text += " (Remote)"
            }
            else if (platform_info.connection === "view"){
                platform_info.text += " (View-only)"
            }
            else if (platform_info.connection === "connected"){
                platform_info.text += " (Connected)"
                // copy "connected" platform; Note: this will auto select the last listed "connected" platform
                console.log("autoconnect =",platform_info.name);
                autoSelectedPlatform = platform_info
                autoSelectedIndex = i+1 //+1 due to default "select a platform entry"
            } else {
                console.log("unknown connection type for ",platform_info.text," ",platform_info.connection);
            }

            // Add to the model
            platformListModel.append(platform_info)
        }
    }
    catch(err) {
        console.log("CoreInterface error:", err.toString())
        platformListModel.clear()
        platformListModel.append({ "text" : "Select a Platform..." })
        platformListModel.append({ "text" : "No Platforms Available" } )
    }

    // Auto Select "connected" platform
    if ( autoSelectEnabled && autoSelectedPlatform) {
        console.log("Auto selecting connected platform: ", autoSelectedPlatform.name)
        sendSelection( autoSelectedIndex )


        // For Demo purposes only; Immediately go to control
//        var data = { platform_name: autoSelectedPlatform.name}
//        coreInterface.sendSelectedPlatform(autoSelectedPlatform.uuid, autoSelectedPlatform.connection)
//        NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT,data)
//        platformListModel.currentIndex = autoSelectedIndex
//        platformListModel.selectedConnection = "connected"
    }
    else if ( autoSelectEnabled == false){
        console.log("Auto selecting disabled.")
    }
}

function sendSelection (currentIndex) {
    platformListModel.currentIndex = currentIndex
    platformListModel.selectedConnection = ""
    /*
        Determine action depending on what type of 'connection' is used
    */
    NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, null)
    var disconnect_json = {"hcs::cmd":"disconnect_platform"}
    console.log("disonnecting the platform")
    coreInterface.sendCommand(JSON.stringify(disconnect_json))

    var connection = platformListModel.get(currentIndex).connection
    var data = { platform_name: platformListModel.get(currentIndex).name}

    // Clear all documents for contents
    documentManager.clearDocumentSets();

    if (connection === "view") {
        platformListModel.selectedConnection = "view"
        // Go offline-mode
        NavigationControl.updateState(NavigationControl.events.OFFLINE_MODE_EVENT, data)
        coreInterface.sendSelectedPlatform(platformListModel.get(currentIndex).uuid,platformListModel.get(currentIndex).connection)
        if (!NavigationControl.flipable_parent_.flipped) {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
    else if (connection === "connected"){
        platformListModel.selectedConnection = "connected"
        NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT,data)
        coreInterface.sendSelectedPlatform(platformListModel.get(currentIndex).uuid,platformListModel.get(currentIndex).connection)
        if (NavigationControl.flipable_parent_.flipped) {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
    else if (connection === "remote"){
        platformListModel.selectedConnection = "remote"
        NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT,data)
        // Call coreinterface connect()
        coreInterface.sendSelectedPlatform(platformListModel.get(currentIndex).uuid,platformListModel.get(currentIndex).connection)
        if (NavigationControl.flipable_parent_.flipped) {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    } else {
        if (NavigationControl.flipable_parent_.flipped) {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
}
