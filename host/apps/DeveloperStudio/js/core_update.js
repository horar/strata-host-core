.pragma library

.import "navigation_control.js" as NavigationControl
.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var coreInterface
var updateContainer

var current_version
var latest_version
var error_string

function initialize (newCoreInterface, newUpdateContainer) {
    coreInterface = newCoreInterface
    updateContainer = newUpdateContainer
    isInitialized = true
}

function getUpdateInformation () {
    const get_latest_release_version = {
        "hcs::cmd": "get_latest_release_version"
    }
    coreInterface.sendCommand(JSON.stringify(get_latest_release_version));
}

function parseVersionInfo (payload) {
    if (payload.hasOwnProperty("current_version") && payload.current_version.length > 0
        && payload.hasOwnProperty("latest_version") && payload.latest_version.length > 0) {
        console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Rcvd core update notification: current", payload.current_version, "latest", payload.latest_version)

        current_version = payload.current_version
        latest_version = payload.latest_version
        error_string = payload.error_string

        var temp_current_version = current_version.replace('-','').split(".");
        var temp_latest_version = latest_version.replace('-','').split(".");

        // Check if latest_version is newer than current_version
        if (payload.current_version != payload.latest_version) {
            for (let i = 0; i < temp_latest_version.length; i++) {
                if (parseInt(temp_latest_version[i]) > parseInt(temp_current_version[i])) {
                    console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Newer version available detected - offering update to ver", payload.latest_version)
                    createUpdatePopup()
                    break
                }
            }
        }

    } else {
        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Core update notification error. Notification is malformed:", JSON.stringify(payload));
        return
    }
}

function createUpdatePopup() {
    var coreUpdatePopup = NavigationControl.createView("qrc:/partial-views/core-update/SGCoreUpdate.qml", updateContainer)
    coreUpdatePopup.width = updateContainer.width-100
    coreUpdatePopup.height = updateContainer.height - 100
    coreUpdatePopup.x = updateContainer.width/2 - coreUpdatePopup.width/2
    coreUpdatePopup.y =  updateContainer.height/2 - coreUpdatePopup.height/2

    coreUpdatePopup.current_version = current_version
    coreUpdatePopup.latest_version = latest_version
    coreUpdatePopup.error_string = error_string

    coreUpdatePopup.open()
}

// On empty/invalid receive: retry until give-up
