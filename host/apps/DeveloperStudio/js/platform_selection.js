.pragma library
.import "navigation_control.js" as NavigationControl
.import "uuid_map.js" as UuidMap
.import "qrc:/js/platform_filters.js" as PlatformFilters

.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var coreInterface
var documentManager
var platformViewModel
var listError = {
    "retry_count": 0,
    "retry_timer": Qt.createQmlObject("import QtQuick 2.12; Timer {interval: 3000; repeat: false; running: false;}",Qt.application,"TimeOut")
}
var platformListModel
var platformMap = {}
var autoConnectEnabled = true
var previouslyConnected = []

function initialize (newCoreInterface, newDocumentManager, newPlatformViewModel) {
    platformListModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {property int currentIndex: 0; property string platformListStatus: 'loading'}",Qt.application,"PlatformListModel")
    coreInterface = newCoreInterface
    documentManager = newDocumentManager
    platformViewModel = newPlatformViewModel
    listError.retry_timer.triggered.connect(function () { getPlatformList() });
    isInitialized = true
}

/*
    Generate model from incoming platform list
*/
function populatePlatforms(platform_list_json) {
    platformListModel.clear()
    platformMap = {}
    let platform_list

    // Parse JSON
    try {
        platform_list = JSON.parse(platform_list_json)
    } catch(err) {
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Error parsing platform list:", err.toString())
        insertErrorListing()
    }

    if (platform_list.list.length < 1) {
        // empty list received from HCS, retry getPlatformList() query
        emptyListRetry()
        return
    }
    listError.retry_count = 0

    PlatformFilters.initialize()

    console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Processing platform list");
    let index = 0
    for (let platform of platform_list.list){
        platform.error = false

        if (platform.class_id === undefined) {
            console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Platform class_id undefined, skipping");
            continue
        }

        let class_id_string = String(platform.class_id)
        if (UuidMap.uuid_map.hasOwnProperty(class_id_string) && platform.hasOwnProperty("available")) {
            platform.name = UuidMap.uuid_map[class_id_string]   // fetch directory name used to bring up the UI
        } else {
            if (platform.hasOwnProperty("available")) {
                if (platform.available.control){
                    console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Control 'available' flag set but no mapped UI for this class_id; overriding to deny access");
                    platform.available.control = false
                }
            } else {
                console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "'available' field missing for class id", platform.class_id, ", skipping");
                continue
            }
        }

        // Parse list of text filters and gather complete filter info from PlatformFilters
        // Support both intermediate and planned Deployment Portal API
        if (platform.hasOwnProperty("filters")) {
            // platform matches new API
            let filterModel = []
            for (let filter of platform.filters) {
                let filterListItem = PlatformFilters.findFilter(filter)
                if (filterListItem) {
                    filterModel.push(filterListItem)
                } else {
                    // filter from Deployment Portal unknown to UI; update Strata
                }
            }
            platform.filters = filterModel
        } else {
            platform.filters = []
            // platform matches old API - TODO [Faller]: remove once deployment portal supports new API, also remove oldNewMap from platformFilters
            if (platform.hasOwnProperty("application_icons")) {
                for (let application_icon of platform.application_icons) {
                    if (PlatformFilters.oldNewMap.hasOwnProperty(application_icon)){
                        let filter = PlatformFilters.oldNewMap[application_icon]
                        let filterListItem = PlatformFilters.findFilter(filter)
                        if (filterListItem) {
                            platform.filters.push(filterListItem)
                        }
                    }
                }
            }
            if (platform.hasOwnProperty("product_icons")) {
                for (let product_icon of platform.product_icons) {
                    if (PlatformFilters.oldNewMap.hasOwnProperty(product_icon)){
                        let filter = PlatformFilters.oldNewMap[product_icon]
                        let filterListItem = PlatformFilters.findFilter(filter)
                        if (filterListItem) {
                            platform.filters.push(filterListItem)
                        }
                    }
                }
            }
        }

        // Add to the model
        platformListModel.append(platform)

        // Create entry in platformMap
        platformMap[class_id_string] = {
            "index": index,
            "ui_exists": (platform.name !== undefined),
            "available": platform.available
        }
        index++
    }

    parseConnectedPlatforms(coreInterface.connected_platform_list_)
    platformListModel.platformListStatus = "loaded"
}

