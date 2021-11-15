/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library
.import "navigation_control.js" as NavigationControl
.import "qrc:/js/platform_filters.js" as PlatformFilters
.import "constants.js" as Constants

.import tech.strata.logger 1.0 as LoggerModule
.import tech.strata.commoncpp 1.0 as CommonCpp
.import tech.strata.notifications 1.0 as PlatformNotifications

var isInitialized = false
var sdsModel
var coreInterface
var strataClient
var listError = {
    "retry_count": 0,
    "retry_timer": Qt.createQmlObject("import QtQuick 2.12; Timer {interval: 3000; repeat: false; running: false;}",Qt.application,"TimeOut")
}
var platformSelectorModel
var classMap = {} // contains metadata for platformSelectorModel for faster lookups
var previouslyConnected = []
var localPlatformListSettings = Qt.createQmlObject("import Qt.labs.settings 1.1; Settings {category: \"LocalPlatformList\";}", Qt.application)
var notificationActions = []
var localPlatformList = []

function createPlatformActions() {
    for(var i = 0; i < 2; i++){
        notificationActions[i] = Qt.createQmlObject("import QtQuick.Controls 2.12; Action {}",Qt.application, `PlatformNotifications${i}`)
    }
    notificationActions[0].text = "Ok"
    notificationActions[0].triggered.connect(function(){})
    notificationActions[1].text = "Disable platform notifications"
    notificationActions[1].triggered.connect(function(){disablePlatformNotifications()})
}

function initialize (newSdsModel) {
    platformSelectorModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {property int currentIndex: 0; property string platformListStatus: 'loading'}",Qt.application,"PlatformSelectorModel")
    sdsModel = newSdsModel
    coreInterface = newSdsModel.coreInterface;
    strataClient = newSdsModel.strataClient
    listError.retry_timer.triggered.connect(function () { getPlatformList() });
    isInitialized = true
    createPlatformActions()
}

function disablePlatformNotifications(){
    NavigationControl.userSettings.notifyOnPlatformConnections = false
    NavigationControl.userSettings.saveSettings()
}

