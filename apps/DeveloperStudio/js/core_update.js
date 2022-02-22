/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
.pragma library

.import "navigation_control.js" as NavigationControl
.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var coreInterface
var updateLoader
var strataClient

var checking_for_updates = false
var compact_update_info_string = ""
var last_known_update_info_string = ""
var last_notification_timestamp = 0
var error_string = ""

var update_model
var settings_object
var notification_mode

var update_menuitem
var update_alerticon

var dontaskagain_checked = false
var one_day = 86400000 // one day in ms

function initialize (newSdsModel, newUpdateLoader) {
    coreInterface = newSdsModel.coreInterface
    updateLoader = newUpdateLoader
    strataClient = newSdsModel.strataClient
    update_model = Qt.createQmlObject("import QtQuick 2.0; ListModel {}", Qt.application)
    settings_object = Qt.createQmlObject("import Qt.labs.settings 1.1; Settings {category: \"CoreUpdate\";}", Qt.application)
    getUserNotificationModeFromINIFile()
    getLastKnownNotificationTimestampFromINIFile()
    getLastKnownUpdateInfoFromINIFile()
    isInitialized = true
}

function getUpdateInformation () {
    error_string = ""
    compact_update_info_string = ""
    checking_for_updates = true

    clearModelData()
    refreshUpdatePopupData()
    enableMenuItemAndAlertIcon(false)

    strataClient.sendRequest("check_for_updates",{})
}

function parseUpdateInfo (payload) {
    checking_for_updates = false
    // other data is already cleared in getUpdateInformation()

    if (payload.hasOwnProperty("component_list")) {
        var current_timestamp = new Date().getTime()
        if (payload.component_list.length === 0) {
            console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Received no updates available notification")
            setLastKnownUpdateInfo()
            refreshUpdatePopupData()
            return
        }

        console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Received updates available notification")
        processUpdateInfo(payload.component_list)

        if (compact_update_info_string.length > 0) {
            enableMenuItemAndAlertIcon(true)
        } else {
            error_string = "Received invalid updates notification"
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, error_string)
            refreshUpdatePopupData()
            return
        }

        // Check if latest_version is newer than last known version in the INI (offer update even if currently on "Don't Ask Again" mode)
        if (((dontaskagain_checked === false) &&
             ((last_notification_timestamp === 0) ||
             ((last_notification_timestamp + one_day) <= current_timestamp) ||
             (last_known_update_info_string !== compact_update_info_string))) ||
            ((dontaskagain_checked === true) &&
             (last_known_update_info_string !== compact_update_info_string))) {
            setLastKnownUpdateInfo()
            setLastKnownNotificationTimestamp(current_timestamp)
            setUserNotificationMode("AskAgainLater")
            enableMenuItemAndAlertIcon(true)
            createUpdatePopup()
            return
        } else {
            console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "User already requested to not update to these versions")
        }
    } else if (payload.hasOwnProperty("error_string") && payload.error_string.length > 0) {
        error_string = payload.error_string
        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, error_string)
    } else {
        error_string = "Core update notification error. Notification is malformed: " + JSON.stringify(payload)
        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, error_string)
    }
    refreshUpdatePopupData()
}

function processUpdateInfo (component_list) {
    var componentLength = component_list.length
    for (var i = 0; i < componentLength; i++) {
        if ((component_list[i].hasOwnProperty("name") === false) || (component_list[i].name.length === 0)) {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "missing 'name' property")
            continue
        }

        if ((component_list[i].hasOwnProperty("latest_version") === false) || (component_list[i].latest_version.length === 0)) {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "missing 'latest_version' property")
            continue
        }

        if ((component_list[i].hasOwnProperty("update_size") === false) || (component_list[i].update_size.length === 0)) {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "missing 'update_size' property")
            continue
        }

        if ((component_list[i].hasOwnProperty("current_version") === false) || (component_list[i].current_version.length === 0)) {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "missing 'current_version' property")
            continue
        }

        update_model.append(component_list[i])
        compact_update_info_string += "/" + component_list[i].name + "/" + component_list[i].latest_version
    }
    console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Update Info: ", compact_update_info_string)
}

function clearModelData() {
    update_model.clear()
}

function refreshUpdatePopupData() {
    if (updateLoader.active) {
        updateLoader.item.error_string = error_string
        updateLoader.item.checking_for_updates = checking_for_updates
        updateLoader.item.dontaskagain_checked = dontaskagain_checked
    }
}

function createUpdatePopup () {
    if (updateLoader.active === false) {
        NavigationControl.createView("qrc:/partial-views/core-update/SGCoreUpdate.qml", updateLoader)
    }

    updateLoader.item.width = updateLoader.width
    updateLoader.item.height = updateLoader.height

    refreshUpdatePopupData()

    if (updateLoader.item.opened === false) {
        updateLoader.item.open()
    }
}

function removeUpdatePopup () {
    NavigationControl.removeView(updateLoader)
}

function getUserNotificationModeFromINIFile () {
    if (settings_object.value("userNotificationMode")) {
        notification_mode = settings_object.value("userNotificationMode")
        if (notification_mode === "DontAskAgain") {
            dontaskagain_checked = true
        } else {
            dontaskagain_checked = false
        }
    } else {
        setUserNotificationMode()
    }
}

function setUserNotificationMode (mode) {
    if (mode && (mode === "DontAskAgain")) {
        settings_object.setValue("userNotificationMode", "DontAskAgain")
        dontaskagain_checked = true
    } else {
        settings_object.setValue("userNotificationMode", "AskAgainLater")
        dontaskagain_checked = false
    }
}

function getLastKnownNotificationTimestampFromINIFile () {
    if (settings_object.value("lastNotificationTimestamp")) {
        last_notification_timestamp = parseInt(settings_object.value("lastNotificationTimestamp"))
    } else {
        last_notification_timestamp = 0
    }
}

function setLastKnownNotificationTimestamp (notification_timestamp_int) {
    settings_object.setValue("lastNotificationTimestamp", notification_timestamp_int)
    last_notification_timestamp = notification_timestamp_int
}

function getLastKnownUpdateInfoFromINIFile () {
    if (settings_object.value("lastKnownUpdateInfo")) {
        last_known_update_info_string = settings_object.value("lastKnownUpdateInfo")
    } else {
        last_known_update_info_string = ""
    }
}

function setLastKnownUpdateInfo () {
    settings_object.setValue("lastKnownUpdateInfo", compact_update_info_string)
    last_known_update_info_string = compact_update_info_string
}

function registerMenuItem (item) {
    update_menuitem = item
}

function registerAlertIcon (icon) {
    update_alerticon = icon
}

function enableMenuItemAndAlertIcon (enable) {
    update_menuitem.hasUpdate = enable
    update_alerticon.visible = enable
}
