/* This file will control notifications from a central source */
.import tech.strata.notifications 1.0 as PlatformNotifications
var notificationMap = {}
var notificationSignalMap = {}
var notifications = PlatformNotifications.Notifications

function createNotification(msg,level = PlatformNotifications.Notifications.Info,reciever = "all",context = {},key = "general") {
   PlatformNotifications.Notifications.createNotification(msg,level,reciever,context,key)
    if(!notificationMap.hasOwnProperty(key)){
        notificationMap[key] = []
    }
}

function destroyNotifications(key_ = null) {
    if (key_ === null) {
        for (const [key] in Object.keys(notificationMap)) {
            const notifications = PlatformNotifications.Notifications.getNotifications(key)
            if(notifications !== undefined){
                unRegisterNotificationActions(key)
                notifications.forEach(notification =>  notification.level !== 2 ? PlatformNotifications.Notifications.deleteNotification(notification) : null)
            }
        }
    } else {
        const notifications = PlatformNotifications.Notifications.getNotifications(key_)
        if(notifications !== undefined){
            unRegisterNotificationActions(key_)
            notifications.forEach(notification => notification.level !== 2 ? PlatformNotifications.Notifications.deleteNotification(notification): null)
        }
    }
}

function unRegisterNotificationActions(key) {
    notificationMap[key].forEach(mapIndex => mapIndex.destroy())
    delete notificationMap[key]
}

function createDynamicNotificationActions(actions) {
    notificationMap[actions.key !== null ? actions.key : "general" ] = []
    for (var i = 0; i < actions.data.length; i++) {
        notificationMap[actions.key][i] = Qt.createQmlObject(`import QtQuick.Controls 2.12; Action {}`,Qt.application, `PlatformNotifications${i}.${actions.key}`)
        notificationMap[actions.key][i].text = actions["data"][i].text
        const action = actions["data"][i].action
        notificationMap[actions.key][i].triggered.connect(function(){action()})
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

function getTriggerFunction(key = "general", type = "generic"){
    if(notificationSignalMap[key] !== undefined){
    return notificationSignalMap[key][type]
    } else {
        return () => {}
    }
}


function createDynamicAction(key,type,text,func) {
    const object = {}
    Object.defineProperties(object,{
        text:{
            value: text
        },
        create:{
            value: setTriggerFunction(key,type,func)
        },
        action:{
            value: getTriggerFunction(key,type)
        }
    })
    Object.prototype.hasOwnProperty.call(object,"create")
    return object
}
