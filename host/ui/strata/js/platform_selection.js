.pragma library
.import "qrc:/js/navigation_control.js" as NavigationControl

var isInitialized = false
var platformListModel
var coreInterface
var documentManager
var selectedPlatform = { "uuid":"", "verbose":"", "connection":"" }

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
    // platform_id -> local qml directory holding interface
    //to enable a new model of board UI to be shown, this list has to be edited
    //the other half of the map will be the name of the directory that will be used to show the initial screen (e.g. usb-pd/Control.qml)

    var uuid_map = {
        "P2.2017.1.1.0" : "usb-pd",             //original version
        "P2.2018.1.1.0" : "bubu",
        "SEC.2017.004.2.0" : "motor-vortex",
        "SEC.2018.004.0.1" : "usb-pd",
        "SEC.2018.004.1.1" : "usb-pd",
        "SEC.2018.004.1.2" : "usb-pd",
        "P2.2018.0.0.0" : "usb-pd-multiport",       //uninitialized board
        "SEC.2017.038.0.0": "usb-pd-multiport",
        "SEC.2017.038.0.1": "usb-pd-multiport",
        "SEC.2018.018.0.0" : "logic-gate", // Alpha Board
        "SEC.2018.018.1.0" : "logic-gate", // Beta Board
        "SEC.2018.001.0.0": "usb-hub"
    }

    platformListModel.clear()
    platformListModel.currentIndex = -1
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
            //console.log("the UUID String=",theString)
            if(theString !== null){
                if(pattern.test(theString)) {
                    var platformType = String(theString).match(pattern)[0]
                }
                else{   //If there is invalid uuid just pass the iteration.
                    console.log("platform uuid does not match the pattern");
                    continue
                }
            }
            else{   //If the uuid is null just pass the iteration.
                console.log("platform uuid string is null");
                continue
            }
            console.log("looking at platform ",platform_list.list[i].uuid);

//            if (platformType){
//                console.log("platform name matched pattern:",platformType);
//            }

            // Extract platform verbose name and UUID
            var platform_info = {
                "text" : platform_list.list[i].verbose,
                "verbose" : platform_list.list[i].verbose,
                "name" : uuid_map.hasOwnProperty(platformType) ? uuid_map[platformType] : "unknown-platform",    //this will return the name used to bring up the UI
                "connection" : platform_list.list[i].connection,
                "uuid"  :   platform_list.list[i].uuid
            }

//            console.log("platform list item:",i);
//            console.log("text:",platform_info.text);
//            console.log("verbose:",platform_info.verbose);
//            console.log("platform type:",platformType);
//            console.log("name:",platform_info.name);
//            console.log("connection:",platform_info.connection);
//            console.log("uuid:",platform_info.uuid);

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

            // If the previously selected platform is still available, set the currentIndex to match
            if (selectedPlatform.uuid === platform_info.uuid &&
                    selectedPlatform.verbose === platform_info.verbose &&
                    selectedPlatform.connection === platform_info.connection) {
                platformListModel.currentIndex = (platformListModel.count - 1)
            }

        }
    }
    catch(err) {
        console.log("CoreInterface error:", err.toString())
        platformListModel.clear()
        platformListModel.append({ "text" : "Select a Platform..." })
        platformListModel.append({ "text" : "No Platforms Available" } )
    }

    // If no previous SelectedPlatform matched, reset to default state
    if (platformListModel.currentIndex === -1) {
        sendSelection(0)
    }

    // Auto Select newly connected platform
    if ( autoSelectEnabled && autoSelectedPlatform) {
        console.log("Auto selecting connected platform: ", autoSelectedPlatform.name)
        sendSelection( autoSelectedIndex )
    }
}

function sendSelection (currentIndex) {
    platformListModel.currentIndex = currentIndex
    platformListModel.selectedConnection = ""
    selectedPlatform.uuid = platformListModel.get(currentIndex).uuid
    selectedPlatform.verbose = platformListModel.get(currentIndex).verbose
    selectedPlatform.connection = platformListModel.get(currentIndex).connection

    /*
        Determine action depending on what type of 'connection' is used
    */
    NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, null)
    var disconnect_json = {"hcs::cmd":"disconnect_platform"}
    console.log("disonnecting the platform")
    coreInterface.sendCommand(JSON.stringify(disconnect_json))

    var connection = platformListModel.get(currentIndex).connection
    var data = { platform_name: platformListModel.get(currentIndex).name}
    console.log("setting data platform_name to",data.platform_name);

    // Clear all documents for contents
    documentManager.clearDocumentSets();

    if (connection === "view") {
        platformListModel.selectedConnection = "view"
        console.log("menu item selected for platform:",platformListModel.get(currentIndex).uuid, platformListModel.get(currentIndex).connection);
        // Go offline-mode
        NavigationControl.updateState(NavigationControl.events.OFFLINE_MODE_EVENT, data)
        coreInterface.sendSelectedPlatform(platformListModel.get(currentIndex).uuid, platformListModel.get(currentIndex).connection)
        if (!NavigationControl.flipable_parent_.flipped) {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
    else if (connection === "connected"){
        platformListModel.selectedConnection = "connected"
        coreInterface.sendSelectedPlatform(platformListModel.get(currentIndex).uuid, platformListModel.get(currentIndex).connection)
        NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT,data)
        if (NavigationControl.flipable_parent_.flipped) {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
    else if (connection === "remote"){
        platformListModel.selectedConnection = "remote"
        // Call coreinterface connect()
        coreInterface.sendSelectedPlatform(platformListModel.get(currentIndex).uuid, platformListModel.get(currentIndex).connection)
        NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT,data)
        if (NavigationControl.flipable_parent_.flipped) {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    } else {
        if (NavigationControl.flipable_parent_.flipped) {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
}
