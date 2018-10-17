import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------
    // Notification Messages
    //
    // define and document incoming notification messages
    //  the properties of the message must match with the UI elements using them
    //  document all messages to clearly indicate to the UI layer proper names


    property var entice_rgb: {
        "string" : "",
        "value" : ""
    }


    // -------------------  end notification messages


    // -------------------
    // Commands
    //


    // @f set_rgb_color
    // {"cmd": "set_rbg_color","payload": {"strip1": "0x00FF0000","strip2": "0x00FF0000"}}
    property var set_rgb_color : ({
                                    "cmd" : "set_rbg_color",
                                    "payload": {
                                          "strip":"<value>",
                                    },

                                    // Update will set and send in one shot
                                    update: function (rgb_strip1, rgb_strip2) {
                                        this.set(speed)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (rgb_strip1, rgb_strip2) {
                                        console.log("rgb1=", rgb_strip1, ", rgb2=", rgb_strip2)
                                        this.payload.strip1 = rgb_strip1;
                                        this.payload.strip2 = rgb_strip2;
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })

    // -------------------  end commands

    // NOTE:
    //  All internal property names for PlatformInterface must avoid name collisions with notification/cmd message properties.
    //   naming convention to avoid name collisions;
    // property var _name


    // -------------------------------------------------------------------
    // Connect to CoreInterface notification signals
    //
    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }
}
