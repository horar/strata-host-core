.pragma library
.import "navigation_control.js" as NavigationControl
.import "uuid_map.js" as UuidMap
.import "qrc:/js/platform_filters.js" as PlatformFilters

.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var coreInterface
var listError = {
    "retry_count": 0,
    "retry_timer": Qt.createQmlObject("import QtQuick 2.12; Timer {interval: 3000; repeat: false; running: false;}",Qt.application,"TimeOut")
}
var platformSelectorModel
var classMap = {} // contains metadata for platformSelectorModel for faster lookups
var previouslyConnected = []

function initialize (newCoreInterface) {
    platformSelectorModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {property int currentIndex: 0; property string platformListStatus: 'loading'}",Qt.application,"PlatformSelectorModel")
    coreInterface = newCoreInterface
    listError.retry_timer.triggered.connect(function () { getPlatformList() });
    isInitialized = true
}

function getPlatformList () {
    platformSelectorModel.platformListStatus = "loading"
    const get_dynamic_plat_list = {
        "hcs::cmd": "dynamic_platform_list",
        "payload": {}
    }
    coreInterface.sendCommand(JSON.stringify(get_dynamic_plat_list));
}

/*
    Generate platform selector ListModel from incoming JSON platform list
*/
function generatePlatformSelectorModel(platform_list_json) {
    platformSelectorModel.clear()
    classMap = {}
    let platform_list

    // Parse JSON
    try {
        platform_list = JSON.parse(platform_list_json).list
    } catch(err) {
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Error parsing platform list:", err.toString())
        platformSelectorModel.platformListStatus = "error"
    }

    if (platform_list.length < 1) {
        // empty list received from HCS, retry getPlatformList() query
        emptyListRetry()
        return
    }
    listError.retry_count = 0

    PlatformFilters.initialize()

    console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Processing platform list");

    for (let platform of platform_list){
        if (platform.class_id === undefined || platform.hasOwnProperty("available") === false) {
            console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Platform has undefined or missing fields, skipping");
            continue
        }

        generatePlatform(platform)
    }

    parseConnectedPlatforms(coreInterface.connected_platform_list_)
    platformSelectorModel.platformListStatus = "loaded"
}

/*
    Retry and manage timeout when HCS responds with an empty platform list
*/
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
        platformSelectorModel.platformListStatus = "error"
    }
}

/*
    Generate ListElemtent from platform JSON and append to selector model
*/
function generatePlatform (platform) {
    let class_id_string = String(platform.class_id)
    let ui_location = ""
    if (UuidMap.uuid_map.hasOwnProperty(class_id_string)) {
        ui_location = UuidMap.uuid_map[class_id_string]   // fetch directory name used to bring up the UI
    } else {
        if (platform.available.control){
            console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Control 'available' flag set but no mapped UI for this class_id; overriding to deny access");
            platform.available.control = false
        }
    }

    // Parse list of text filters and gather complete filter info from PlatformFilters
    if (platform.hasOwnProperty("filters")) {
        platform.filters = PlatformFilters.getFilterList(platform.filters)
    } else {
        platform.filters = []
    }

    platform.error = false
    platform.connected = false  // != device_id, as device may be bound but not connected (i.e. view_open)
    platform.device_id = ""
    platform.visible = true
    platform.view_open = false
    platform.ui_exists = (ui_location !== "")
    platform.firmware_version = ""

    // Create entry in classMap
    classMap[class_id_string] = {
        "ui_location": ui_location,
        "original_listing": platform,
        "selector_listings": [platformSelectorModel.count]
    }

    // Add to the model
    platformSelectorModel.append(platform)
}

/*
    Determine platform connection changes and update model accordingly.
    Generate listings for duplicate/unlisted/unknown platforms.
*/
function parseConnectedPlatforms (connected_platform_list_json) {
    let currentlyConnected
    try {
        currentlyConnected = JSON.parse(connected_platform_list_json).list
    } catch(err) {
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Error parsing connected platforms list:", err.toString())
        return
    }

    for (let platform of currentlyConnected) {
        if (platform.class_id === undefined || platform.device_id === undefined) {
            console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Connected platform has undefined class_id or device_id, skipping")
            continue
        }

        if (devicePreviouslyConnected(platform.device_id)) {
            refreshFirmwareVersion(platform)
            continue
        } else {
            addConnectedPlatform(platform)
        }
    }

    // Clean up disconnected platforms remaining in previouslyConnected, restore model state
    for (let disconnected_platform of previouslyConnected) {
        disconnectPlatform(disconnected_platform)
    }

    previouslyConnected = currentlyConnected
}

