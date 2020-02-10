import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    property var periodic_status: {
        "ADC_210": 0.10000,        //current reading of NCS210R in mA (from 0 to 100.00)
        "ADC_211": 0.002000,       //current reading of NCS211R in mA (from 0 to 2.000)
        "ADC_213": 30.00,          //current reading of NCS213R in A (from 0 to 30.00)
        "ADC_214": 1.000,          //current reading of NCS214R in A (from 0 to 1.000)
        "ADC_333": 0.0001000,      //current reading of NCS333R in uA (from 0 to 100.0)
        "ADC_VIN": 26.00           //current reading of Vin in V (from 0 to 26.0)
    }

    property var current_sense_interrupt: {
        value: "good"
    }



    property var voltage_sense_interrupt: {

    }

    property var i_in_interrupt: {

    }

    property var config_running: {
        "value" : false
    }

    property var cp_test_invalid: {
        "value" : false
    }

    property var set_enable_210 : ({
                                       "cmd" : "set_enable_210",
                                       "payload": {
                                           "enable": "on"	// default value
                                       },

                                       update: function (enable) {
                                           this.set(enable)
                                           this.send(this)
                                       },
                                       set: function (enable) {
                                           this.payload.enable = enable
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var set_enable_211 : ({
                                       "cmd" : "set_enable_211",
                                       "payload": {
                                           "enable": "on"	// default value
                                       },

                                       update: function (enable) {
                                           this.set(enable)
                                           this.send(this)
                                       },
                                       set: function (enable) {
                                           this.payload.enable = enable
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var set_enable_213 : ({
                                       "cmd" : "set_enable_213",
                                       "payload": {
                                           "enable": "on"	// default value
                                       },

                                       update: function (enable) {
                                           this.set(enable)
                                           this.send(this)
                                       },
                                       set: function (enable) {
                                           this.payload.enable = enable
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var set_enable_214 : ({
                                       "cmd" : "set_enable_214",
                                       "payload": {
                                           "enable": "on"	// default value
                                       },

                                       update: function (enable) {
                                           this.set(enable)
                                           this.send(this)
                                       },
                                       set: function (enable) {
                                           this.payload.enable = enable
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var set_enable_333 : ({
                                       "cmd" : "set_enable_333",
                                       "payload": {
                                           "enable": "on"	// default value
                                       },

                                       update: function (enable) {
                                           this.set(enable)
                                           this.send(this)
                                       },
                                       set: function (enable) {
                                           this.payload.enable = enable
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var set_low_load_enable : ({
                                            "cmd" : "set_low_load_enable",
                                            "payload": {
                                                "enable": "on"	// default value
                                            },

                                            update: function (enable) {
                                                this.set(enable)
                                                this.send(this)
                                            },
                                            set: function (enable) {
                                                this.payload.enable = enable
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })
    property var set_mid_load_enable : ({
                                            "cmd" : "set_mid_load_enable",
                                            "payload": {
                                                "enable": "on"	// default value
                                            },

                                            update: function (enable) {
                                                this.set(enable)
                                                this.send(this)
                                            },
                                            set: function (enable) {
                                                this.payload.enable = enable
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var set_high_load_enable : ({
                                             "cmd" : "set_high_load_enable",
                                             "payload": {
                                                 "enable": "on"	// default value
                                             },

                                             update: function (enable) {
                                                 this.set(enable)
                                                 this.send(this)
                                             },
                                             set: function (enable) {
                                                 this.payload.enable = enable
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }
                                         })

    property var set_load_dac : ({
                                     "cmd" : "set_load_dac",
                                     "payload": {
                                         "load": "0"	// default value
                                     },

                                     update: function (enable) {
                                         this.set(enable)
                                         this.send(this)
                                     },
                                     set: function (enable) {
                                         this.payload.enable = enable
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }
                                 })

    property var set_mode : ({
                                 "cmd" : "set_mode",
                                 "payload": {
                                     "mode": "auto"		// default value
                                 },

                                 update: function (mode) {
                                     this.set(mode)
                                     this.send(this)
                                 },
                                 set: function (mode) {
                                     this.payload.mode = mode
                                 },
                                 send: function () { CorePlatformInterface.send(this) },
                                 show: function () { CorePlatformInterface.show(this) }
                             })

    property var set_v_set : ({
                                  "cmd" : "set_v_set",
                                  "payload": {
                                      "duty_cycle": "0"		// default value
                                  },

                                  update: function (duty_cycle) {
                                      this.set(duty_cycle)
                                      this.send(this)
                                  },
                                  set: function (duty_cycle) {
                                      this.payload.duty_cycle = duty_cycle
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })

    property var set_i_in_dac : ({
                                  "cmd" : "set_i_in_dac",
                                  "payload": {
                                      "i_in": "0"		// default value
                                  },

                                  update: function (i_in) {
                                      this.set(i_in)
                                      this.send(this)
                                  },
                                  set: function (i_in) {
                                      this.payload.i_in = i_in
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })

    property var set_recalibrate : ({
                                        "cmd" : "recalibrate",
                                        "payload": { },

                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var reset_board : ({
                                    "cmd" : "reset_board",
                                    "payload": { },

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
