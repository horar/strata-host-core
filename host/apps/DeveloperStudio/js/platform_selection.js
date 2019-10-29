.pragma library
.import "navigation_control.js" as NavigationControl
.import "uuid_map.js" as UuidMap
.import "platform_model.js" as PlatformModel

.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var autoConnectEnabled = true
var platformListModel
var coreInterface
var documentManager
var platformListModified = false

function initialize (newModel, newCoreInterface, newDocumentManager) {
    isInitialized = true
    platformListModel = newModel
    coreInterface = newCoreInterface
    documentManager = newDocumentManager
}

function populatePlatforms(platform_list_json) {
    platformListModel.clear()
    platformListModel.currentIndex = 0
    var protocol = "file:/"

    // Parse JSON
    try {
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "populatePlaforms: ", platform_list_json)
        var platform_list = JSON.parse(platform_list_json)

        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "number of platforms in list:", platform_list.list.length);

        if (platform_list.list.length <1) {
            platform_list = PlatformModel.platforms
            protocol = "qrc:/"
            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Empty list received from HCS, loading hardcoded list of", platform_list.list.length, "platforms");
        }

        for (var platform of platform_list.list){
            var platform_info

            var class_id = String(platform.class_id);
            // console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "class_id =",class_id)

            if (class_id !== "undefined" && UuidMap.uuid_map.hasOwnProperty(class_id)) {  // Checks against the string "undefined" since it is cast to String() above
                console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "looking at platform", platform.class_id);

                // Extract platform information
                 platform_info = {
                    "verbose_name" : platform.verbose_name,
                    "name" : UuidMap.uuid_map[class_id],    // This will return the directory name used to bring up the UI
                    "connection" : platform.connection,
                    "class_id" : platform.class_id,
                    "opn": platform.opn,
                    "description": platform.description,
                    "image": protocol + platform.image,
                    "available": platform.available,
                    "icons": []
                }

                for (var application_icon of platform.application_icons) {
                    platform_info.icons.push({"icon": application_icon, "type": "application" })
                }
                for (var product_icon of platform.product_icons) {
                    platform_info.icons.push({"icon": product_icon, "type": "product" })
                }
//                console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, JSON.stringify(platform_info));

            } else {   // If there is an invalid/missing class_id, or not found in local map, build unknown board for interface
                // [TODO]: call HCS to check remote databases for class_id not found in local map for download
                console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "platform list showing a class_id that is not found in local map");
                platform_info = {
                    "verbose_name" : "Unknown Platform: " + platform.verbose_name,
                    "connection" : "view",
                    "class_id" : platform.class_id,
                    "opn": platform.opn,
                    "description": "Please update Strata to use this platform.",
                    "image": "images/platform-images/notFound.png",
                    "available": { "control": false, "documents": false }  // Don't allow control or docs for unknown board
                }
            }

            // Add to the model
            platformListModel.append(platform_info)
            // If the previously selected platform is still available, focus on it in platformSelector
            if (platformListModel.selectedClass_id === platform_info.class_id) {
                platformListModel.currentIndex = (platformListModel.count - 1)
            }
        }

        // Move connected plat listing to top of list
        if (platformListModel.currentIndex !==0) {
            platformListModel.move(platformListModel.currentIndex, 0, 1)
            platformListModel.currentIndex = 0
        }

        platformListModified = false
    }

    catch(err) {
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "CoreInterface error:", err.toString())
        platformListModel.clear()
        platformListModel.append({
                                     "verbose_name": "Platform List Unavailable",
                                     "description": "There was a problem loading the platform list",
                                     "image": "images/platform-images/notFound.png",
                                     "available": { "control": false, "documents": false }
                                 })
    }
}

function parseConnectedPlatforms (connected_platform_list_json) {
    try {
        var connected_platform_list = JSON.parse(connected_platform_list_json)

        if (connected_platform_list.list.length > 0) {
            // for every connected platform (currently should only be 1), check platformListModel for match, and update the model entry to connected state
            // if not found, generate a listing for unlisted or unknown platforms.
            platformListModel.currentIndex = 0
            for (var platform of connected_platform_list.list){
                var class_id = String(platform.class_id);
                if (class_id !== "undefined" && UuidMap.uuid_map.hasOwnProperty(class_id)) {
                    for (var j = 0; j < platformListModel.count; j ++) {
                        if (platform.class_id === platformListModel.get(j).class_id ) {

                            platformListModel.get(j).connection = "connected"
                            platformListModel.get(j).available = {
                                "documents": true,
                                "control": true
                            }
                            platformListModel.move(j, 0, 1)
                            if (autoConnectEnabled) {
                                selectPlatform(0)
                            }
                            platformListModified = true
                            break
                        }
                        if (j === platformListModel.count-1) {
                            // recognized class_id in UuidMap, but no matching listing found in platformListModel
                            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "unlisted platform connected");
                            var platform_info = {
                                "verbose_name" : "Unlisted Platform Connected: " + platform.verbose_name,
                                "connection" : "connected",
                                "class_id" : platform.class_id,
                                "opn": "Class id: " + platform.class_id,
                                "description": "No information to display.",
                                "image": "images/platform-images/notFound.png",
                                "available": { "control": false, "documents": false },  // Don't allow control or docs for unknown board
                                "cachedDocuments": false,
                                "cachedControl": false,
                                "cachedConnection": "view"
                            }
                            platformListModel.insert(0, platform_info)
                            if (autoConnectEnabled) {
                                selectPlatform(0)
                            }
                            platformListModified = true
                            break
                        }
                    }
                    break
                } else {
                    // class_id of connected platform not listed in UuidMap
                    console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "unknown platform connected");
                    var platform_info = {
                        "verbose_name" : "Unknown Platform Connected: " + platform.verbose_name,
                        "connection" : "view",
                        "class_id" : platform.class_id,
                        "opn": "Class id: " + platform.class_id,
                        "description": "Strata does not recognize this class_id. Updating Strata may fix this problem.",
                        "image": "images/platform-images/notFound.png",
                        "available": { "control": false, "documents": false },  // Don't allow control or docs for unknown board
                        "cachedDocuments": false,
                        "cachedControl": false,
                        "cachedConnection": "view"
                    }
                    platformListModel.insert(0, platform_info)
                    platformListModified = true
                }
            }
        } else {
            // no platforms connected, reset platformListModel to original state
            console.log("ParseConnectedPlatforms: no platforms connected")
            if (platformListModified) {
                populatePlatforms(coreInterface.platform_list_)
                if (platformListModel.selectedClass_id !== "") {
                    deselectPlatform()
                }
            }
        }
    } catch(err) {
        console.log(LoggerModule.Logger.devStudioPlatformModelCategory, "ParseConnectedPlatforms error:", err.toString())
        platformListModel.clear()
        platformListModel.append({ "verbose_name" : "Error! No platforms available" })
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
        platformListModel.selectedConnection = platformListModel.get(index).connection
    }
    sendSelection()
}

function deselectPlatform () {
    platformListModel.selectedClass_id = ""
    platformListModel.selectedConnection = ""
    sendSelection()
}
