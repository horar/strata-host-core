.pragma library

.import "navigation_control.js" as NavigationControl
.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var coreInterface
var updateContainer
var listError = {
    "retry_count": 0,
    "retry_timer": Qt.createQmlObject("import QtQuick 2.12; Timer {interval: 3000; repeat: false; running: false;}",Qt.application,"TimeOut")
}

var latest_version
var current_version

function initialize (newCoreInterface, newUpdateContainer) {
    coreInterface = newCoreInterface
    updateContainer = newUpdateContainer
    // isInitialized = true
//     listError.retry_timer.triggered.connect(function () { getUpdateInformation() });
}

function getUpdateInformation () {
    const get_latest_release_version = {
        "hcs::cmd": "get_latest_release_version"
    }
    coreInterface.sendCommand(JSON.stringify(get_latest_release_version));
}

function parseVersionInfo (payload) {
    if (payload.hasOwnProperty("latest_version") && payload.latest_version.length > 0) {
        console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Received Core Update notification, latest version:", payload.latest_version)
        latest_version = payload.latest_version
        open()
    } else {
        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Core Update Notification Error. Notification is malformed:", JSON.stringify(payload));
        return
    }
}

function open() {
    var coreUpdatePopup = NavigationControl.createView("qrc:/partial-views/core-update/SGCoreUpdate.qml", updateContainer)
    coreUpdatePopup.width = updateContainer.width-100
    coreUpdatePopup.height = updateContainer.height - 100
    coreUpdatePopup.x = updateContainer.width/2 - coreUpdatePopup.width/2
    coreUpdatePopup.y =  updateContainer.height/2 - coreUpdatePopup.height/2
    coreUpdatePopup.latest_version = latest_version
    coreUpdatePopup.open()
}

// On empty/invalid receive: retry until give-up