/*
    Determine platform connection changes and update model accordingly.
    Generate listings for unlisted/unknown platforms.
*/
function parseConnectedPlatforms (connected_platform_list_json) {
    // Build next 'previouslyConnected' list
    let currentlyConnected = []
    let connected_platform_list

    try {
        connected_platform_list = JSON.parse(connected_platform_list_json)
    } catch(err) {
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Error parsing connected platforms list:", err.toString())
        return
    }

    for (let platform of connected_platform_list.list) {
        if (platform.class_id === undefined) {
            console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Connected platform has undefined class_id, skipping")
            continue
        }
        let class_id_string = String(platform.class_id);
        currentlyConnected.push(class_id_string)

        // Determine if platform exists in model or if unlisted/unrecognized
        if (platformMap.hasOwnProperty(class_id_string)) {
            if (previouslyConnected.includes(class_id_string)) {
                // platform previously connected: keep status, remove from previouslyConnected list
                previouslyConnected.splice(previouslyConnected.indexOf(class_id_string), 1);
            } else {
                // update model
                let index = platformMap[class_id_string].index
                platformListModel.get(index).connection = "connected"

                if (platformMap[class_id_string].ui_exists) {
                    platformListModel.get(index).available = {
                        "documents": true,
                        "control": true
                    }
                    autoConnect(class_id_string)
                }
            }
        } else if (class_id_string !== "undefined" && UuidMap.uuid_map.hasOwnProperty(class_id_string)) {
            // unlisted platform connected: no entry in DP platform list, but UI found in UuidMap
            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Unlisted platform connected:", class_id_string);
            insertUnlistedListing(platform)
            autoConnect(class_id_string)
        } else {
            // connected platform class_id not listed in UuidMap or DP platform list, or undefined
            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Unknown platform connected:", class_id_string);
            insertUnknownListing(platform)
        }
    }

    // Clean up disconnected platforms remaining in previouslyConnected, restore model state
    for (let class_id of previouslyConnected) {
        let index = platformMap[class_id].index
        if (platformListModel.get(index).error) {
            // Remove listings for unlisted/unknown boards
            delete platformMap[class_id]
            platformListModel.remove(index)
        } else {
            // Restore original disconnected state
            platformListModel.get(index).connection = "view"
            platformListModel.get(index).available = platformMap[class_id].available
        }

        let data = {"class_id": class_id}
        NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, data)
    }

    previouslyConnected = currentlyConnected
}

function selectPlatform(class_id){
    // Get docs if no views are currently open (only one set of docs supported at this time)
    if (platformViewModel.count === 0) {
        coreInterface.connectToPlatform(class_id)
    }

    let index = platformMap[String(class_id)].index
    let data = { "class_id": class_id }
    if (platformListModel.get(index).connection === "view" || platformMap[String(class_id)].ui_exists === false) {
        NavigationControl.updateState(NavigationControl.events.VIEW_COLLATERAL_EVENT, data)
    } else { // connection is "connected"
        NavigationControl.updateState(NavigationControl.events.PLATFORM_CONNECTED_EVENT,data)
    }
}

function autoConnect(class_id) {
    if (autoConnectEnabled) {
        selectPlatform(class_id)
    }
}

function getPlatformList () {
    platformListModel.platformListStatus = "loading"
    const get_dynamic_plat_list = {
        "hcs::cmd": "dynamic_platform_list",
        "payload": {}
    }
    coreInterface.sendCommand(JSON.stringify(get_dynamic_plat_list));
}

function emptyListRetry() {
    if (listError.retry_count < 3) {
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Received empty platform list from HCS, will retry in 3 seconds")
        listError.retry_count++
        listError.retry_timer.start()
    } else if (listError.retry_count < 8) {
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Received empty platform list from HCS, will retry in 10 seconds")
        listError.retry_timer.interval = 10000
        listError.retry_count++
        listError.retry_timer.start()
    } else {
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "HCS failed to supply valid list, displaying error.")
        platformListModel.platformListStatus = "error"
    }
}

function insertErrorListing () {
    platformListModel.clear()
    let platform_info = {
        "verbose_name": "Platform List Unavailable",
        "connection": "view",
        "class_id": "",
        "opn": "",
        "description": "There was a problem loading the platform list",
        "image": "file:/", // Assigns 'not found' image
        "available": { "control": false, "documents": false },
        "filters":[],
        "error": true,
    }
    platformListModel.append(platform_info)
    platformMap = {}
}

function insertUnknownListing (platform) {
    let platform_info = {
        "verbose_name" : "Unknown Platform Connected: " + platform.verbose_name,
        "connection" : "connected",
        "class_id" : platform.class_id,
        "opn": "Class id: " + platform.class_id,
        "description": "Strata does not recognize this class_id. Updating Strata may fix this problem.",
        "image": "file:/", // Assigns 'not found' image
        "available": { "control": false, "documents": false },  // Don't allow control or docs for unknown platform
        "filters":[],
        "error": true
    }
    platformListModel.append(platform_info)

    // create entry in platformMap
    platformMap[String(platform_info.class_id)] = {
        "index": platformListModel.count - 1,
        "ui_exists": false
    }
}

function insertUnlistedListing (platform) {
    let class_id_string = String(platform.class_id)

    let platform_info = {
        "verbose_name" : "Unlisted Platform Connected: " + platform.verbose_name,
        "connection" : "connected",
        "class_id" : platform.class_id,
        "opn": "Class id: " + platform.class_id,
        "description": "No information to display.",
        "image": "file:/", // Assigns 'not found' image
        "available": { "control": true, "documents": true },  // If UI exists and customer has physical platform, allow access
        "filters":[],
        "name": UuidMap.uuid_map[class_id_string],
        "error": true,
    }
    platformListModel.append(platform_info)

    // create entry in platformMap
    platformMap[class_id_string] = {
        "index": platformListModel.count - 1,
        "ui_exists": true
    }
}

function logout() {
    platformListModel.platformListStatus = "loading"
    platformListModel.clear()
    platformMap = {}
    previouslyConnected = []
}
