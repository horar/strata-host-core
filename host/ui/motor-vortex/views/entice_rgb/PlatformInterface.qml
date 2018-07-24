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


    /*    // DEBUG - TODO: Faller - Remove before merging back to Dev
    Window {
        id: debug
        visible: true
        width: 200
        height: 200

        // This button sends 2 notifications in 1 JSON, future possible implementation
        Button {
            id: button1
            text: "send pi_stats and voltage"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                                        "input_voltage_notification": {
                                            "vin": '+ (Math.random()*5+10).toFixed(2) +'
                                        },
                                        "pi_stats": {
                                            "speed_target": 3216,
                                            "current_speed": '+ (Math.random()*2000+3000).toFixed(0) +',
                                            "error": -1104,
                                            "sum": -0.01,
                                            "duty_now": 0.67,
                                            "mode": "manual"
                                        }
                                    }')
            }
        }

        Button {
            id: button2
            anchors { top: button1.bottom }
            text: "send vin"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                    "value":"pi_stats",
                    "payload":{
                                "speed_target":3216,
                                "current_speed": '+ (Math.random()*2000+3000).toFixed(0) +',
                                "error":-1104,
                                "sum":-0.01,
                                "duty_now":0.67,
                                "mode":"manual"
                               }
                             }')
            }
        }
        Button {
            anchors { top: button2.bottom }
            text: "send"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"input_voltage_notification",
                            "payload":{
                                     "vin":'+ (Math.random()*5+10).toFixed(2) +'
                            }
                    }
            ')
            }
        }
    }*/
}
