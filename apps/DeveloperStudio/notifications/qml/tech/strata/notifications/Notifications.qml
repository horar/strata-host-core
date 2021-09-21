/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
pragma Singleton

import QtQuick 2.12
import QtQml 2.12
import QtQml.Models 2.12

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/constants.js" as Constants
import "qrc:/js/login_utilities.js" as Authenticator

/*
  Core notifications: see createNotification() below for use
*/

Item {
    property alias model: filteredNotifications
    property string currentUser: ""

    enum Level {
        Info = 0,
        Warning = 1,
        Critical = 2
    }

    onCurrentUserChanged: {
        filteredNotifications.invalidate()
    }

    SGUserSettings {
        id: notificationSettings
        user: "strata"
        classId: "notifications"
    }

    ListModel {
        id: model_

        Component.onCompleted: {
            addSavedNotifications()
        }

        Component.onDestruction: {
            saveNotifications()
        }
    }

    SGSortFilterProxyModel {
        id: filteredNotifications
        sourceModel: model_
        invokeCustomFilter: true
        sortEnabled: false

        function filterAcceptsRow(index) {
            const notification = sourceModel.get(index);
            if (notification.to !== "all" && notification.to !== currentUser) {
                return false
            } else {
                return true
            }
        }

        function remove(index) {
            sourceModel.remove(index)
        }

        function clear() {
            sourceModel.clear()
        }
    }

    Connections {
        target: Signals

        onLoginResult: {
            const resultObject = JSON.parse(result)
            //console.log(Logger.devStudioCategory, "Login result received")
            if (resultObject.response === "Connected") {
                currentUser = resultObject.user_id
            }
        }

        onLogout: {
            for (let i = 0; i < model_.count; i++) {
                // Clear any actions when the user logs out
                model_.get(i).actions.clear()
            }

            currentUser = ""
        }

        onValidationResult: {
            if (result === "Current token is valid" && currentUser !== Constants.GUEST_USER_ID) {
                currentUser = Authenticator.settings.user
            }
        }
    }

    /**
     * Function: createNotification
     * Description: creates and appends a notification to the list of notifications
     * Parameters:
        - title (REQUIRED): The notification title
        - level (REQUIRED): The notification importance level (0, 1, 2) (Notifications.Info, Notifications.Warning, Notifications.Critical)
        - to (REQUIRED): The user to show the notification to. Either "all", "current", or a specific user's email id
        - additionalParameters: The object can include the following properties
            - description: The notification description
            - actions: A list of Action objects that correspond to each button in the notification
            - saveToDisk: Whether to save the notification to disk/inbox or discard upon timeout | DEFAULT: False
                * note, upon logout or app close, the actions associated with a notification are removed due to them being context specific.
            - singleton: Only allow one notification with this title to be exposed to the user | DEFAULT: False
            - timeout: The timeout for the notification (in milliseconds), set 0 for no timeout | DEFAULT: 10000ms for non-critical notifications, critical default is 0
            - iconSource: The icon's source url | DEFAULT: level === Notifications.Level.Info ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/exclamation-triangle.svg"

        Example:
            Action {
                id: notificationAction
                text: "Click me" // Text displayed on the button
                onTriggered: { // Run this when the button is clicked
                    console.log("I was clicked!")
                }
            }

            Notifications.createNotification(
                        "This is a title",
                        Notifications.Info,
                        "all",
                        {
                            "description": "This is the notification description",
                            "actions": [testNotificationAction, ...]
                        })

     **/
    function createNotification(title, level, to, additionalParameters = {}) {
        const description = additionalParameters.hasOwnProperty("description") ? additionalParameters["description"] : "";
        const actions = additionalParameters.hasOwnProperty("actions") ? additionalParameters["actions"].map((action) => ({"action": action})) : [];
        const saveToDisk = additionalParameters.hasOwnProperty("saveToDisk") ? additionalParameters["saveToDisk"] : false;
        const singleton = additionalParameters.hasOwnProperty("singleton") ? additionalParameters["singleton"] : false;
        const iconSource = additionalParameters.hasOwnProperty("iconSource") ? additionalParameters["iconSource"] : (level === Notifications.Level.Info ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/exclamation-triangle.svg");
        let timeout = additionalParameters.hasOwnProperty("timeout") ? additionalParameters["timeout"] : -1;
        var uuid = create_UUID()

        if (timeout < 0) {
            if (level < 2) {
                timeout = 10000
            } else {
                timeout = 0
            }
        }

        if (to === "current") {
            to = NavigationControl.context.user_id;
        }

        const notification = {
            "title": title,
            "description": description,
            "level": level,
            "to": to,
            "hidden": false,
            "date": new Date(),
            "timeout": timeout,
            "iconSource": iconSource,
            "saveToDisk": saveToDisk,
            "singleton": singleton,
            "actions": actions,
            "uuid": uuid,
        };

        let foundEntry = false;
        // Check the pre-existing entry in the model and see if that one is a singleton
        for (let i = 0; i < model_.count; i++) {
            let notif = model_.get(i);
            if (notif.title === title) {
                if (notif.singleton) {
                    return false
                }

                foundEntry = true;
                break;
            }
        }

        if (singleton && foundEntry) {
            // If the entry being inserted has the singleton property set to true, and the title already exists, don't insert
            return "";
        }

        model_.append(notification);
        return uuid;
    }

    function saveNotifications() {
        // Save the open notifications to disk on close
        let notifications = { "notifications": [] };
        for (let i = 0; i < model_.count; i++) {
            let row = model_.get(i);
            if (row.saveToDisk) {
                notifications["notifications"].push({
                                       "title": row.title,
                                       "description": row.description,
                                       "to": row.to,
                                       "iconSource": row.iconSource,
                                       "level": row.level,
                                       "date": row.date.toLocaleString(Qt.locale())
                                   });
            }
        }

        notificationSettings.writeFile("savedNotifications.json", notifications)
    }

    function addSavedNotifications() {
        let savedNotifications = notificationSettings.readFile("savedNotifications.json");

        if (!savedNotifications.hasOwnProperty("notifications")) {
            return;
        } else {
            savedNotifications = savedNotifications["notifications"];
        }

        for (let i = 0; i < savedNotifications.length; i++) {
            const notification = {
                "title": savedNotifications[i].title,
                "description": savedNotifications[i].description,
                "level": savedNotifications[i].level,
                "to": savedNotifications[i].to,
                "hidden": true,
                "date": Date.fromLocaleString(Qt.locale(), savedNotifications[i].date),
                "timeout": 0,
                "iconSource": savedNotifications[i].iconSource,
                "saveToDisk": true,
                "singleton": false,
                "actions": [],
                "uuid": ""
            };
            model_.append(notification)
        }
    }

    function destroyNotification(uuid){
        if(uuid !== null && uuid !== ""){
            for(var i = 0;i < model_.count; i++){
                if(model_.get(i).uuid === uuid){
                    model_.remove(i)
                    break
                }
            }
        }
    }

    function create_UUID(){
        var dt = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c =='x' ? r :(r&0x3|0x8)).toString(16);
        });
        return uuid;
    }
}
