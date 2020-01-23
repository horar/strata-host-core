import QtQuick 2.12

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------------------------------------------------------
    // UI Control States
    //
    property var telemetry: {
        "vin_ext":"0.00",
        "vin_sb":"0.00",
        "vin_ldo":"0.00",
        "vout_ldo":"0.00",
        "usb_5v":"0.00",
        "iin":"0.0",
        "iout":"0.0",
        "pin_sb":"0.000",
        "pin_ldo":"0.000",
        "pout_ldo":"0.000",
        "ploss":"0.000",
        "eff_sb": "0.0",
        "eff_ldo":"0.0",
        "temperature":"23.0"
    }

    property var control_states: {
        "vin_sel":"Off",        //Board input voltage selection
        "vin_ldo_sel":"Off",	//LDO input voltage selection
        "vin_ldo_set":"5.00",	//LDO input voltage set value
        "vout_ldo_set":"4.70",	//LDO output voltage set value
        "load_en":"off",		//Load enable
        "load_set":"0.0",       //Load current set value
        "ldo_sel":"TSOP5",      //LDO package selection
        "ldo_en":"off",         //LDO enable
        "sb_mode":"pwm"         //Sync buck mode

    }

    property var int_status: {
        "int_pg_ldo":false,		//LDO Power Good
        "int_pg_308":false,		//Output voltage monitor power good
        "int_ldo_temp":false,	//LDO temp alert
        "vin_good":false,		//Valid board input voltage valid flag
        "vin_ldo_good":false,	//LDO input voltage valid flag
        "ldo_clim":false		//LDO current limit reached flag
    }

//    property var vin_ldo_good: {
//        "value" : false
//    }

//    property var int_pg_ldo: {
//        "value" : false
//    }

//    property var int_ldo_temp: {
//        "value" : false
//    }

    // -------------------------------------------------------------------
    // Outgoing Commands
    //
    property var set_ldo_enable : ({
                                       "cmd" : "set_ldo_enable",
                                       "payload": {
                                           "value" : "off"
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
    property var set_vin_ldo : ({
                                    "cmd" : "set_vin_ldo",
                                    "payload": {
                                        "value": 5.0 // default value
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

    property var ext_load_conn : ({
                                      "cmd" : "ext_load_conn",
                                      "payload": {
                                          "value": false // default value
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


    property var select_ldo : ({
                                   "cmd" : "select_ldo",
                                   "payload": {
                                       "value": "TSOP5" // default value
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




    property var select_vin_ldo : ({
                                       "cmd" : "select_vin_ldo",
                                       "payload": {
                                           "value": "Off" // default value
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


    property var set_load_enable : ({
                                        "cmd" : "set_load_enable",
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

    property var set_vout_ldo : ({
                                     "cmd" : "set_vout_ldo",
                                     "payload": {
                                         "value": 3.3 // default value
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

    property var set_load : ({
                                 "cmd" : "set_load",
                                 "payload": {
                                     "value": 0 // default value
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


    property var select_vin : ({
                                   "cmd" : "select_vin",
                                   "payload": {
                                       "value": "Off" // default value
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

    property var get_all_states: ({
                                      "cmd":"get_all_states",
                                      "payload": {},

                                      send: function () { CorePlatformInterface.send(this) }
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
