.pragma library
.import "navigation_control.js" as NavigationControl
.import "uuid_map.js" as UuidMap
.import "qrc:/js/platform_filters.js" as PlatformFilters

.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var autoConnectEnabled = true
var listError = {
    "retry_count": 0,
    "retry_timer": Qt.createQmlObject("import QtQuick 2.12; Timer {interval: 3000; repeat: false; running: false;}",Qt.application,"TimeOut")
}
var platformListModel
var coreInterface
var documentManager
var platformListModified = false
var platformListReceived = false

function initialize (newCoreInterface, newDocumentManager) {
    platformListModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {property int currentIndex: 0; property string selectedClass_id: ''; property string selectedName: ''; property string selectedConnection: ''; property string platformListStatus: 'loading'}",Qt.application,"PlatformListModel")
    coreInterface = newCoreInterface
    documentManager = newDocumentManager
    listError.retry_timer.triggered.connect(function () { getPlatformList() });
    isInitialized = true
}

function populatePlatforms(platform_list_json) {
    platformListModel.clear()
    platformListModel.currentIndex = 0

    // Parse JSON
    try {
        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "populatePlatforms: ", platform_list_json)
        var platform_list = JSON.parse(platform_list_json)

        if (platform_list.list.length < 1) {
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
                console.log("HCS failed to supply valid list, displaying error.")
                platformListModel.platformListStatus = "error"
            }
        } else {
            listError.retry_count = 0
            platformListModel.platformListStatus = "loaded"
        }

        PlatformFilters.initialize()

        for (var platform of platform_list.list){
            var platform_info

            console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Getting platform information for:", platform.class_id);

            // Extract platform information
            platform_info = {
                "verbose_name" : platform.verbose_name,
                "connection" : platform.connection,
                "class_id" : platform.class_id,
                "opn": platform.opn,
                "description": platform.description,
                "image": "file:/" + platform.image,
                "available": platform.available,
                "filters": [],
            }

            var class_id_String = String(platform.class_id)

            if (platform.class_id !== undefined && UuidMap.uuid_map.hasOwnProperty(class_id_String)) {
                platform_info.name = UuidMap.uuid_map[class_id_String]   // fetch directory name used to bring up the UI
            } else {
                // [TODO]: call HCS to check remote databases for class_id not found in local map for download
                if (platform_info.available.control || platform_info.available.documents){
                    console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "'Available' flags are set but no mapped UI for this class_id; overriding to deny access");
                    platform_info.available.control = false
                    platform_info.available.documents = false
                }
            }

            // Support both intermediate and planned Deployment Portal API
            if (platform.hasOwnProperty("filters")) {
                // platform matches new API
                for (let filter of platform.filters) {
                    let filterJSON = PlatformFilters.findFilter(filter)
                    if (filterJSON) {
                        platform_info.filters.push(filterJSON)
                    } else {
                        // filter from Deployment Portal unknown to UI; update Strata
                    }
                }
            } else {
                // platform matches old API - TODO [Faller]: remove once deployment portal supports new API, also remove oldNewMap from platformFilters
                for (var application_icon of platform.application_icons) {
                    if (PlatformFilters.oldNewMap.hasOwnProperty(application_icon)){
                        let filter = PlatformFilters.oldNewMap[application_icon]
                        let filterJSON = PlatformFilters.findFilter(filter)
                        if (filterJSON) {
                            platform_info.filters.push(filterJSON)
                        }
                    } else {
                        // icon is not a valid filter or unknown icon
                    }
                }
                for (var product_icon of platform.product_icons) {
                    if (PlatformFilters.oldNewMap.hasOwnProperty(product_icon)){
                        let filter = PlatformFilters.oldNewMap[product_icon]
                        let filterJSON = PlatformFilters.findFilter(filter)
                        if (filterJSON) {
                            platform_info.filters.push(filterJSON)
                        }
                    } else {
                        // icon is not a valid filter or unknown icon
                    }
                }
            }

            // console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, JSON.stringify(platform_info));

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

        parseConnectedPlatforms(coreInterface.connected_platform_list_)
    }
    catch(err) {
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, err.toString())
        appendErrorListing()
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
                    }
                    if (platformListModified === false) {
                        // recognized class_id in UuidMap, but no matching listing found in platformListModel
                        console.log(LoggerModule.Logger.devStudioPlatformSelectionCategory, "unlisted platform connected");
                        var platform_info = {
                            "verbose_name" : "Unlisted Platform Connected: " + platform.verbose_name,
                            "connection" : "connected",
                            "class_id" : platform.class_id,
                            "opn": "Class id: " + platform.class_id,
                            "description": "No information to display.",
                            "image": "images/platform-images/notFound.png",
                            "available": { "control": true, "documents": true },  // If UI exists and customer has physical board, allow access
                            "cachedDocuments": false,
                            "cachedControl": false,
                            "cachedConnection": "view",
                            "icons":[]
                        }
                        platformListModel.insert(0, platform_info)
                        if (autoConnectEnabled) {
                            selectPlatform(0)
                        }
                        platformListModified = true
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
        console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "ParseConnectedPlatforms error:", err.toString())
        appendErrorListing()
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
    documentManager.clearDocuments();

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

function getPlatformList () {
    platformListModel.platformListStatus = "loading"
    const get_dynamic_plat_list = {
        "hcs::cmd": "dynamic_platform_list",
        "payload": {}
    }
    coreInterface.sendCommand(JSON.stringify(get_dynamic_plat_list));
}

function appendErrorListing () {
    platformListModel.clear()
    platformListModel.append({
                                 "verbose_name": "Platform List Unavailable",
                                 "description": "There was a problem loading the platform list",
                                 "image": "images/platform-images/notFound.png",
                                 "available": { "control": false, "documents": false },
                                 "error": true,
                                 "opn": "",
                                 "icons":[],
                                 "class_id": "",
                                 "connection": "view"
                             })
}
