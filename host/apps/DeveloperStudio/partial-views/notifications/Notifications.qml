pragma Singleton

import QtQuick 2.12
import QtQml 2.12
import QtQml.Models 2.12

import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl

ListModel {
    // Constants
    readonly property int info: 0
    readonly property int warning: 1
    readonly property int critical: 2

    property SGUserSettings notificationSettings: SGUserSettings {
        id: notificationSettings
        user: NavigationControl.context.user_id
        classId: "notifications"
    }

    Component.onDestruction: {
        // Save the open notifications to disk on close
        let notifications = { "notifications": [] };
        for (let i = 0; i < count; i++) {
            let row = get(i);
            if (row.saveToDisk) {
                notifications["notifications"].push({
                                       "title": row.title,
                                       "description": row.description,
                                       "level": row.level,
                                       "date": row.date.toLocaleString()
                                   });
            }
        }

        notificationSettings.writeFile("savedNotifications.json", notifications)
    }

    /**
     * Function: createNotification
     * Description: creates and appends a notification to the list of notifications
     * Parameters:
        - title (REQUIRED): The notification title
        - level (REQUIRED): The notification importance level (0, 1, 2) (Info, Warning, Critical)
        - additionalParameters: The object can include the following properties
            - description: The notification description
            - actions: A list of Action objects that correspond to each button in the notification
            - saveToDisk: Whether to save the notification to disk | DEFAULT: False
            - singleton: Only allow one notification with this title to be exposed to the user | DEFAULT: False
            - timeout: The timeout for the notification  (in milliseconds) | DEFAULT: 10000ms for non-critical notifications
            - iconSource: The icon's source url | DEFAULT: level === Notifications.info ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/exclamation-triangle.svg"
            - notifyAllUsers: Whether to notify all users on the system // TODO
     **/
    function createNotification(title, level, additionalParameters = {}) {
        const description = additionalParameters.hasOwnProperty("description") ? additionalParameters["description"] : "";
        const actions = additionalParameters.hasOwnProperty("actions") ? additionalParameters["actions"].map((action) => ({"action": action})) : [];
        const saveToDisk = additionalParameters.hasOwnProperty("saveToDisk") ? additionalParameters["saveToDisk"] : false;
        const singleton = additionalParameters.hasOwnProperty("singleton") ? additionalParameters["singleton"] : false;
        const notifyAllUsers = additionalParameters.hasOwnProperty("notifyAllUsers") ? additionalParameters["notifyAllUsers"] : false;
        const iconSource = additionalParameters.hasOwnProperty("iconSource") ? additionalParameters["iconSource"] : (level === Notifications.info ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/exclamation-triangle.svg");
        let timeout = additionalParameters.hasOwnProperty("timeout") ? additionalParameters["timeout"] : -1;

        if (timeout < 0) {
            if (level < 2) {
                timeout = 10000
            } else {
                timeout = 0
            }
        }

        let foundEntry = false;
        // Check the pre-existing entry in the model and see if that one is a singleton
        for (let i = 0; i < count; i++) {
            let notif = get(i);
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
            return false;
        }

        let notification = {
            "title": title,
            "description": description,
            "level": level,
            "date": new Date(),
            "timeout": timeout,
            "iconSource": iconSource,
            "notifyAllUsers": notifyAllUsers,
            "saveToDisk": saveToDisk,
            "singleton": singleton,
            "actions": actions
        };

        append(notification);
        return true;
    }
}
