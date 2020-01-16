import QtQuick 2.12

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------------------------------------------------------
    // UI Control States
    //
    property var telemetry: {
        "vin_ext":"5.50",
        "vin_sb":"5.50",
        "vin_ldo":"5.00",
        "vout_ldo":"3.30",
        "iin":"85.0",
        "iout":"100.0",
        "pin_sb":"0.340",
        "pin_ldo":"0.500",
        "pout_ldo":"0.330",
        "ploss":"0.170",
        "eff_sb": "95.0",
        "eff_ldo":"66.0",
        "temperature":"24.2"
    }

    property var control_states: {
        "vin_sel":"external",	//Board input voltage selection
        "vin_ldo_sel":"bypass",	//LDO input voltage selection
        "vin_ldo_set":"5.00",	//LDO input voltage set value
        "vout_ldo_set":"3.30",	//LDO output voltage set value
        "load_en":true,		//Load enable
        "load_set":"100.0",	//Load current set value
        "ldo_sel":"TSOP",	//LDO package selection
        "ldo_en":"on",		//LDO enable
        "sb_mode":"pwm"	//Sync buck mode

    }

    property var vin_ldo_good: {
        "value" : true
    }


    property var int_pg_ldo: {
        "value" : true
    }

    property var int_ldo_temp: {
        "value" : true
    }

    // -------------------------------------------------------------------
    // Outgoing Commands
    //
    property var set_ldo_enable : ({
                                       "cmd" : "set_ldo_enable",
                                       "payload": {
                                           "value" : "on"
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
                                          "value":true // default value
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
                                       "value": "TSOP" // default value
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
                                           "value": "bypass" // default value
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
                                     "value": 100 // default value
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
                                       "value": "external" // default value
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
