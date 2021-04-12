import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    property var periodic_status: {
        "ADC_210": 0.00,        //current reading of NCS210R in mA (from 0 to 100.00)
        "ADC_211": 0.000,       //current reading of NCS211R in mA (from 0 to 2.000)
        "ADC_213": 0.00,        //current reading of NCS213R in A (from 0 to 30.00)
        "ADC_214": 0.000,       //current reading of NCS214R in A (from 0 to 1.000)
        "ADC_333": 0.0001000,   //current reading of NCS333R in uA (from 0 to 100.0)
        "ADC_VIN": 0 ,
        "max_input_voltage": "00.0",
        "max_OBL_current" : "00.0",
        "max_input_current": "00.0",
        "power_margin": "0",
    }

    property var led_status: {
        "CSA_max_reading": "off",
        "CSA_warning" : "",
        "interrupts": {
            "vs_int" : "off",
            "cs_int" : "off",
            "i_in_int" : "off"
        }
    }

    property var switch_enable_status: {
        "en_210": "off",        //on or off
        "en_211": "off",        //on or off
        "en_213": "off",        //on or off
        "en_214": "off",        //on or off
        "en_333": "off" ,       //on or off
        "i_in_max" : "30.5",
        "i_in_set" : "30.5",
        "low_load_en" : "off",
        "load_switch_status":""

    }

    property var error_notification: {
        "message" : ""
    }

    property var load_enable_status: {
        "low_load_en": "on",
        "mid_load_en": "off",
        "high_load_en": "off",
        "max_input_voltage" : "26",
        "max_current" : "100",
        "max_current_units" : "µA"
    }

    property var current_sense_interrupt: {
        "value":"no",
        "load_fault": "off",
        "error_msg": "",
        "switch_status": ""
    }

    property var voltage_sense_interrupt: {
        "value": "no",
        "load_fault": "off",
        "error_msg": "",
        "switch_status": ""
    }

    property var i_in_interrupt: {
        "value": "no",
        "load_fault": "off",
        "error_msg": "",
        "switch_status": ""
    }

    property var config_running: {
        "value" : false
    }

    property var cp_test_invalid: {
        "value" : false
    }

    property var initial_status: {
        "en_210": "on",                   //on or off
        "en_211": "off",                  //on or off
        "en_213": "off",                  //on or off
        "en_214": "off",                  //on or off
        "en_333": "off",                  //on or off
        "manual_mode": "auto",            //auto or manual
        "max_input_current": 30.5,          //float
        "max_input_voltage": 26.5,          //float
        "low_load_en": "off",             //on or off
        "mid_load_en": "off",             //on or off
        "high_load_en": "off",            //on or off
        "active_discharge": "on",
        "load_switch_status" :"freeze"
    }

    property var reset_status: {
        "switch_en_state":"off",// for the 5 en switches, turn them all off
        "switch_load_state":"off", // for the 3 load enable switches
        "load_fault" : "off",
        "switch_status" : "unfreeze",
        "load_switch_status":"freeze"

    }

    property var ad_status:{
        "status":"on"
    }


    property var set_initial_state_UI : ({
                                             "cmd" : "set_initial_state_UI",
                                             update: function () {
                                                 CorePlatformInterface.send(this)
                                             },

                                             set: function (enable) {
                                                 this.payload.enable = enable
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }
                                         })

    property var switch_enables : ({
                                       "cmd" : "set_switch_enables",
                                       "payload": {
                                           "enable": "210_on"	// default value
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

    property var load_enables : ({
                                     "cmd" : "set_load_enables",
                                     "payload": {
                                         "enable": "low_load_on"	// default value
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

    property var set_load_dac_load : ({
                                          "cmd" : "set_load_dac",
                                          "payload": {
                                              "load": "0"	// default value
                                          },

                                          update: function (load) {
                                              this.set(load)
                                              this.send(this)
                                          },
                                          set: function (load) {
                                              this.payload.load = load
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
                                      "voltage_set": "0"		// default value
                                  },

                                  update: function (voltage_set) {
                                      this.set(voltage_set)
                                      this.send(this)
                                  },
                                  set: function (voltage_set) {
                                      this.payload.voltage_set = voltage_set
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

    property var set_active_discharge : ({
                                             "cmd" : "set_active_discharge",
                                             "payload": {
                                                 "AD_set":"on"	// default value
                                             },

                                             update: function (AD_set) {
                                                 this.set(AD_set)
                                                 this.send(this)
                                             },
                                             set: function (AD_set) {
                                                 this.payload.AD_set = AD_set
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
