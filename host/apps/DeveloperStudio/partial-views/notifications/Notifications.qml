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

    onRowsAboutToBeRemoved: {
        let row = get(first);

        // Delete the title when the row is about to get deleted
        _notificationTitles.delete(get(first).title)
    }

    Component.onDestruction: {
        // Save the open notifications to disk on close
        let notifications = [];
        for (let i = 0; i < count; i++) {
            let row = get(i);
            if (row.saveToDisk) {
                notifications.push({
                                       "title": row.title,
                                       "description": row.description,
                                       "level": row.level,
                                       "date": row.date.toLocaleString()
                                   });
            }
        }

        notificationSettings.writeFile("savedNotifications", notifications)
    }

    /**
     * Function: createNotification
     * Description: creates and appends a notification to the list of notifications
     * Parameters:
        - title: The notification title
        - description: The notification description
        - level: The notification importance level (0, 1, 2) (Info, Warn, Critical)
        - actions: A list of Action objects that correspond to each button in the notification
        - notifyAllUsers: Whether to notify all users on the system // TODO
        - saveToDisk: Whether to save the notification to disk
        - singleton: Only allow one notification with this title to be exposed to the user
     **/
    function createNotification(title, description, level, actions = [], notifyAllUsers = false, saveToDisk = false, singleton = false) {
        if (_notificationTitles.has(title)) {
            return false;
        }

        let notification = {
            "title": title,
            "description": description,
            "level": level,
            "date": new Date(),
            "timeout": (level === 2 ? 0 : 5000), // Set the timeout to 0 if it is an error notification
            "notifyAllUsers": notifyAllUsers,
            "saveToDisk": saveToDisk,
            "singleton": singleton,
            "actions": actions.map((action) => ({"action": action}))
        };

        append(notification);
        _notificationTitles.add(title);
        return true;
    }

    SGUserSettings {
        id: notificationSettings
        user: NavigationControl.context.user_id
        classId: "notifications"
    }
}
