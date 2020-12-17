.pragma library

.import "restclient.js" as Rest
.import QtQuick 2.0 as QtQuickModule

.import tech.strata.logger 1.0 as LoggerModule

/*
  Utilities: Dynamically load qml controls by qml filename
*/
function createObject(name, parent, context = {}) {
    console.log(LoggerModule.Logger.devStudioUtilityCategory, "createObject: name =", name)

    var component = Qt.createComponent(name, QtQuickModule.Component.PreferSynchronous, parent);

    if (component.status === QtQuickModule.Component.Error) {
        console.error(LoggerModule.Logger.devStudioUtilityCategory, "Cannot createComponent:", name, "; err=", component.errorString());
        return null
    }

    var object = component.createObject(parent, context)
    if (object === null) {
        console.error(LoggerModule.Logger.devStudioUtilityCategory, "Cannot createObject:", name);
    }

    return object;
}
