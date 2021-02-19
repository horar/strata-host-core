/* This file will control notifications from a central source */
.import tech.strata.notifications 1.0 as PlatformNotifications
var notificationMap = {}
var uuidMap = {}
var signals = Qt.createQmlObject('import QtQuick 2.0; QtObject { signal executeAction(string key,string type)}', Qt.application, 'NotificationSignals');

function createNotification(msg,level = PlatformNotifications.Notifications.Info,reciever = "all",context = {},key) {
   PlatformNotifications.Notifications.createNotification(msg,level,reciever,context,key)
}

function destroyNotifications(key_ = null) {
        if (key_ === null) {
            for (const [key] in Object.keys(notificationMap)) {
                const notifications = PlatformNotifications.Notifications.getNotifications(key)
                unRegisterNotificationActions(key)
                notifications.forEach(notification => PlatformNotifications.Notifications.deleteNotification(notification))
            }
        } else {
            const notifications = PlatformNotifications.Notifications.getNotifications(key_)
            unRegisterNotificationActions(key_)
            notifications.forEach(notification => PlatformNotifications.Notifications.deleteNotification(notification))
            }
        }


function unRegisterNotificationActions(key) {
    for(var i = 0; i < notificationMap[key].length; i++){
        delete notificationMap[key][i]
    }
    delete notificationMap[key]
}

function createDynamicNotifications(actions) {
    notificationMap[actions.key] = []
    for (var i = 0; i < actions.data.length; i++) {
        notificationMap[actions.key][i] = Qt.createQmlObject(`import QtQuick.Controls 2.12; Action {}`,Qt.application, `PlatformNotifications${i}`)
        notificationMap[actions.key][i].text = actions["data"][i].text
        const actionType = actions["data"][i].action
        const actionKey = actions.key
        notificationMap[actions.key][i].triggered.connect(function(){signals.executeAction(actionKey,actionType)})
    }
}

function getNotificationActions(key){
    return notificationMap[key]
}
