import QtQuick 2.12
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------------------------------------------------------
    // UI Control States
    //
    property var telemetry: {
        "vin_ext":"5.50",       //External input voltage
        "vin_sb":"5.50",        //Sync buck regulator input voltage
        "vin_ldo":"5.00",       //LDO input voltage
        "vout_ldo":"3.30",      //LDO output voltage
        "usb_5v":"5.00",        //USB 5V voltage
        "iin":"85.0",           //Board input current
        "iout":"100.0",         //LDO output current
        "vdiff":"2.70",         //LDO differential voltage
        "iin_ldo":"101.0",       //LDO input current
        "pin_sb":"0.340",       //Sync buck regulator input power
        "pin_ldo":"0.500",      //LDO input power
        "pout_ldo":"0.330",     //LDO output power
        "ploss":"0.170",        //LDO power loss
        "eff_sb": "95.0",       //Sync buck regulator efficiency
        "eff_ldo":"66.0",       //LDO efficiency
        "eff_tot":"62.7",       //Total system efficiency
        "board_temp":"24.2",	//Board temperature
        "ldo_temp":"23.0"     //LDO temperature
    }

    property var ldo_clim_thresh: {
        "value" : ""
    }

    property var tsd_thresh: {
        "value" : ""
    }

    property var control_states: {
        "vin_sel":"Off",        //Board input voltage selection
        "vin_ldo_sel":"Off",	//LDO input voltage selection
        "vin_ldo_set":"5.00",	//LDO input voltage set value
        "vout_ldo_set":"4.70",	//LDO output voltage set value
        "load_en":"off",		//Load enable
        "load_set":"0.0",       //Load current set value
        "ldo_sel":"TSOP5",      //LDO package selection
        "ldo_en": "off",         //LDO enable
        "vout_set_disabled":false //LDO output voltage adjustment disable state
    }

    property var int_status: {
        "int_pg_ldo":false,		//LDO Power Good
        "int_ldo_temp":false,	//LDO temp alert
        "vin_good":false,		//Valid board input voltage valid flag
        "vin_ldo_good":false,	//LDO input voltage valid flag
        "ldo_clim":true,		//LDO current limit reached flag
        "dropout":false,		//LDO dropout threshold notification
        "ocp":false,			//LDO short-circuit protection notification
        "tsd":false,            //LDO TSD notification
    }

    property var variant_name: {
        "value":"NCP164C_TSOP"
    }

    property var ext_load_status: {
        "value":false
    }

    property var config_running: {
        "value":false
    }

    property var sc_allowed: {
        "value":false
    }

    // -------------------------------------------------------------------
    // Outgoing Commands
    //
    property var set_isolate_ldo : ({
                                        "cmd" : "isolate_ldo",
                                        "payload": {
                                            "value" : true
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

    property var disable_vout_set : ({
                                         "cmd" : "disable_vout_set",
                                         "payload": {
                                             "value" : true
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


    property var set_load : ({
                                 "cmd" : "set_load",
                                 "payload": {
                                     "value" : 100
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


    property var enable_sc: ({
                                 "cmd" : "enable_sc",
                                 "payload": {  },

                                 update: function () {
                                     CorePlatformInterface.send(this)
                                 },
                                 send: function () { CorePlatformInterface.send(this) },
                                 show: function () { CorePlatformInterface.show(this) }
                             })

    property var reset_clim: ({
                                 "cmd" : "reset_clim",
                                 "payload": {  },

                                 update: function () {
                                     CorePlatformInterface.send(this)
                                 },
                                 send: function () { CorePlatformInterface.send(this) },
                                 show: function () { CorePlatformInterface.show(this) }
                             })

    property var reset_tsd: ({
                                 "cmd" : "reset_tsd",
                                 "payload": {  },

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
