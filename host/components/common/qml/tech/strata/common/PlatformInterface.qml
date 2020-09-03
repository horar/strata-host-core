import QtQuick 2.12

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

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
