/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    property int apiVersion: 1

    // -------------------------------------------------------------------
    // Listens to message notifications coming from CoreInterface.cpp
    // Forward messages to core_platform_interface.js to process
    // -------------------------------------------------------------------
    Connections {
        target: sdsModel.coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }

    // -------------------------
    // Pass-through Helper functions
    // -------------------------
    function send (command) {
        CorePlatformInterface.send(command)
    }

    function show (command) {
        CorePlatformInterface.show(command)
    }

    function injectDebugNotification(notification) {
        CorePlatformInterface.injectDebugNotification(notification)
    }
}
