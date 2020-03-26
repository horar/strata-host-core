import QtQuick 2.12
import QtQuick.Window 2.3

import tech.strata.sgwidgets 1.0
import QtQuick.Controls 2.2
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface



    // -------------------------------------------------------------------
    // Incoming Notification Messages
    //
    // Define and document incoming notification messages here.
    //
    // The property name *must* match the associated notification value.
    // Sets UI Control State when changed.


    //
    property var toggle_light_notification : {
        "value": "on",     // or "off"
    }

    property var toggle_door_notification : {
         "value": "open",     // or "closed"
    }

    property var room_color_notification : {
         "color": "",     // or "green","purple","red"
    }

    property var debug_notification:{      //debug strings
            "message":""
    }

    //----------------------------------------------------------------------
    //
    //
    //      Commands
    //
    //----------------------------------------------------------------------


    property var toggle_light : ({
                                      "cmd" : "toggle_light",
                                      "payload": {
                                          "value":"on"
                                      },

                                      update: function (value) {
                                          this.set(avalue)
                                          this.send(this)
                                      },
                                      set: function (inValue) {
                                          this.payload.value = inValue;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var toggle_door : ({
                                      "cmd" : "toggle_door",
                                      "payload": {
                                          "value": "open",  // or "closed"
                                      },

                                      update: function (value) {
                                          this.set(value)
                                          this.send(this)
                                      },
                                      set: function (inValue) {
                                          this.payload.value = inValue;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var set_room_color : ({
                                      "cmd" : "set_room_color",
                                      "payload": {
                                          "color": "blue",  // or "green","purple","red"
                                      },

                                      update: function (value) {
                                          this.set(value)
                                          this.send(this)
                                      },
                                      set: function (inValue) {
                                          this.payload.value = inValue;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })


    // -------------------------------------------------------------------
    // Listens to message notifications coming from CoreInterface.cpp
    // Forward messages to core_platform_interface.js to process

    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }
}