function getPlatformList () {
    platformSelectorModel.platformListStatus = "loading"
    strataClient.sendRequest("dynamic_platform_list", {})
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

    platform_list.sort(function(a,b){ // Sort by timestamp
        return new Date(b.timestamp) - new Date(a.timestamp);
    });

    // Check to see if the user has a local platform list that they want to add
    if (localPlatformListSettings.value("path", "") !== "") {
        const localPlatforms = getLocalPlatformList(localPlatformListSettings.value("path"));
        console.info(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Found cached local platform list.")

        if (localPlatforms.length > 0) {
            const mode = localPlatformListSettings.value("mode", "append");
            localPlatformList = localPlatforms;

            if (mode === "replace") {
                console.info(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Replacing dynamic platform list with cached local platform list.")
                platform_list = localPlatformList;
            } else if (mode === "append") {
                console.info(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Appending cached local platform list to dynamic platform list")
                platform_list = platform_list.concat(localPlatformList);
            }
        }
    }

    let recentlyReleased = 3
    for (let platform of platform_list){
        if (platform.class_id === undefined || platform.hasOwnProperty("available") === false) {
            console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Platform has undefined or missing fields, skipping");
            continue
        }

        if ((platform.available.order || platform.available.documents) && !platform.available.unlisted) {
            platform.recently_released = recentlyReleased > 0 // set first 3 timestamp-sorted non-"coming soon"/"unlisted" platforms to be "recently released"
            recentlyReleased --
        }

        generatePlatform(platform)
    }

    parseConnectedPlatforms(coreInterface.connectedPlatformList_)
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
    const class_id_string = String(platform.class_id) // undefined class_id shall not get here

    // Parse list of text filters and gather complete filter info from PlatformFilters
    if (platform.hasOwnProperty("filters")) {
        platform.filters = PlatformFilters.getFilterList(platform.filters)
    } else {
        platform.filters = []
    }

    if (platform.hasOwnProperty("parts_list")) {
        platform.parts_list = platform.parts_list.map(part => { return { opn: part, matchingIndex: -1 }})
    } else {
        platform.parts_list = []
    }

    platform.desc_matching_index = -1
    platform.opn_matching_index = -1
    platform.name_matching_index = -1

    platform.error = false
    platform.connected = false  // != device_id, as device may be bound but not connected (i.e. view_open)
    platform.device_id = Constants.NULL_DEVICE_ID
    platform.visible = true
    platform.view_open = false
    platform.firmware_version = ""
    platform.program_controller = false
    platform.program_controller_progress = 0.0
    platform.program_controller_error_string = ""
    platform.controller_class_id = ""
    platform.is_assisted = false
    platform.coming_soon = !platform.available.documents && !platform.available.order

    // Create entry in classMap
    classMap[class_id_string] = {
        "original_listing": platform,
        "selector_listings": [platformSelectorModel.count]
    }

    // Add to the model
    platformSelectorModel.append(platform)
}

/*
    Determine platform connection changes and update model accordingly.
    Generate listings for duplicate/unknown platforms.
*/
function parseConnectedPlatforms (connected_platform_list_json) {
    let currentlyConnected
    try {
        currentlyConnected = JSON.parse(connected_platform_list_json).list
    } catch(err) {
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Error parsing connected platforms list:", err.toString())
        return
    }

    let i = currentlyConnected.length
    while (i--) {
        let platform = currentlyConnected[i]
        if ((platform.class_id === undefined && platform.controller_class_id === undefined) || platform.device_id === undefined) {
            console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Connected platform has undefined class_id or device_id, skipping")
            // remove bad platform from list
            currentlyConnected.splice(i, 1)
            continue
        }
        if (platform.class_id !== undefined) {
            platform.class_id = String(platform.class_id)
        }

        let previousIndex = previousDeviceIndex(platform.device_id)
        if (previousIndex > -1) {
            let previousPlatform = previouslyConnected[previousIndex]

            let platformChanged = previousPlatform.class_id !== platform.class_id
                || previousPlatform.platform_id !== platform.platform_id
                || previousPlatform.firmware_version !== platform.firmware_version
                || previousPlatform.active !== platform.active

            if (platform.controller_class_id !== undefined) {
                // Assisted Strata has additional properties
                // properties (class_id, ...) could be changed (e.g. controller (dongle) removed from platform (board))
                platformChanged = platformChanged
                    || previousPlatform.controller_class_id !== platform.controller_class_id
                    || previousPlatform.fw_class_id !== platform.fw_class_id
                    || previousPlatform.controller_platform_id !== platform.controller_platform_id
            }

            if (platformChanged) {
                disconnectPlatform(previousPlatform)
                addConnectedPlatform(platform)
            }

            // device previously connected: keep status, remove from previouslyConnected list
            previouslyConnected.splice(previousIndex, 1);
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

/*
    Determine if device was already connected (present in most recent connected_platform_list_json)
*/
function previousDeviceIndex(device_id) {
    for (let i = 0; i < previouslyConnected.length; i++) {
        if (previouslyConnected[i].device_id === device_id) {
            return i
        }
    }
    return -1
}

/*
    Determine if connected platform exists in model or if unrecognized
*/
function addConnectedPlatform(platform) {
    const is_assisted = (platform.controller_class_id !== undefined)

    // common data for embedded and assisted platforms
    let data = {
        "class_id": platform.class_id,
        "device_id": platform.device_id,
        "firmware_version": platform.firmware_version,
        "is_assisted": is_assisted
        // assisted platforms have an extra field - "controller_class_id"
    }

    if (is_assisted) {
        // Assisted Strata

        data.controller_class_id = platform.controller_class_id  // assisted platforms have an extra data field

        if (platform.controller_class_id === "") {
            //unregistered assisted controller
            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Unregistered assisted controller connected.");
            insertUnregisteredListing(platform)
        } else if (platform.class_id === undefined) {
            //controller without platform
            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Assisted controller without platform connected:", platform.controller_class_id);
            if (classMap.hasOwnProperty(platform.controller_class_id)) {
                connectListing(platform)
            } else {
                insertAssistedNoPlatformListing(platform)
            }

        } else if (platform.class_id === "") {
            //unregistered assisted platform
            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Unregistered assisted platform connected.");
            insertUnregisteredListing(platform)
        } else {
            if (platform.class_id === platform.fw_class_id) {
                if (classMap.hasOwnProperty(platform.class_id)) {
                    if (platform.firmware_version.length === 0) {
                        //controller with invalid firmware

                        // if there is already listing for this platform, reuse it
                        let listing = getDeviceListing(platform.class_id, platform.device_id)
                        if (listing) {
                            connectListing(platform)
                        } else {
                            insertProgramFirmwareListing(platform)
                        }

                        sdsModel.firmwareUpdater.programAssistedController(platform.device_id)
                    } else {
                        if (platform.active === "bootloader") {
                            if (sdsModel.firmwareUpdater.isFirmwareUpdateInProgress(platform.device_id)) {
                                // firmware backup is running (platform.firmware_version is not empty)
                                insertProgramFirmwareListing(platform)
                            } else {
                                console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Platform in bootloader mode connected.");
                                insertBootloaderListing(platform)
                                sdsModel.platformOperation.platformStartApplication(platform.device_id)
                            }
                        } else {
                            connectListing(platform)
                        }
                    }
                } else {
                    // connected platform class_id not listed in DP platform list
                    console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Unknown platform connected:", platform.class_id);
                    insertUnknownListing(platform)
                }
            } else {
                //uncompatible firmware installed
                insertProgramFirmwareListing(platform)
                sdsModel.firmwareUpdater.programAssistedController(platform.device_id)
            }
        }
    } else {
        // Embedded Strata

        if (platform.class_id === "") {
            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Unregistered platform connected.");
            insertUnregisteredListing(platform)
        } else {
            if (classMap.hasOwnProperty(platform.class_id)) {
                if (platform.firmware_version.length === 0) {
                    //device without firmware

                    // if there is already listing for this platform, reuse it
                    let listing = getDeviceListing(platform.class_id, platform.device_id)
                    if (listing) {
                        connectListing(platform)
                    } else {
                        insertProgramFirmwareListing(platform)
                    }

                    sdsModel.firmwareUpdater.programEmbeddedWithoutFw(platform.device_id)
                } else {
                    if (platform.active === "bootloader") {
                        if (sdsModel.firmwareUpdater.isFirmwareUpdateInProgress(platform.device_id)) {
                            // firmware backup is running (platform.firmware_version is not empty)
                            insertProgramFirmwareListing(platform)
                        } else {
                            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Platform in bootloader mode connected.");
                            insertBootloaderListing(platform)
                            sdsModel.platformOperation.platformStartApplication(platform.device_id)
                        }
                    } else {
                        connectListing(platform)
                    }
                }
            } else {
                // connected platform class_id not listed in DP platform list
                console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Unknown platform connected:", platform.class_id);
                insertUnknownListing(platform)
            }
        }
    }

    let platform_name = platform.verbose_name
    const class_id = (platform.class_id !== undefined) ? platform.class_id : platform.controller_class_id
    if (classMap.hasOwnProperty(class_id)) {
        platform_name = classMap[class_id].original_listing.verbose_name
    }
    notifyConnectedState(true, platform_name)

    NavigationControl.updateState(NavigationControl.events.PLATFORM_CONNECTED_EVENT, data)
}

/*
    Update existing listing's 'connected' state
    OR add duplicate listing when 2 boards with same class_id connected
*/
function connectListing(platform) {
    const class_id = (platform.class_id !== undefined) ? platform.class_id : platform.controller_class_id
    let found_visible = false
    let selector_listing
    let selector_index = -1

    // Do one of the following (by priority):
    //    1) find listing already bound to this device_id
    //    2) find any visible unbound listing for re-use
    //    3) find any unbound listing for re-use
    //    4) generate new listing
    for (let index of classMap[class_id].selector_listings) {
        selector_listing = platformSelectorModel.get(index)
        if (selector_listing.error) {
            continue // skip error listings created by assisted strata boards
        }

        if (selector_listing.device_id === platform.device_id) {
            selector_index = index
            break
        } else if (selector_listing.device_id === Constants.NULL_DEVICE_ID && found_visible === false) {
            selector_index = index
            if (selector_listing.visible) {
                found_visible = true
            }
        }
    }

    if (selector_index === -1) {
        selector_index = platformSelectorModel.count
        classMap[class_id].selector_listings.push(selector_index)
        let selectorCopy = copyObject(classMap[class_id].original_listing)
        platformSelectorModel.append(selectorCopy)
    }

    selector_listing = platformSelectorModel.get(selector_index)
    selector_listing.connected = true
    selector_listing.firmware_version = platform.firmware_version
    selector_listing.device_id = platform.device_id
    selector_listing.visible = true
    let available = copyObject(copyObject(selector_listing.available))
    available.unlisted = false // override unlisted to show hidden listing when physical board present
    if (platform.class_id === undefined) {  // controller without platform
        available.control = false
    }
    selector_listing.available = available
    selector_listing.controller_class_id = platform.controller_class_id
    selector_listing.is_assisted = (platform.controller_class_id !== null)
    // controller_class_id is automatically converted from null to "" here. So we need another flag is_assisted to remember whether there was controller_class_id.

    if (NavigationControl.userSettings.autoOpenView){
        if (selector_listing.available.control) {
            let data = {
                "name": selector_listing.verbose_name,
                "available": selector_listing.available,
                "class_id": selector_listing.class_id,
                "device_id": selector_listing.device_id,
                "firmware_version": selector_listing.firmware_version,
                "index": selector_index,
                "view": "control",
                "connected": true,
                "controller_class_id": selector_listing.controller_class_id,
                "is_assisted": selector_listing.is_assisted,
            }
            openPlatformView(data)
        }
    }
}

function openPlatformView(platform) {
    let selector_listing = null;
    if (platform.hasOwnProperty("index")) {
        selector_listing = platformSelectorModel.get(platform.index)
        selector_listing.view_open = true
    }

    let data = {
        "class_id": platform.class_id,
        "device_id": platform.device_id,
        "name": selector_listing ? selector_listing.verbose_name : platform.name,
        "view": platform.view,
        "connected": platform.connected,
        "available": platform.available,
        "firmware_version": platform.firmware_version,
        "controller_class_id": platform.controller_class_id,
        "is_assisted": platform.is_assisted
    }

    NavigationControl.updateState(NavigationControl.events.OPEN_PLATFORM_VIEW_EVENT,data)
}

/*
    Disconnect listing, reset completely if no related PlatformView is open
*/
function disconnectPlatform(platform) {
    const class_id = (platform.class_id !== undefined) ? platform.class_id : platform.controller_class_id
    const is_assisted = (platform.controller_class_id !== undefined)
    let selector_listing = getDeviceListing(class_id, platform.device_id)
    if (selector_listing === null) {
        let errStr = "Unable to disconnect platform, device_id: " + platform.device_id + ", class_id: " + platform.class_id
        if (is_assisted) {
            errStr += ", controller_class_id: " + platform.controller_class_id
        }
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, errStr)
        return;
    }

    selector_listing.connected = false

    resetListing(selector_listing)

    let platform_name = platform.verbose_name
    if (classMap.hasOwnProperty(class_id)) {
        platform_name = classMap[class_id].original_listing.verbose_name
    }
    notifyConnectedState(false, platform_name)

    let data = {
        "device_id": platform.device_id,
        "class_id": platform.class_id,
        "controller_class_id": platform.controller_class_id,
        "is_assisted": is_assisted
    }
    NavigationControl.updateState(NavigationControl.events.PLATFORM_DISCONNECTED_EVENT, data)

    if (selector_listing.view_open && NavigationControl.userSettings.closeOnDisconnect) {
        closePlatformView(platform)
        NavigationControl.updateState(NavigationControl.events.CLOSE_PLATFORM_VIEW_EVENT, data)
    }
}

/*
    Reset listing to original disconnected state, unbind any device_id
    Remove duplicate listings, leaving last listing visible
*/
function resetListing(selector_listing) {
    // even if 'class_id' was not defined, it can be contained in 'selector_listing' as empty string
    const class_id = (selector_listing.class_id === undefined || selector_listing.class_id.length === 0)
                     ? selector_listing.controller_class_id
                     : selector_listing.class_id

    selector_listing.device_id = Constants.NULL_DEVICE_ID
    selector_listing.available = copyObject(classMap[class_id].original_listing.available)

    selector_listing.program_controller = false
    selector_listing.program_controller_progress = 0.0
    selector_listing.program_controller_error_string = ""

    if (selector_listing.error) {
        // remove error listings that are not connected and no view_open
        selector_listing.visible = false
    } else {
        // last listing out needs to stay visible in list
        for (let index of classMap[class_id].selector_listings) {
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
function getDeviceListing(class_id_string, device_id) {
    if (classMap[class_id_string]) {
        for (let index of classMap[class_id_string].selector_listings) {
            if (platformSelectorModel.get(index).device_id === device_id) {
                return platformSelectorModel.get(index)
            }
        }
    }
    return null
}

/*
    Set view_open state to false, unbind device_id and reset listing if no longer connected
*/
function closePlatformView (platform) {
    let selector_listing = getDeviceListing(String(platform.class_id), platform.device_id)

    if (selector_listing !== null) {
        selector_listing.view_open = false

        if (selector_listing.connected === false) {
            resetListing(selector_listing)
        }
    }
}

/*
    Insert listing for platform that is not in DB platform_list and does not have a UI
*/
function insertUnknownListing (platform) {
    const class_id = (platform.class_id !== undefined) ? platform.class_id : platform.controller_class_id
    let listing_data = {
        "verbose_name": (platform.verbose_name) ? platform.verbose_name : "Unknown Platform",
        "opn" : "Class id: " + class_id,
        "description": "Strata does not recognize this class_id. Updating Strata may fix this problem."
    }

    insertListing(generateErrorListing(platform, listing_data))
}

/*
    Insert listing for unregistered platform
*/
function insertUnregisteredListing (platform) {
    let listing_data = {
        "verbose_name": "Unregistered platform",
        "description": "Unregistered platform. Contact local support."
    }

    insertListing(generateErrorListing(platform, listing_data))
}

/*
    Insert listing for unknown Strata assisted without platform (controller only)
*/
function insertAssistedNoPlatformListing (platform) {
    let listing_data = {
        "verbose_name": "Unknown Strata Assisted Controller",
        "description": "Please connect platform to controller."
    }

    insertListing(generateErrorListing(platform, listing_data))
}

/*
    Insert listing for Strata assisted with platform incompatible with controller
*/
function insertAssistedIncompatibleListing (platform) {
    const class_id = platform.class_id
    let fw_class_id = String(platform.fw_class_id)
    if (fw_class_id.length === 0) {
        fw_class_id = "no_firmware"
    }
    let listing_data = {
        "verbose_name": "Strata Assisted (incompatible firmware)",
        "class_id": class_id,
        "opn": "Class id: " + class_id,
        "description": "Strata Assisted: Firmware (" + fw_class_id + ") not compatible with platform (" + class_id + ")."
    }

    insertListing(generateErrorListing(platform, listing_data))
}

/*
    Insert listing for platform which is being flashed
*/
function insertProgramFirmwareListing(platform) {
    let listing_data = {
        "verbose_name": (platform.controller_class_id !== undefined)
                        ? "Strata Assisted Platform"
                        : "Strata Embedded Platform",
        "program_controller": true
    }
    const class_id = platform.class_id
    if (classMap.hasOwnProperty(class_id)) {
        const original_listing = classMap[class_id].original_listing
        listing_data.opn = original_listing.opn
        listing_data.verbose_name = original_listing.verbose_name
    }

    insertListing(generateErrorListing(platform, listing_data))
}

/*
    Insert listing for platform which is booted into bootloader
*/
function insertBootloaderListing(platform) {
    let listing_data = {
        "verbose_name": "Bootloader",
        "description": "Platform in bootloader mode."
    }
    const class_id = (platform.class_id !== undefined) ? platform.class_id : platform.controller_class_id
    if (classMap.hasOwnProperty(class_id)) {
        listing_data.opn = classMap[class_id].original_listing.opn
    }

    insertListing(generateErrorListing(platform, listing_data))
}

function generateErrorListing (platform, listing_data) {
    const is_assisted = (platform.controller_class_id !== undefined)
    let error = {
        "verbose_name": "",
        "connected": true,
        "class_id": platform.class_id,
        "device_id": platform.device_id,
        "opn": "N/A",
        "description": "",
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
        "parts_list": [],
        "firmware_version": platform.firmware_version,
        "program_controller": false,
        "program_controller_progress": 0.0,
        "program_controller_error_string": "",
        "controller_class_id": (is_assisted) ? platform.controller_class_id : "",
        "is_assisted": is_assisted
    }

    for (var attribute in listing_data) {
        error[attribute] = listing_data[attribute]
    }

    return error
}

function insertListing (platform) {
    platformSelectorModel.append(platform)

    let index = platformSelectorModel.count - 1
    const class_id = (platform.class_id !== undefined) ? platform.class_id : platform.controller_class_id

    if (classMap.hasOwnProperty(class_id)) {
        classMap[class_id].selector_listings.push(index)
    } else {
        // create entry in classMap
        classMap[class_id] = {
            "original_listing": platform,
            "selector_listings": [index]
        }
    }
}

/*
  Sets the localPlatformList array and adds it to the platformSelectorModel
*/
function setLocalPlatformList(list) {
    // Remove the previous local platforms if they exist
    if (localPlatformList.length > 0) {
        let idx = platformSelectorModel.count - localPlatformList.length

        if (idx >= 0) {
            platformSelectorModel.remove(idx, localPlatformList.length)
        }
    }

    localPlatformList = list;

    for (let platform of localPlatformList) {
        generatePlatform(platform)
    }
}

/*
  Reads the localPlatformList JSON file and returns its contents.
  If the JSON file has an error, it returns an empty array
*/

function getLocalPlatformList(path) {
    let contents = CommonCpp.SGUtilsCpp.readTextFileContent(path)

    if (contents !== "") {
        try {
            let localPlatforms = JSON.parse(contents);
            localPlatformListSettings.setValue("path", path);

            return localPlatforms;
        } catch (err) {
            console.error("Development platform list file has invalid JSON: ", path);
            return [];
        }
    }
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

function setPlatformSelectorModelPropertyRev(deviceId, propertyName, value) {
    //items are checked in reverse order

    for(var i = platformSelectorModel.count - 1; i >= 0; --i) {
        var item = platformSelectorModel.get(i)
        if (item.device_id === deviceId) {
            platformSelectorModel.setProperty(i, propertyName, value)
            break;
        }
    }
}

function notifyConnectedState(connected, platformName){
    if(NavigationControl.userSettings.notifyOnPlatformConnections){
        if (connected){
            PlatformNotifications.Notifications.createNotification(`${platformName} is connected`,
                                                                   PlatformNotifications.Notifications.Info,
                                                                   "all",
                                                                   {
                                                                       "timeout": 4000,
                                                                       "actions": [notificationActions[0],notificationActions[1]]
                                                                   })
        } else {
            PlatformNotifications.Notifications.createNotification(`${platformName} is disconnected`,
                                                                   PlatformNotifications.Notifications.Info,
                                                                   "all",
                                                                   {
                                                                       "timeout": 4000,
                                                                       "actions": [notificationActions[0],notificationActions[1]]
                                                                   })
        }
    }
}