function refreshFirmwareVersion(platform) {
    // Upon successful firmware flash, connected platform list resent, check for version changes
    let class_id_string = String(platform.class_id);
    let device_id_string = String(platform.device_id);

    if (classMap.hasOwnProperty(class_id_string)) {
        for (let index of classMap[class_id_string].selector_listings) {
            let selector_listing = platformSelectorModel.get(index)
            if (selector_listing.device_id === device_id_string) {
                if (selector_listing.firmware_version !== platform.firmware_version) {
                    selector_listing.firmware_version = platform.firmware_version
                    for (let i = 0; i < NavigationControl.platform_view_model_.count; i++) {
                        let open_view = NavigationControl.platform_view_model_.get(i)
                        if (open_view.class_id === class_id_string && open_view.device_id === device_id_string) {
                            open_view.firmware_version = platform.firmware_version
                            break
                        }
                    }
                } // else firmware version has not changed
                break
            }
        }
    }
}

/*
    Determine if device was already connected (present in most recent connected_platform_list_json)
*/
function devicePreviouslyConnected(device_id) {
    let device_id_string = String(device_id);
    for (let i = 0; i < previouslyConnected.length; i++) {
        if (String(previouslyConnected[i].device_id) === device_id_string) {
            // device previously connected: keep status, remove from previouslyConnected list
            previouslyConnected.splice(i, 1);
            return true
        }
    }
    return false
}

/*
    Determine if connected platform exists in model or if unlisted/unrecognized
*/
function addConnectedPlatform(platform) {
    let class_id_string = String(platform.class_id);
    let device_id_string = String(platform.device_id);

    if (classMap.hasOwnProperty(class_id_string)) {
        connectListing(class_id_string, device_id_string, platform.firmware_version)
    } else if (class_id_string !== "undefined" && UuidMap.uuid_map.hasOwnProperty(class_id_string)) {
        // unlisted platform connected: no entry in DP platform list, but UI found in UuidMap
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Unlisted platform connected:", class_id_string);
        insertUnlistedListing(platform)
    } else {
        // connected platform class_id not listed in UuidMap or DP platform list, or undefined
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Unknown platform connected:", class_id_string);
        insertUnknownListing(platform)
    }

    let data = {
        "device_id": device_id_string,
        "class_id": class_id_string,
        "firmware_version": platform.firmware_version
    }
    NavigationControl.updateState(NavigationControl.events.PLATFORM_CONNECTED_EVENT, data)
}

/*
    Update existing listing's 'connected' state
    OR add duplicate listing when 2 boards with same class_id connected
*/
function connectListing(class_id_string, device_id_string, firmware_version) {
    let found_visible = false
    let selector_listing
    let selector_index = -1

    // Do one of the following (by priority):
    //    1) find listing already bound to this device_id
    //    2) find any visible unbound listing for re-use
    //    3) find any unbound listing for re-use
    //    4) generate new listing
    for (let index of classMap[class_id_string].selector_listings) {
        selector_listing = platformSelectorModel.get(index)
        if (selector_listing.device_id === device_id_string) {
            selector_index = index
            break
        } else if (selector_listing.device_id === "" && found_visible === false) {
            selector_index = index
            if (selector_listing.visible) {
                found_visible = true
            }
        }
    }

    if (selector_index === -1) {
        selector_index = platformSelectorModel.count
        classMap[class_id_string].selector_listings.push(selector_index)
        let selectorCopy = copyObject(classMap[class_id_string].original_listing)
        platformSelectorModel.append(selectorCopy)
    }

    selector_listing = platformSelectorModel.get(selector_index)
    selector_listing.connected = true
    selector_listing.device_id = device_id_string
    selector_listing.firmware_version = firmware_version
    selector_listing.visible = true
    let available = copyObject(copyObject(selector_listing.available))
    available.unlisted = false // override unlisted to show hidden listing when physical board present
    selector_listing.available = available
}

