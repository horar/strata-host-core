.pragma library

.import "navigation_control.js" as NavigationControl
.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var coreInterface
var updateContainer

var current_version
var latest_version
var last_known_version
var error_string

var settings_object
var notification_mode

var update_menuitem
var dontaskagain_checked

function initialize (newCoreInterface, newUpdateContainer) {
    // No-op if not on Windows
    if (Qt.platform.os === "windows") {
        coreInterface = newCoreInterface
        updateContainer = newUpdateContainer
        settings_object = Qt.createQmlObject("import Qt.labs.settings 1.1; Settings {category: \"CoreUpdate\";}", Qt.application)
        getUserNotificationModeFromINIFile()
        getLastKnownVersionFromINIFile()
    }

    isInitialized = true
}

function getUpdateInformation () {
    // No-op if not on Windows
    if (Qt.platform.os === "windows") {
        const get_version_info = {
            "hcs::cmd": "get_component_version_info"
        }
        coreInterface.sendCommand(JSON.stringify(get_version_info));
    }
}

function parseVersionInfo (payload) {
    if (payload.hasOwnProperty("current_version") && payload.current_version.length > 0
        && payload.hasOwnProperty("latest_version") && payload.latest_version.length > 0) {
        console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Rcvd core version notification: current", payload.current_version, "latest", payload.latest_version)

        current_version = payload.current_version
        latest_version = payload.latest_version
        error_string = payload.error_string

        var temp_current_version = current_version.replace('-','').split(".");
        var temp_latest_version = latest_version.replace('-','').split(".");

        // Check if latest_version is newer than last known version in the INI (offer update even if currently on "Don't Ask Again" mode)
        if (last_known_version !== payload.latest_version) {
            setLastKnownVersion(payload.latest_version)
            setUserNotificationMode("AskAgainLater")
            enableMenuItem()
            createUpdatePopup()
            return
        }

        // Check if latest_version is newer than current_version
        if (payload.current_version !== payload.latest_version) {
            for (let i = 0; i < temp_latest_version.length; i++) {
                if (parseInt(temp_latest_version[i]) > parseInt(temp_current_version[i])) {
                    console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Newer version available detected:", payload.latest_version)
                    enableMenuItem()
                    if (notification_mode != "DontAskAgain") {
                        createUpdatePopup()
                    }
                    break
                }
            }
        }

        if (notification_mode == "DontAskAgain") {
            dontaskagain_checked = true
        } else {
            dontaskagain_checked = false
        }

    } else if (payload.hasOwnProperty("error_string") && payload.error_string.length > 0) {
        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, payload.error_string);
    } else {
        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Core update notification error. Notification is malformed:", JSON.stringify(payload));
    }
}

function createUpdatePopup () {
    var coreUpdatePopup = NavigationControl.createView("qrc:/partial-views/core-update/SGCoreUpdate.qml", updateContainer)
    coreUpdatePopup.width = updateContainer.width
    coreUpdatePopup.height = updateContainer.height
    coreUpdatePopup.x = updateContainer.width/2 - coreUpdatePopup.width/2
    coreUpdatePopup.y =  updateContainer.height/2 - coreUpdatePopup.height/2

    coreUpdatePopup.current_version = current_version
    coreUpdatePopup.latest_version = latest_version
    coreUpdatePopup.error_string = error_string
    coreUpdatePopup.dontaskagain_checked = dontaskagain_checked

    coreUpdatePopup.open()
}

function getUserNotificationModeFromINIFile () {
    if (settings_object.value("userNotificationMode")) {
        notification_mode = settings_object.value("userNotificationMode")
    } else {
        setUserNotificationMode()
    }

    if (notification_mode == "DontAskAgain") {
        dontaskagain_checked = true
    } else {
        dontaskagain_checked = false
    }
}

function setUserNotificationMode (mode) {
    if (mode && mode === "DontAskAgain") {
        settings_object.setValue("userNotificationMode", "DontAskAgain")
        dontaskagain_checked = true
    } else {
        settings_object.setValue("userNotificationMode", "AskAgainLater")
        dontaskagain_checked = false
    }
}

function getLastKnownVersionFromINIFile () {
    if (settings_object.value("lastKnownVersion")) {
        last_known_version = settings_object.value("lastKnownVersion")
    } else {
        last_known_version = ""
    }
}

function setLastKnownVersion (version) {
    settings_object.setValue("lastKnownVersion", version)
}

function registerMenuItem (item) {
    update_menuitem = item
}

function enableMenuItem () {
    update_menuitem.enabled = true
}