.pragma library
.import "navigation_control.js" as NavigationControl
.import "uuid_map.js" as UuidMap

.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var autoConnectEnabled = true
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
    var autoConnecting = false

    platformListModel.clear()
    platformListModel.currentIndex = 0

    // Parse JSON
    try {
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "populatePlaforms: ", platform_list_json)
        var platform_list = JSON.parse(platform_list_json)
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "number of platforms in list:", platform_list.list.length);

        for (var i = 0; i < platform_list.list.length; i ++){
            var platform_info

            var class_idPattern = new RegExp('^[0-9]{3,10}$');  // [TODO]: recreate regexp when class_id structure is finalized, currently checks for 3-10 digit int
            var class_id = String(platform_list.list[i].class_id);
            // console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "class_id =",class_id)

            if (class_idPattern.test(class_id) && class_id !== "undefined" && UuidMap.uuid_map.hasOwnProperty(class_id)) {  // Checks against the string "undefined" since it is cast to String() above
                console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "looking at platform", platform_list.list[i].class_id);

                // Extract platform information
                 platform_info = {
                    "verbose_name" : platform_list.list[i].verbose_name,
                    "name" : UuidMap.uuid_map[class_id],    // This will return the directory name used to bring up the UI
                    "connection" : platform_list.list[i].connection,
                    "class_id" : platform_list.list[i].class_id,
                    "on_part_number": platform_list.list[i].on_part_number,
                    "description": platform_list.list[i].description,
                    "image": platform_list.list[i].image,
                    "available": platform_list.list[i].available,
                    "icons": []
                }

                for (var j = 0; j < platform_list.list[i].application_icons.length; j++) {
                    platform_info.icons.push({"icon": platform_list.list[i].application_icons[j], "type": "application" })
                }
                for (var k = 0; k < platform_list.list[i].product_icons.length; k++) {
                    platform_info.icons.push({"icon": platform_list.list[i].product_icons[k], "type": "product" })
                }
//                console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, JSON.stringify(platform_info));

            } else {   // If there is an invalid/missing class_id, or not found in local map, build unknown board for interface
                // [TODO]: call HCS to check remote databases for class_id not found in local map for download
                console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "platform showing invalid/missing class_id, or not found in local map");
                platform_info = {
                    "verbose_name" : "Unknown Platform: " + platform_list.list[i].verbose_name,
                    "connection" : "view",  // Set view, don't want to autoconnect
                    "class_id" : platform_list.list[i].class_id,
                    "on_part_number": platform_list.list[i].on_part_number,
                    "description": "Please update Strata to use this platform.",
                    "image": "notFound.png",
                    "available": { "control": false, "documents": false }  // Don't allow control or docs for unknown board
                }
            }

            // Add to the model
            platformListModel.append(platform_info)

            // If the previously selected platform is still available, focus on it in platformSelector
            if (platformListModel.selectedClass_id === platform_info.class_id &&
                    platformListModel.selectedName === platform_info.name) {
                platformListModel.currentIndex = (platformListModel.count - 1)
            }

            if (platform_info.connection === "connected" && autoConnectEnabled){
                // copy "connected" platform; Note: this will auto select the last listed "connected" platform
                console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Selecting", platform_info.name, "for autoconnection");
                autoConnecting = true
                platformListModel.selectedClass_id = platform_info.class_id
                platformListModel.selectedName = platform_info.name
                platformListModel.selectedConnection = platform_info.connection
            }
        }
    }

    catch(err) {
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "CoreInterface error:", err.toString())
        platformListModel.clear()
        platformListModel.append({ "verbose_name" : "No platforms available" })
    }

    // Auto select newly connected platform
    if (autoConnecting) {
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Auto connecting platform ", platformListModel.selectedClassId)

        // Move connected plat listing to top of list
        platformListModel.move(platformListModel.currentIndex, 0, 1)
        platformListModel.currentIndex = 0

        sendSelection()
    } else {
        // Reset to default state
        deselectPlatform()
    }
}

function sendSelection () {
    // Run this disconnection code only if nav_control believes something is connected, otherwise createView() needlessly gets called
    if (NavigationControl.context["platform_connected"] || NavigationControl.context["offline_mode"] || NavigationControl.context["class_id"] !== "") {
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Disconnecting platform from navigation control")
        NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, null)
    }

    console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Disconnecting platform from core interface")
    coreInterface.disconnectPlatform()

    // Clear all documents for contents
    documentManager.clearDocumentSets();

    /*
        Determine action depending on what type of 'connection' is used
    */
    if (platformListModel.selectedConnection === ""){
        setControlView()

    } else {
        var data = { class_id: platformListModel.selectedClass_id }
        coreInterface.sendSelectedPlatform(platformListModel.selectedClass_id, platformListModel.selectedConnection)

        if (platformListModel.selectedConnection === "view") {
            NavigationControl.updateState(NavigationControl.events.OFFLINE_MODE_EVENT, data)
            setContentView()

        } else { // selectedConnection is "remote" or "connected"
            NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT,data)
            setControlView()
        }
    }
}

function setControlView(){
    NavigationControl.updateState(NavigationControl.events.SHOW_CONTROL)
}

function setContentView(){
    NavigationControl.updateState(NavigationControl.events.SHOW_CONTENT)
}

function selectPlatform(index){
    if (index >= 0) {
        platformListModel.currentIndex = index
        platformListModel.selectedClass_id = platformListModel.get(index).class_id
        platformListModel.selectedName = platformListModel.get(index).name
        platformListModel.selectedConnection = platformListModel.get(index).connection
    }
    sendSelection()
}

function deselectPlatform () {
    platformListModel.selectedClass_id = ""
    platformListModel.selectedName = ""
    platformListModel.selectedConnection = ""
    sendSelection()
}