function openPlatformView(platform) {
    let selector_listing = platformSelectorModel.get(platform.index)
    selector_listing.view_open = true

    let data = {
        "class_id": platform.class_id,
        "device_id": platform.device_id,
        "name": selector_listing.verbose_name,
        "view": "control",
        "connected": true,
        "available": platform.available,
        "firmware_version": platform.firmware_version
    }

    if (selector_listing.connected === false || selector_listing.ui_exists === false || platform.device_id === "" || platform.available.control === false) {
        data.view = "collateral"
        data.connected = false
    }

    NavigationControl.updateState(NavigationControl.events.OPEN_PLATFORM_VIEW_EVENT,data)
}

/*
    Disconnect listing, reset completely if no related PlatformView is open
*/
function disconnectPlatform(platform) {
    let device_id_string = String(platform.device_id)
    let class_id_string = String(platform.class_id)
    let selector_listing = getDeviceListing(class_id_string, device_id_string)

    selector_listing.connected = false

    if (selector_listing.view_open === false) {
        resetListing(selector_listing)
    }

    let data = {
        "device_id": device_id_string,
        "class_id": class_id_string
    }
    NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, data)
}

/*
    Reset listing to original disconnected state, unbind any device_id
    Remove duplicate listings, leaving last listing visible
*/
function resetListing(selector_listing) {
    selector_listing.device_id = ""
    selector_listing.available = copyObject(classMap[selector_listing.class_id].original_listing.available)

    if (selector_listing.error) {
        // remove error listings that are not connected and no view_open
        selector_listing.visible = false
    } else {
        // last listing out needs to stay visible in list
        for (let index of classMap[selector_listing.class_id].selector_listings) {
            let other_listing = platformSelectorModel.get(index)
            if (other_listing !== selector_listing && other_listing.visible) {
                // if at least one other listing is still visible, this one can be made invisible
                selector_listing.visible = false
                break
            }
        }
    }
}

/*
    Find platform listing in model for a given device_id
*/
function getDeviceListing(class_id_string, device_id_string) {
    for (let index of classMap[class_id_string].selector_listings) {
        if (platformSelectorModel.get(index).device_id === device_id_string) {
            return platformSelectorModel.get(index)
        }
    }
    return null
}

/*
    Set view_open state to false, unbind device_id and reset listing if no longer connected
*/
function closePlatformView (platform) {
    let selector_listing = getDeviceListing(String(platform.class_id), String(platform.device_id))

    selector_listing.view_open = false

    if (selector_listing.connected === false) {
        resetListing(selector_listing)
    }
}

/*
    Insert listing for platform that is not in DB platform_list and does not have a UI
*/
function insertUnknownListing (platform) {
    let platform_info = generateErrorListing(platform)
    insertErrorListing(platform_info)
}

/*
    Insert listing for platform that is not in DB platform_list but does have a UI
*/
function insertUnlistedListing (platform) {
    let platform_info = generateErrorListing(platform)

    platform_info.ui_exists = true
    platform_info.available.control = true
    platform_info.description = "No information to display."

    let index = insertErrorListing(platform_info)
}

function generateErrorListing (platform) {
    let error = {
        "verbose_name" : "Unknown Platform",
        "connected" : true,
        "class_id" :  String(platform.class_id),
        "device_id":  String(platform.device_id),
        "opn": "Class id: " +  String(platform.class_id),
        "description": "Strata does not recognize this class_id. Updating Strata may fix this problem.",
        "image": "", // Assigns 'not found' image
        "available": {
            "control": false,
            "documents": false,
            "unlisted": false,
            "order": false
        },
        "filters":[],
        "error": true,
        "visible": true,
        "view_open": false,
        "ui_exists": false,
        "firmware_version": platform.firmware_version
    }
    return error
}

function insertErrorListing (platform) {
    platformSelectorModel.append(platform)

    let index = platformSelectorModel.count - 1

    // create entry in classMap
    classMap[platform.class_id] = {
        "ui_location": "",
        "original_listing": platform,
        "selector_listings": [index]
    }

    if (platform.ui_exists) {
        classMap[platform.class_id].ui_location =  UuidMap.uuid_map[platform.class_id]
    }

    return index
}

function logout() {
    platformSelectorModel.platformListStatus = "loading"
    platformSelectorModel.clear()
    classMap = {}
    previouslyConnected = []
}

function copyObject(object){
    return JSON.parse(JSON.stringify(object))
}
