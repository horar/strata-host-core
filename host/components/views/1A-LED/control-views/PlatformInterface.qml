import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    //TELEMETRY

    property var telemetry : {
        "lcsm": "0.000",
        "gcsm": "0.00",
        "vin": "0.000",
        "vout": "0.000",
        "vin_conn": "0.000",
        "vled": "0.000",
        "temperature": 23.0
    }


    //INTERRUPTS

    property var int_os_alert: {
        "value" : false
    }



    property var foldback_status: ({
                                 "value": "off"
                             })


    property var control_states: ({
                                      "enable":"off",
                                      "dim_en_duty":"0.0",
                                      "dim_en_freq":"1.000",
                                      "led_config":"3 LEDs",
                                      "os_alert_threshold":"80"
                                  })

    //ENABLE/DISABLE LED DRIVER

    property var set_enable : ({
                                   "cmd" : "set_enable",
                                   "payload": {
                                       "value": "on" // default value
                                   },

                                   update: function (value) {
                                       this.set(value)
                                       this.send(this)
                                   },
                                   set: function (value) {
                                       this.payload.value = value
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }
                               })

    //DIM#_EN SETTINGS

    property var dim_en_duty_state: {
        "value" : 0.0
    }

    property var set_dim_en_duty : ({
                                        "cmd" : "set_dim_en_duty",
                                        "payload": {
                                            "value": 0.0 // default value
                                        },

                                        update: function (value) {
                                            this.set(value)
                                            this.send(this)
                                        },
                                        set: function (value) {
                                            this.payload.value = value
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var set_dim_en_freq : ({
                                        "cmd" : "set_dim_en_freq",
                                        "payload": {
                                            "value": 1 // default value
                                        },

                                        update: function (value) {
                                            this.set(value)
                                            this.send(this)
                                        },
                                        set: function (value) {
                                            this.payload.value = value
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    //SET LED CONFIGURATION

    property var set_led : ({
                                "cmd" : "set_led_config",
                                "payload": {
                                    "value":"3_leds" // default value
                                },

                                update: function (value) {
                                    this.set(value)
                                    this.send(this)
                                },
                                set: function (value) {
                                    this.payload.value = value
                                },
                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }
                            })

    //SET OS#/ALERT# THRESHOLD

    property var set_os_alert : ({
                                "cmd" : "set_os_alert",
                                "payload": {
                                    "value": 1103 // default value
                                },

                                update: function (value) {
                                    this.set(value)
                                    this.send(this)
                                },
                                set: function (value) {
                                    this.payload.value = value
                                },
                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }
                            })


   //Get All States

    property var  get_all_states: ({

                                       "cmd":"get_all_states",
                                       update: function () {
                                           CorePlatformInterface.send(this)
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
