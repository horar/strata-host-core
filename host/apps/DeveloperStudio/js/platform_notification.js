/* This file will control notifications from a central source */
.import tech.strata.notifications 1.0 as PlatformNotifications
var notificationMap = {}
var notificationSignalMap = {}
var notifications = PlatformNotifications.Notifications

function createNotification(msg,level = PlatformNotifications.Notifications.Info,reciever = "all",context = {},key = "general") {
   PlatformNotifications.Notifications.createNotification(msg,level,reciever,context,key)
}

function destroyNotifications(key_ = null) {
    if (key_ === null) {
        for (const [key] in Object.keys(notificationMap)) {
            const currentNotifications = PlatformNotifications.Notifications.getNotifications(key)
            unRegisterNotificationActions(key)
            if(currentNotifications !== undefined){
                currentNotifications.forEach(notification =>  notification.level === 2 ? PlatformNotifications.Notifications.deleteNotification(notification) : null)
            }
        }
    } else {
        const currentNotifications = PlatformNotifications.Notifications.getNotifications(key_)
        unRegisterNotificationActions(key_)
        if(currentNotifications !== undefined){
            currentNotifications.forEach(notification => notification.level === 2 ? PlatformNotifications.Notifications.deleteNotification(notification): null)
        }
    }
}


function unRegisterNotificationActions(key) {
    notificationMap[key].forEach(mapIndex => delete mapIndex)
    delete notificationMap[key]
}

function createDynamicNotifications(actions) {
    notificationMap[actions.key !== null ? actions.key : "general" ] = []
    for (var i = 0; i < actions.data.length; i++) {
        notificationMap[actions.key][i] = Qt.createQmlObject(`import QtQuick.Controls 2.12; Action {}`,Qt.application, `PlatformNotifications${i}.${actions.key}`)
        notificationMap[actions.key][i].text = actions["data"][i].text
        const actionType = actions["data"][i].action
        const actionKey = actions.key
        notificationMap[actions.key][i].triggered.connect(function(){notificationSignalMap[actionKey][actionType]()})
    }
}

function getNotificationActions(key){
    return notificationMap[key]
}

function setTriggerFunction(key = "general",type ="generic",func = function(){}){
    if(notificationSignalMap[key] === undefined){
        notificationSignalMap[key] = {}
    }
    notificationSignalMap[key][type] = func
}

