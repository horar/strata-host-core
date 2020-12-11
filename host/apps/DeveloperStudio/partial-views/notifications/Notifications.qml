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

    // _notificationTitles holds the Set of titles currently showing
    property var _notificationTitles: new Set()

    property SGUserSettings notificationSettings: SGUserSettings {
        id: notificationSettings
        user: NavigationControl.context.user_id
        classId: "notifications"
    }

    onRowsAboutToBeRemoved: {
        let row = get(first);

        // Delete the title when the row is about to get deleted
        _notificationTitles.delete(get(first).title)
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
        let description = additionalParameters.hasOwnProperty("description") ? additionalParameters["description"] : "";
        let actions = additionalParameters.hasOwnProperty("actions") ? additionalParameters["actions"].map((action) => ({"action": action})) : [];
        let saveToDisk = additionalParameters.hasOwnProperty("saveToDisk") ? additionalParameters["saveToDisk"] : false;
        let singleton = additionalParameters.hasOwnProperty("singleton") ? additionalParameters["singleton"] : false;
        let notifyAllUsers = additionalParameters.hasOwnProperty("notifyAllUsers") ? additionalParameters["notifyAllUsers"] : false;
        let timeout = additionalParameters.hasOwnProperty("timeout") ? additionalParameters["timeout"] : -1;
        let iconSource = additionalParameters.hasOwnProperty("iconSource") ? additionalParameters["iconSource"] : (level === Notifications.info ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/exclamation-triangle.svg");

        if (timeout < 0) {
            if (level < 2) {
                timeout = 10000
            } else {
                timeout = 0
            }
        }

        if (singleton && _notificationTitles.has(title)) {
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
        _notificationTitles.add(title);
        return true;
    }
}
