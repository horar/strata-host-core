.pragma library

.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var updateChecked = false
var coreInterface
var listError = {
    "retry_count": 0,
    "retry_timer": Qt.createQmlObject("import QtQuick 2.12; Timer {interval: 3000; repeat: false; running: false;}",Qt.application,"TimeOut")
}

// function initialize (newCoreInterface) {
//     coreInterface = newCoreInterface
//     listError.retry_timer.triggered.connect(function () { getUpdateInformation() });
// }

function getUpdateInformation (newCoreInterface) {

    if (isInitialized === false) {
        coreInterface = newCoreInterface
        isInitialized = true
    }

    console.error(LoggerModule.Logger.devStudioPlatformSelectionCategory, "[VICTOR] Inside core-self-update::getUpdateInformation");

    const get_latest_release_version = {
        "hcs::cmd": "get_latest_release_version",
        "payload": {
            "application":"developer_studio"
        }
    }
    coreInterface.sendCommand(JSON.stringify(get_latest_release_version));
}

// On empty/invalid receive: retry until give-up
