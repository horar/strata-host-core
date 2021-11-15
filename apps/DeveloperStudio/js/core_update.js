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
.import tech.strata.logger 1.0 as LoggerModule

var isInitialized = false
var coreInterface
var updateLoader
var strataClient

var update_info_string = ""
var compact_update_info_string = ""
var last_known_update_info_string = ""
var last_notification_timestamp = 0
var error_string = ""

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
    settings_object = Qt.createQmlObject("import Qt.labs.settings 1.1; Settings {category: \"CoreUpdate\";}", Qt.application)
    getUserNotificationModeFromINIFile()
    getLastKnownNotificationTimestampFromINIFile()
    getLastKnownUpdateInfoFromINIFile()
    isInitialized = true
}

function getUpdateInformation () {
    strataClient.sendRequest("check_for_updates",{});
}

function parseUpdateInfo (payload) {
    if (payload.hasOwnProperty("component_list")) {
        var current_timestamp = new Date().getTime()
        if (payload.component_list.length === 0) {
            console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Received no updates available notification")
            update_info_string = ""
            compact_update_info_string = ""
            setLastKnownUpdateInfo()
            return;
        }

        console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Received updates available notification")
        processUpdateInfo(payload.component_list)

        if (compact_update_info_string.length > 0) {
            enableMenuItemAndAlertIcon()
        } else {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Received invalid updates notification")
            return;
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
            enableMenuItemAndAlertIcon()
            createUpdatePopup()
        } else {
            console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "User already requested to not update to these versions")
        }
    } else if (payload.hasOwnProperty("error_string") && payload.error_string.length > 0) {
        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, payload.error_string);
    } else {
        console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Core update notification error. Notification is malformed:", JSON.stringify(payload))
    }
}

function processUpdateInfo (component_list) {
    update_info_string = ""
    compact_update_info_string = ""
    var componentLength = component_list.length;
    for (var i = 0; i < componentLength; i++) {
        if ((component_list[i].hasOwnProperty("name") === false) || (component_list[i].name.length === 0)) {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "missing 'name' property");
            continue;
        }

        if ((component_list[i].hasOwnProperty("latest_version") === false) || (component_list[i].latest_version.length === 0)) {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "missing 'latest_version' property");
            continue;
        }

        if ((component_list[i].hasOwnProperty("update_size") === false) || (component_list[i].update_size.length === 0)) {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "missing 'update_size' property");
            continue;
        }

        if ((component_list[i].hasOwnProperty("current_version") === false) || (component_list[i].current_version.length === 0)) {
            console.error(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "missing 'current_version' property");
            continue;
        }

        update_info_string += "<p><b>" + component_list[i].name + "</b><br>"
        update_info_string += "New Version: <b>" + component_list[i].latest_version + "</b>";
        if (component_list[i].current_version !== "N/A")
            update_info_string += " (<b>" + component_list[i].current_version + "</b>)";
        update_info_string += "<br>Update Size: <b>" + component_list[i].update_size + "</b>";
        update_info_string += "</p>"
        compact_update_info_string += "/" + component_list[i].name + "/" + component_list[i].latest_version
    }
    console.info(LoggerModule.Logger.devStudioCorePlatformInterfaceCategory, "Update Info: ", compact_update_info_string)
}

function createUpdatePopup () {
    NavigationControl.createView("qrc:/partial-views/core-update/SGCoreUpdate.qml", updateLoader)

    updateLoader.item.width = updateLoader.width
    updateLoader.item.height = updateLoader.height

    updateLoader.item.update_info_string = update_info_string
    updateLoader.item.error_string = error_string
    updateLoader.item.dontaskagain_checked = dontaskagain_checked

    updateLoader.item.open()
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

function enableMenuItemAndAlertIcon () {
    update_menuitem.enabled = true
    update_alerticon.visible = true
}
