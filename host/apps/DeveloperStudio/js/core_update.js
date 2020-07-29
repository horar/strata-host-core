.pragma library

.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
// var updateChecked = false
var coreInterface
var listError = {
    "retry_count": 0,
    "retry_timer": Qt.createQmlObject("import QtQuick 2.12; Timer {interval: 3000; repeat: false; running: false;}",Qt.application,"TimeOut")
}

function initialize (newCoreInterface) {
    coreInterface = newCoreInterface
    isInitialized = true
//     listError.retry_timer.triggered.connect(function () { getUpdateInformation() });
}

function getUpdateInformation () {
    const get_latest_release_version = {
        "hcs::cmd": "get_latest_release_version"
    }
    coreInterface.sendCommand(JSON.stringify(get_latest_release_version));
}

function parseVersionInfo (payload) {
    console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "[VICTOR] Inside parseVersionInfo");

    let version_info

    const obj = JSON.parse(payload)


    console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "[VICTOR] obj: ", obj)

    // // Parse JSON
    // try {
    //     version_info = JSON.parse(payload)
    // } catch(err) {
    //     console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Error parsing version info:", err.toString())
    //     // platformSelectorModel.platformListStatus = "error"
    // }

    // if (version_info.length < 1) {
    //     console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Version info JSON length < 1")
    //     // empty list received from HCS, retry getPlatformList() query
    //     // emptyListRetry()
    //     return
    // }

    // console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "Version info from UI: ", version_info.latest_version)

}

// On empty/invalid receive: retry until give-up
