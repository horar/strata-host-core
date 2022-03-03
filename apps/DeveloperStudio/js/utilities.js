/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
