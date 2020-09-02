import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // TELEMETRY Notificatioreceive from MCU (same variables)

    property var  get_measurement_value: ({

                                              "cmd":"get_measurement_value",
                                              update: function () {
                                                  CorePlatformInterface.send(this)
                                              },
                                              send: function () { CorePlatformInterface.send(this) },
                                              show: function () { CorePlatformInterface.show(this) }
                                          })


    property var telemetry : {
        "cell_voltage": "",
        "cell_temp": "",
        "total_time":0,
        "log_indicator": "black",
        "onboard_indicator": "black"
    }

    // Receive value 1  LEDS On/Off Controller commands in GUI send black/off or Red
    property var control_states: ({
                                      "measurement":"stop",
                                      "onboard_load_en":"off",
                                      "load_current":750,
                                      "charge_volt":4.35,
                                      "cut_off_volt":2800,
                                      "b_constant":3380,
                                      "apt":30,
                                      "est_test_time":0,
                                      "log_interval":1

                                  })
    //Receive value 2
    property var int_os_alert: ({
                                    "cut_off_volt":"black",
                                    "over_volt":"black",
                                    "over_current":"2000",
                                    "over_temp":"black",
                                    "double_time":"black",
                                    "no_battery":"black"
                                })

    //value 2
    property var set_measurement : ({
                                        "cmd" : "set_measurement",
                                        "payload": {
                                            "value": "stop" // default value
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
    //value 2
    property var set_load_current : ({
                                         "cmd" : "set_load_current",
                                         "payload": {
                                             "value": 3000 //
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
    //value3
    property var set_onboard_load_en : ({
                                            "cmd" : "set_onboard_load_en",
                                            "payload": {
                                                "value": "off" // default value
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
    //value4
    property var set_charge_volt : ({
                                        "cmd" : "set_charge_volt",
                                        "payload": {
                                            "value": 4.2 // default value
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
    //value5
    property var set_cut_off_volt : ({
                                         "cmd" : "set_cut_off_volt",
                                         "payload": {
                                             "value": 2800 // default value
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
    //value6
    property var set_b_constant : ({
                                       "cmd" : "set_b_constant",
                                       "payload": {
                                           "value": 3380 // default value
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
    //Value7
    property var set_apt : ({
                                "cmd" : "set_apt",
                                "payload": {
                                    "value": 32530 // default value
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
    //value8
    property var set_est_test_time : ({
                                          "cmd" : "set_est_test_time",
                                          "payload": {
                                              "value": 240 // default value
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
    property var set_log_interval : ({
                                         "cmd" : "set_log_interval",
                                         "payload": {
                                             "value": 3 // default value
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


    property var set_fg_initialize : ({
                                          "cmd" : "set_fg_initialize",
                                          "payload": {
                                              "value":"" // default value
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

    //SET EXT LED STATE
    property var set_ext_led_state : ({
                                          "cmd" : "set_ext_led_state",
                                          "payload": {
                                              "value":"disconnected" // default value
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
                                         "value": 110 // default value
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
