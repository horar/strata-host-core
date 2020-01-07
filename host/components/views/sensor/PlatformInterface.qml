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

    // @notification get_sensor_type
    // @description: read values
    //
    property var get_sensor_type: {
        "type":""
    }

    property var nct72_one_shot: {
        "caption":"One-shot",
        "value":"",
        "state":"enabled",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_busy: {
        "caption":"One-shot",
        "value":"",
        "state":"enabled",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_therm: {
        "caption":"THERM",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_rthrm: {
        "caption":"THERM",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }
    
    property var nct72_rlow: {
        "caption":"RLOW",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_rhigh: {
        "caption":"RLOW",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_open: {
        "caption":"RLOW",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_lthrm: {
        "caption":"RLOW",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_llow: {
        "caption":"RLOW",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_lhigh: {
        "caption":"RLOW",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_mode: {
        "caption":"Mode",
        "value":"Run",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_alert: {
        "caption":"Alert",
        "value":"Enabled",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_pin6: {
        "caption":"Pin 6",
        "value":"Enabled",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_range: {
        "caption":"Range",
        "value":"0_127",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_conv_rate: {
        "caption":"Conversion Rate",
        "value":"0_127",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_pwm_temp_remote: {
        "caption":"Conversion Rate",
        "value":"40",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_pwm_temp_local: {
        "caption":"Conversion Rate",
        "value":"40",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_remote_low_limit_frac: {
        "caption":"",
        "value":"0.00",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_remote_high_limit_frac: {
        "caption":"",
        "value":"0.00",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_remote_offset_frac: {
        "caption":"",
        "value":"0.00",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_remote_high_limit: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_remote_offset: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_remote_therm_limit: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_local_low_limit: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_local_high_limit: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_local_therm_limit: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_therm_hyst: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_man_id: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_remote_temp: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }

    property var nct72_local_temp: {
        "caption":"",
        "value":"",
        "state":"enabled",
        "values":["0.00","0.25","0.50","0.75"],
        "scales":[0.00,0.00,0.00]
    }





    property var lc717a10ar_cin_act_touch: {
        "cin": [0,0,0,0,0,0,0,0]
    }
    property var lc717a10ar_cin_act_proximity: {
        "cin": [0,0,0,0]
    }

    property var lc717a10ar_reset: {
        "status": ""
    }




    property var nct72_get_config: {
        "RANGE":0,
        "ALERT_THERM2":0,
        "RUN_STOP":0,
        "MASK1":0,
        "byte":0
    }

    property var nct72_get_conv_rate: {
        "conv_rate":"62.5 ms"
    }

    // external low limit get
    property var nct72_get_ext_low_lim: {
        "integer":0,
        "fraction":"0"
    }

    // external high limit get
    //    property var nct72_get_ext_high_lim: {
    //        "integer":0,
    //        "fraction":"0"
    //    }

    // internal low limit get
    property var nct72_get_int_low_lim: {
        "value":0
    }

    // internal high limit get
    property var nct72_get_int_high_lim: {
        "value": 10
    }

    property var nct72_int_temp: {
        "THERM":false,
        "ALERT":false,
        "THERM2": false
    }

    property var nct72_get_cons_alert: {
        "cons_alert":3
    }

    property var nct72_get_man_id: {
        "id":65
    }

    property var nct72_get_therm_hyst: {
        "hyst":10
    }

    property var nct72_get_therm_limits: {
        "external":108,
        "internal":85
    }

    property var nct72_get_ext_offset: {
        "integer":0,
        "fraction":"0"
    }

    property var nct72_remote_low_limit: {
        "caption":"Remote Low Limit:",
        "value":"10",
        "state":"enabled",
        "scales":[127.00,0.00,0.25]
    }

    property var nct72_remote_low_limit_caption: {
        "caption":"Remote Low Limit:"
    }

    //    property var nct72_remote_low_limit_value: {
    //        "value":"20"
    //    }

    property var nct72_remote_low_limit_state: {
        "state":"disabled"
    }

    property var nct72_alert_therm2: {
        "caption":"ALERT",
        "value":"",
        "state":"alert_therm2_state"
    }

    property var nct72_alert_therm2_caption: {
        "caption":"ALERT"
    }

    property var nct72_alert_therm2_state: {
        "state":"ALERT"
    }

    //ALERT, THERM, or THERM2 Interrupt Notification

    property var nct72_therm_value: {
        "value" : "1"
    }

    property var nct72_alert_therm2_value: {
        "value" : "1"
    }

    property var nct72_cons_alert: {
        "caption":"Consecutive ALERTs:",
        "value":"ardvark",
        "state":"enabled",
        "values":["monkey","cat","dog","ardvark"]
    }

    property var nct72_cons_alert_caption: {
        "caption" : "Consecutive ALERTs:"
    }

    property var nct72_cons_alert_value: {
        "value" : "ardvark"
    }

    property var nct72_cons_alert_state: {
        "state" : "disabled"
    }

    property var nct72_cons_alert_values: {
        "values" : ["monkey","cat","dog","ardvark"]
    }


    //New notification implemented
    property var nct72_remote_temp_value: {
        "value":"25.750000"
    }

    property var nct72_local_temp_value: {
        "value":"26"
    }
    //
    property var nct72_lthrm_value: {
        "value":"1"
    }

    property var nct72_rthrm_value: {
        "value":"0"
    }

    property var nct72_open_value: {
        "value":"0"
    }

    property var nct72_rlow_value: {
        "value":"0"
    }

    property var nct72_rhigh_value: {
        "value":"0"
    }

    property var nct72_llow_value: {
        "value":"0"
    }

    property var nct72_lhigh_value: {
        "value":"0"
    }

    property var nct72_busy_value: {
        "value":"1"
    }

    property var nct72_remote_low_limit_scales: {
        "scales":[127.00,0.00,0.25]
    }

    property var nct72_remote_high_limit_scales: {
        "scales":[127.00,0.00,0.25]
    }

    property var nct72_local_low_limit_scales: {
        "scales":[127.00,0.00,0.25]
    }

    property var nct72_local_high_limit_scales: {
        "scales":[127.00,0.00,0.25]
    }

    //Light Sensor Commands

    //Periodic notification that returns Lux value for gauge
    property var light: {
        "caption":"Lux (lx)",
        "value":"2449",
        "state":"disabled",
        "values":[],
        "scales":["65536","0","1"]
    }


    property var light_caption: {
        "caption":"Lux (lx)"
    }

    property var light_value: {
        "value" : "1"
    }

    property var light_state: {
        "state" : "disabled"
    }

    property var light_scales: {
        "scales":["65536","0","1"]
    }







    property var light_manual_integ: {
        "caption": "Manual Integration",
        "value":"Stop",
        "state":"disabled_and_grayed_out",
        "values":["Start","Stop"],
        "scales":[]
    }


    property var light_manual_integ_caption: {
        "caption":"Manual Integration"
    }

    property var light_manual_integ_value: {
        "value": "Stop"
    }

    property var light_manual_integ_state: {
        "state":"disabled_and_grayed_out"
    }

    property var light_manual_integ_values: {
        "values":["Start","Stop"]
    }


    property var light_status: {
        "caption":"Status",
        "value":"Active",
        "state":"enabled",
        "values":["Active","Sleep"],
        "scales":[]
    }

    property var light_status_caption: {
        "caption":"Status"
    }

    property var light_status_value: {
        "value":"Active"
    }

    property var light_status_state: {
        "state":"enabled"
    }

    property var light_status_values: {
        "values":["Active","Sleep"]
    }


    property var light_integ_time: {
        "caption":"Integration Time",
        "value":"200ms",
        "state":"disabled_and_grayed_out",
        "values":["12.5ms","100ms","200ms","Manual"],
        "scales":[]
    }

    property var light_integ_time_caption: {
        "caption":"Integration Time"
    }

    property var light_integ_time_value: {
        "value":"200ms"
    }

    property var light_integ_time_state: {
        "state":"enabled"
    }

    property var light_integ_time_values: {
        "values":["12.5ms","100ms","200ms","Manual"]
    }

    property var light_gain: {
        "caption":"Gain",
        "value":"8",
        "state":"enabled",
        "values":["0.25","1","2","8"],
        "scales":[]
    }

    property var light_gain_caption: {
        "caption":"Gain"
    }

    property var light_gain_value: {
        "value" : "8"
    }

    property var light_gain_state: {
        "state" : "enabled"
    }

    property var light_gain_values: {
        "values":["0.25","1","2","8"]
    }

    property var light_sensitivity: {
        "caption":"Sensitivity (%)",
        "value":"98.412697",
        "state":"enabled",
        "values":[],
        "scales":["150","66.7","98.41"]
    }

    property var light_sensitivity_caption: {
        "caption":"Lux (lx)"
    }

    property var light_sensitivity_value: {
        "value" : "1"
    }

    property var light_sensitivity_state: {
        "state" : "enabled"
    }

    property var light_sensitivity_scales: {
        "scales":["65536","0","1"]
    }


    property var set_light_status: ({
                                        "cmd" : "light_status",
                                        "payload": {
                                            "value": false
                                        },
                                        update: function (value) {
                                            this.set(value)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (value) {
                                            this.payload.value = value;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var set_light_sensitivity: ({
                                             "cmd" : "light_sensitivity",
                                             "payload": {
                                                 "value": 100
                                             },
                                             update: function (value) {
                                                 this.set(value)
                                                 CorePlatformInterface.send(this)
                                             },
                                             set: function (value) {
                                                 this.payload.value = value;
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }
                                         })
    property var set_light_gain: ({
                                      "cmd" : "light_gain",
                                      "payload": {
                                          "value":"1"
                                      },
                                      update: function (value) {
                                          this.set(value)
                                          CorePlatformInterface.send(this)
                                      },
                                      set: function (value) {
                                          this.payload.value = value;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var set_light_integ_time: ({
                                            "cmd" : "light_integ_time",
                                            "payload": {
                                                "value":"12.5ms"
                                            },
                                            update: function (value) {
                                                this.set(value)
                                                CorePlatformInterface.send(this)
                                            },
                                            set: function (value) {
                                                this.payload.value = value;
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })


    property var set_light_manual_integ: ({
                                              "cmd" : "light_manual_integ",
                                              "payload": {
                                                  "value":false
                                              },
                                              update: function (value) {
                                                  this.set(value)
                                                  CorePlatformInterface.send(this)
                                              },
                                              set: function (value) {
                                                  this.payload.value = value;
                                              },
                                              send: function () { CorePlatformInterface.send(this) },
                                              show: function () { CorePlatformInterface.show(this) }
                                          })




    //New Commands

    property var nct72_control_props: ({
                                           "cmd":"nct72_control_props",
                                           update: function () {
                                               CorePlatformInterface.send(this)
                                           },
                                           send: function () { CorePlatformInterface.send(this) },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })



    //New Notification for touch
    property var touch_cin: {
        "act":[1,1,0,0,0,0,1,0],
        "data":[1,1,0,0,2,1,127,12],
        "err":[1,0,1,0,0,0,0,0]
    }

    //    property var touch_calerr: {
    //        "value":1
    //    }

    //    property var touch_syserr: {
    //        "value":0
    //    }

    //New Command for Touch
    //    property var touch_first_gain0_7_value: ({
    //                                           "cmd" : "touch_first_gain0_7",
    //                                           "payload": {
    //                                               "value":1600
    //                                           },
    //                                           update: function (value) {
    //                                               this.set(value)
    //                                               CorePlatformInterface.send(this)
    //                                           },
    //                                           set: function (value) {
    //                                               this.payload.value = value;
    //                                           },
    //                                           send: function () { CorePlatformInterface.send(this) },
    //                                           show: function () { CorePlatformInterface.show(this) }
    //                                       })


    //    property var touch_second_gain: ({
    //                                         "cmd" : "touch_second_gain",
    //                                         "payload": {
    //                                             "cin":0,
    //                                             "gain":1
    //                                         },
    //                                         update: function (cin,gain) {
    //                                             this.set(cin,gain)
    //                                             CorePlatformInterface.send(this)
    //                                         },
    //                                         set: function (cin,gain) {
    //                                             this.payload.cin = cin
    //                                             this.payload.gain = gain
    //                                         },
    //                                         send: function () { CorePlatformInterface.send(this) },
    //                                         show: function () { CorePlatformInterface.show(this) }
    //                                     })

    property var touch_reset: ({
                                   "cmd":"touch_hw_reset",
                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }
                               })

    //New Proximity Notification & Command
    property var proximity_cin: {
        "act":[0,0,1,0],
        "data":[1,1,6,1],
        "err":[1,1,0,0]
    }

    //Sensors 9-15 1st Gain
    //    property var touch_first_gain8_15: ({
    //                                            "cmd" : "touch_first_gain8_15",
    //                                            "payload": {
    //                                                "value":1600
    //                                            },
    //                                            update: function (value) {
    //                                                this.set(value)
    //                                                CorePlatformInterface.send(this)
    //                                            },
    //                                            set: function (value) {
    //                                                this.payload.value = value;
    //                                            },
    //                                            send: function () { CorePlatformInterface.send(this) },
    //                                            show: function () { CorePlatformInterface.show(this) }
    //                                        })


    // -------------------
    // Commands
    // TO SEND A COMMAND DO THE FOLLOWING:
    // EXAMPLE: To send PWM TEMPERATURE LOCAL: platformInterface.nct72_pwm_temp_local.update(0)

    property var nct72_pwm_temp_local_value:({
                                                 "cmd" : "nct72_pwm_temp_local_value",
                                                 "payload": {
                                                     "value": 80
                                                 },
                                                 update: function (value) {
                                                     this.set(value)
                                                     CorePlatformInterface.send(this)
                                                 },
                                                 set: function (value) {
                                                     this.payload.value = value;
                                                 },
                                                 send: function () { CorePlatformInterface.send(this) },
                                                 show: function () { CorePlatformInterface.show(this) }
                                             })
    // TO SEND A COMMAND DO THE FOLLOWING:
    // EXAMPLE: To send PWM TEMPERATURE REMOTE: platformInterface.nct72_pwm_temp_remote.update(0)

    property var nct72_pwm_temp_remote_value:({
                                                  "cmd" : "nct72_pwm_temp_remote_value",
                                                  "payload": {
                                                      "value": 80
                                                  },
                                                  update: function (value) {
                                                      this.set(value)
                                                      CorePlatformInterface.send(this)
                                                  },
                                                  set: function (value) {
                                                      this.payload.value = value;
                                                  },
                                                  send: function () { CorePlatformInterface.send(this) },
                                                  show: function () { CorePlatformInterface.show(this) }
                                              })


    // COMMAND: Config
    // Sets the temperature range and returns updated scales for certain limit sliders.
    property var nct72_range_value:({
                                        "cmd" : "nct72_range_value",
                                        "payload": {
                                            "value": "0_127"
                                        },
                                        update: function (value) {
                                            this.set(value)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (value) {
                                            this.payload.value = value;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var nct72_alert_therm2_ratioButton:({
                                                     "cmd" : "nct72_alert_therm2_value",
                                                     "payload": {
                                                         "value": "0"
                                                     },
                                                     update: function (value) {
                                                         this.set(value)
                                                         CorePlatformInterface.send(this)
                                                     },
                                                     set: function (value) {
                                                         this.payload.value = value;
                                                     },
                                                     send: function () { CorePlatformInterface.send(this) },
                                                     show: function () { CorePlatformInterface.show(this) }
                                                 })

    property var nct72_mode_value:({
                                       "cmd" : "nct72_mode_value",
                                       "payload": {
                                           "value": "Run"
                                       },
                                       update: function (value) {
                                           this.set(value)
                                           CorePlatformInterface.send(this)
                                       },
                                       set: function (value) {
                                           this.payload.value = value;
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var nct72_alert_value:({
                                        "cmd" : "nct72_alert_value",
                                        "payload": {
                                            "value": "Enabled"
                                        },
                                        update: function (value) {
                                            this.set(value)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (value) {
                                            this.payload.value = value;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })



    property var nct72_conv_rate_value:({
                                            "cmd" : "nct72_conv_rate_value",
                                            "payload": {
                                                "value":"62.5 ms"
                                            },
                                            update: function (value) {
                                                this.set(value)
                                                CorePlatformInterface.send(this)
                                            },
                                            set: function (value) {
                                                this.payload.value = value;
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })
    //NEW remote low limit
    property var nct72_remote_low_limit_value:({
                                                   "cmd" : "nct72_remote_low_limit_value",
                                                   "payload": {
                                                       "value":"-55"
                                                   },
                                                   update: function (value) {
                                                       this.set(value)
                                                       CorePlatformInterface.send(this)
                                                   },
                                                   set: function (value) {
                                                       this.payload.value = value;
                                                   },
                                                   send: function () { CorePlatformInterface.send(this) },
                                                   show: function () { CorePlatformInterface.show(this) }
                                               })

    property var nct72_remote_low_limit_frac_value:({
                                                        "cmd" : "nct72_remote_low_limit_frac_value",
                                                        "payload": {
                                                            "value":"0.25"
                                                        },
                                                        update: function (value) {
                                                            this.set(value)
                                                            CorePlatformInterface.send(this)
                                                        },
                                                        set: function (value) {
                                                            this.payload.value = value;
                                                        },
                                                        send: function () { CorePlatformInterface.send(this) },
                                                        show: function () { CorePlatformInterface.show(this) }
                                                    })

    //New Remote high limit
    property var nct72_remote_high_limit_value:({
                                                    "cmd" : "nct72_remote_high_limit_value",
                                                    "payload": {
                                                        "value":"100"
                                                    },
                                                    update: function (value) {
                                                        this.set(value)
                                                        CorePlatformInterface.send(this)
                                                    },
                                                    set: function (value) {
                                                        this.payload.value = value;
                                                    },
                                                    send: function () { CorePlatformInterface.send(this) },
                                                    show: function () { CorePlatformInterface.show(this) }
                                                })

    property var nct72_remote_high_limit_frac_value:({
                                                         "cmd" : "nct72_remote_high_limit_frac_value",
                                                         "payload": {
                                                             "value":"0.25"
                                                         },
                                                         update: function (value) {
                                                             this.set(value)
                                                             CorePlatformInterface.send(this)
                                                         },
                                                         set: function (value) {
                                                             this.payload.value = value;
                                                         },
                                                         send: function () { CorePlatformInterface.send(this) },
                                                         show: function () { CorePlatformInterface.show(this) }
                                                     })

    //local high and low limits
    property var nct72_local_low_limit_value:({
                                                  "cmd" : "nct72_local_low_limit_value",
                                                  "payload": {
                                                      "value":"-55"
                                                  },
                                                  update: function (value) {
                                                      this.set(value)
                                                      CorePlatformInterface.send(this)
                                                  },
                                                  set: function (value) {
                                                      this.payload.value = value;
                                                  },
                                                  send: function () { CorePlatformInterface.send(this) },
                                                  show: function () { CorePlatformInterface.show(this) }
                                              })

    property var nct72_local_high_limit_value:({
                                                   "cmd" : "nct72_local_high_limit_value",
                                                   "payload": {
                                                       "value":"95"
                                                   },
                                                   update: function (value) {
                                                       this.set(value)
                                                       CorePlatformInterface.send(this)
                                                   },
                                                   set: function (value) {
                                                       this.payload.value = value;
                                                   },
                                                   send: function () { CorePlatformInterface.send(this) },
                                                   show: function () { CorePlatformInterface.show(this) }
                                               })

    property var nct72_remote_therm_limit_value: ({
                                                      "cmd":"nct72_remote_therm_limit_value",
                                                      "payload": {
                                                          "value":"50"
                                                      },
                                                      update: function (value) {
                                                          this.set(value)
                                                          CorePlatformInterface.send(this)
                                                      },
                                                      set: function (value) {
                                                          this.payload.value = value;
                                                      },
                                                      show: function () { CorePlatformInterface.show(this) }
                                                  })
    property var nct72_local_therm_limit_value: ({
                                                     "cmd":"nct72_local_therm_limit_value",
                                                     "payload": {
                                                         "value":""
                                                     },
                                                     update: function (value) {
                                                         this.set(value)
                                                         CorePlatformInterface.send(this)
                                                     },
                                                     set: function (value) {
                                                         this.payload.value = value;
                                                     },
                                                     show: function () { CorePlatformInterface.show(this) }
                                                 })
    property var nct72_therm_hyst_value: ({
                                              "cmd":"nct72_therm_hyst_value",
                                              "payload": {
                                                  "value":""
                                              },
                                              update: function (value) {
                                                  this.set(value)
                                                  CorePlatformInterface.send(this)
                                              },
                                              set: function (value) {
                                                  this.payload.value = value;
                                              },
                                              show: function () { CorePlatformInterface.show(this) }
                                          })

    property var nct72_cons_alert_slider: ({
                                               "cmd":"nct72_cons_alert_value",
                                               "payload": {
                                                   "value":""
                                               },
                                               update: function (value) {
                                                   this.set(value)
                                                   CorePlatformInterface.send(this)
                                               },
                                               set: function (value) {
                                                   this.payload.value = value;
                                               },
                                               show: function () { CorePlatformInterface.show(this) }
                                           })





    //OLD commands
    // TO SYNCHRONIZE THE SPEED ON ALL THE VIEW DO THE FOLLOWING:
    // EXAMPLE: platformInterface.enabled

    //    property var set_sensor_type:({
    //                                      "cmd" : "set_sensor_type",
    //                                      "payload": {
    //                                          "sensor": ""
    //                                      },
    //                                      update: function (sensor) {
    //                                          this.set(sensor)
    //                                          CorePlatformInterface.send(this)
    //                                      },
    //                                      set: function (sensor) {
    //                                          this.payload.sensor = sensor;
    //                                      },
    //                                      send: function () { CorePlatformInterface.send(this) },
    //                                      show: function () { CorePlatformInterface.show(this) }

    //                                  })

    property var get_sensor_type_mode: ({

                                            "cmd":"get_sensor_type",
                                            update: function () {
                                                CorePlatformInterface.send(this)
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var reset_touch_mode: ({

                                        "cmd":"lc717a10ar_reset",
                                        update: function () {
                                            CorePlatformInterface.send(this)
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })


    property var get_light_lux: ({

                                     "cmd":"lv0104cs_get_light",
                                     update: function () {
                                         CorePlatformInterface.send(this)
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }
                                 })



    property var set_pwm_temp_ext: ({
                                        "cmd": "nct72_set_pwm_temp_ext",
                                        "payload": {
                                            "duty": 80,
                                            "period": 0.001
                                        },

                                        update: function (duty) {
                                            this.set(duty)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (duty) {
                                            this.payload.duty = duty;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }

                                    })

    //    property var get_nct72_config: ({
    //                                        "cmd":"nct72_get_config",
    //                                        update: function () {
    //                                            CorePlatformInterface.send(this)
    //                                        },
    //                                        send: function () { CorePlatformInterface.send(this) },
    //                                        show: function () { CorePlatformInterface.show(this) }

    //                                    })

    property var get_nct72_status: ({
                                        "cmd":"nct72_get_status",
                                        update: function () {
                                            CorePlatformInterface.send(this)
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }

                                    })

    property var set_pwm_temp_int: ({
                                        "cmd": "nct72_set_pwm_temp_int",
                                        "payload": {
                                            "duty": 80,
                                            "period": 0.001
                                        },

                                        update: function (duty) {
                                            this.set(duty)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (duty) {
                                            this.payload.duty = duty;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }


                                    })
    //    property var set_config_range: ({
    //                                        "cmd": "nct72_set_config_range",
    //                                        "payload": {
    //                                            "value":""
    //                                        },

    //                                        update: function (value) {
    //                                            this.set(value)
    //                                            CorePlatformInterface.send(this)
    //                                        },
    //                                        set: function (value) {
    //                                            this.payload.value = value;
    //                                        },
    //                                        send: function () { CorePlatformInterface.send(this) },
    //                                        show: function () { CorePlatformInterface.show(this) }
    //                                    })



    property var lv0104cs_setup_measurement: ({
                                                  "cmd": "lv0104cs_setup_measurement",
                                                  "payload": {
                                                      "mode":"",
                                                      "gain":"",
                                                      "integ":"",
                                                      "manual":""
                                                  },
                                                  update: function (mode,gain,integ,manual) {
                                                      this.set(mode,gain,integ,manual)
                                                      CorePlatformInterface.send(this)
                                                  },
                                                  set: function (mode,gain,integ,manual) {
                                                      this.payload.mode = mode;
                                                      this.payload.gain = gain;
                                                      this.payload.integ = integ;
                                                      this.payload.manual = manual;
                                                  },
                                                  send: function () { CorePlatformInterface.send(this) },
                                                  show: function () { CorePlatformInterface.show(this) }

                                              })



    //    property var set_config_alert_therm2 : ({
    //                                                "cmd": "nct72_set_config_alert_therm2",
    //                                                "payload": {
    //                                                    "value":""
    //                                                },

    //                                                update: function (value) {
    //                                                    this.set(value)
    //                                                    CorePlatformInterface.send(this)
    //                                                },
    //                                                set: function (value) {
    //                                                    this.payload.value = value;
    //                                                },
    //                                                send: function () { CorePlatformInterface.send(this) },
    //                                                show: function () { CorePlatformInterface.show(this) }
    //                                            })

    //    property var set_config_run_stop : ({
    //                                            "cmd": "nct72_set_config_run_stop",
    //                                            "payload": {
    //                                                "value":""
    //                                            },

    //                                            update: function (value) {
    //                                                this.set(value)
    //                                                CorePlatformInterface.send(this)
    //                                            },
    //                                            set: function (value) {
    //                                                this.payload.value = value;
    //                                            },
    //                                            send: function () { CorePlatformInterface.send(this) },
    //                                            show: function () { CorePlatformInterface.show(this) }
    //                                        })
    //    property var set_config_alert : ({
    //                                         "cmd": "nct72_set_config_alert",
    //                                         "payload": {
    //                                             "value":""
    //                                         },

    //                                         update: function (value) {
    //                                             this.set(value)
    //                                             CorePlatformInterface.send(this)
    //                                         },
    //                                         set: function (value) {
    //                                             this.payload.value = value;
    //                                         },
    //                                         send: function () { CorePlatformInterface.send(this) },
    //                                         show: function () { CorePlatformInterface.show(this) }
    //                                     })

    //Conversion rate
    //    property var set_conv_rate : ({
    //                                      "cmd": "nct72_set_conv_rate",
    //                                      "payload": {
    //                                          "value":""
    //                                      },

    //                                      update: function (value) {
    //                                          this.set(value)
    //                                          CorePlatformInterface.send(this)
    //                                      },
    //                                      set: function (value) {
    //                                          this.payload.value = value;
    //                                      },
    //                                      send: function () { CorePlatformInterface.send(this) },
    //                                      show: function () { CorePlatformInterface.show(this) }
    //                                  })

    property var get_conv_rate: ({
                                     "cmd":"nct72_get_conv_rate",
                                     update: function () {
                                         CorePlatformInterface.send(this)
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })
    //    property var get_ext_low_lim: ({
    //                                       "cmd":"nct72_get_ext_low_lim",
    //                                       update: function () {
    //                                           CorePlatformInterface.send(this)
    //                                       },
    //                                       send: function () { CorePlatformInterface.send(this) },
    //                                       show: function () { CorePlatformInterface.show(this) }
    //                                   })
    //    property var set_ext_low_lim_integer: ({
    //                                               "cmd":"nct72_set_ext_low_lim_integer",
    //                                               "payload": {
    //                                                   "value":""
    //                                               },

    //                                               update: function (value) {
    //                                                   this.set(value)
    //                                                   CorePlatformInterface.send(this)
    //                                               },
    //                                               set: function (value) {
    //                                                   this.payload.value = value;
    //                                               },
    //                                               send: function () { CorePlatformInterface.send(this) },
    //                                               show: function () { CorePlatformInterface.show(this) }
    //                                           })
    //    property var set_ext_low_lim_fraction: ({
    //                                                "cmd":"nct72_set_ext_low_lim_fraction",
    //                                                "payload": {
    //                                                    "value":""
    //                                                },

    //                                                update: function (value) {
    //                                                    this.set(value)
    //                                                    CorePlatformInterface.send(this)
    //                                                },
    //                                                set: function (value) {
    //                                                    this.payload.value = value;
    //                                                },
    //                                                send: function () { CorePlatformInterface.send(this) },
    //                                                show: function () { CorePlatformInterface.show(this) }
    //                                            })

    //// external high limit get
    //    property var get_ext_high_lim: ({
    //                                        "cmd":"nct72_get_ext_high_lim",
    //                                        update: function () {
    //                                            CorePlatformInterface.send(this)
    //                                        },
    //                                        send: function () { CorePlatformInterface.send(this) },
    //                                        show: function () { CorePlatformInterface.show(this) }
    //                                    })
    //    property var set_ext_high_lim_integer: ({
    //                                                "cmd":"nct72_set_ext_high_lim_integer",
    //                                                "payload": {
    //                                                    "value":""
    //                                                },

    //                                                update: function (value) {
    //                                                    this.set(value)
    //                                                    CorePlatformInterface.send(this)
    //                                                },
    //                                                set: function (value) {
    //                                                    this.payload.value = value;
    //                                                },
    //                                                send: function () { CorePlatformInterface.send(this) },
    //                                                show: function () { CorePlatformInterface.show(this) }
    //                                            })
    //    property var set_ext_high_lim_fraction: ({
    //                                                 "cmd":"nct72_set_ext_high_lim_fraction",
    //                                                 "payload": {
    //                                                     "value":""
    //                                                 },

    //                                                 update: function (value) {
    //                                                     this.set(value)
    //                                                     CorePlatformInterface.send(this)
    //                                                 },
    //                                                 set: function (value) {
    //                                                     this.payload.value = value;
    //                                                 },
    //                                                 send: function () { CorePlatformInterface.send(this) },
    //                                                 show: function () { CorePlatformInterface.show(this) }
    //                                             })



    //Consecutive ALERTs
    property var get_cons_alert: ({
                                      "cmd":"nct72_get_cons_alert",
                                      update: function () {
                                          CorePlatformInterface.send(this)
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var set_ext_low_lim: ({
                                       "cmd":"nct72_set_cons_alert",
                                       "payload": {
                                           "value":""
                                       },
                                       update: function (value) {
                                           this.set(value)
                                           CorePlatformInterface.send(this)
                                       },
                                       set: function (value) {
                                           this.payload.value = value;
                                       },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    //Manufacturers ID
    property var get_man_id: ({
                                  "cmd":"nct72_get_man_id",
                                  update: function () {
                                      CorePlatformInterface.send(this)
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })


    //Hysteresis
    //    property var get_therm_hyst: ({
    //                                      "cmd":"nct72_get_therm_hyst",
    //                                      update: function () {
    //                                          CorePlatformInterface.send(this)
    //                                      },
    //                                      send: function () { CorePlatformInterface.send(this) },
    //                                      show: function () { CorePlatformInterface.show(this) }
    //                                  })


    //    property var set_therm_hyst: ({
    //                                      "cmd":"nct72_set_therm_hyst",
    //                                      "payload": {
    //                                          "value":""
    //                                      },
    //                                      update: function (value) {
    //                                          this.set(value)
    //                                          CorePlatformInterface.send(this)
    //                                      },
    //                                      set: function (value) {
    //                                          this.payload.value = value;
    //                                      },
    //                                      show: function () { CorePlatformInterface.show(this) }
    //                                  })
    //Remote and Local THERM Limits
    property var get_therm_limits: ({
                                        "cmd":"nct72_get_therm_limits",
                                        update: function () {
                                            CorePlatformInterface.send(this)
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    //    property var set_ext_therm_limit: ({
    //                                           "cmd":"nct72_set_ext_therm_limit",
    //                                           "payload": {
    //                                               "value":""
    //                                           },
    //                                           update: function (value) {
    //                                               this.set(value)
    //                                               CorePlatformInterface.send(this)
    //                                           },
    //                                           set: function (value) {
    //                                               this.payload.value = value;
    //                                           },
    //                                           show: function () { CorePlatformInterface.show(this) }
    //                                       })
    //    property var set_int_therm_limit: ({
    //                                           "cmd":"nct72_set_int_therm_limit",
    //                                           "payload": {
    //                                               "value":""
    //                                           },
    //                                           update: function (value) {
    //                                               this.set(value)
    //                                               CorePlatformInterface.send(this)
    //                                           },
    //                                           set: function (value) {
    //                                               this.payload.value = value;
    //                                           },
    //                                           show: function () { CorePlatformInterface.show(this) }
    //                                       })

    //Remote Offset
    property var get_ext_offset: ({
                                      "cmd":"nct72_get_ext_offset",
                                      update: function () {
                                          CorePlatformInterface.send(this)
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var set_ext_offset_integer: ({
                                              "cmd":"nct72_set_ext_offset_integer",
                                              "payload": {
                                                  "value":""
                                              },
                                              update: function (value) {
                                                  this.set(value)
                                                  CorePlatformInterface.send(this)
                                              },
                                              set: function (value) {
                                                  this.payload.value = value;
                                              },
                                              show: function () { CorePlatformInterface.show(this) }
                                          })
    property var set_ext_offset_fraction: ({
                                               "cmd":"nct72_set_ext_offset_fraction",
                                               "payload": {
                                                   "value":""
                                               },
                                               update: function (value) {
                                                   this.set(value)
                                                   CorePlatformInterface.send(this)
                                               },
                                               set: function (value) {
                                                   this.payload.value = value;
                                               },
                                               show: function () { CorePlatformInterface.show(this) }
                                           })

    //    //One-shot
    property var one_shot: ({
                                "cmd":"nct72_one_shot",
                                update: function () {
                                    CorePlatformInterface.send(this)
                                },
                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }
                            })




    //    //internal low limit get
    //    property var get_int_low_lim: ({
    //                                       "cmd":"nct72_get_int_low_lim",
    //                                       update: function () {
    //                                           CorePlatformInterface.send(this)
    //                                       },
    //                                       send: function () { CorePlatformInterface.send(this) },
    //                                       show: function () { CorePlatformInterface.show(this) }
    //                                   })
    //    // internal low limit set
    //    property var set_int_low_lim: ({
    //                                       "cmd":"nct72_set_int_low_lim",
    //                                       "payload": {
    //                                           "value":""
    //                                       },
    //                                       update: function (value) {
    //                                           this.set(value)
    //                                           CorePlatformInterface.send(this)
    //                                       },
    //                                       set: function (value) {
    //                                           this.payload.value = value;
    //                                       },
    //                                       show: function () { CorePlatformInterface.show(this) }
    //                                   })

    //internal high limit get
    //    property var get_int_high_lim: ({
    //                                        "cmd":"nct72_get_int_high_lim",
    //                                        update: function () {
    //                                            CorePlatformInterface.send(this)
    //                                        },
    //                                        send: function () { CorePlatformInterface.send(this) },
    //                                        show: function () { CorePlatformInterface.show(this) }
    //                                    })
    //    property var set_int_high_lim: ({
    //                                        "cmd":"nct72_set_int_high_lim",
    //                                        "payload": {
    //                                            "value":""
    //                                        },
    //                                        update: function (value) {
    //                                            this.set(value)
    //                                            CorePlatformInterface.send(this)
    //                                        },
    //                                        set: function (value) {
    //                                            this.payload.value = value;
    //                                        },
    //                                        show: function () { CorePlatformInterface.show(this) }
    //                                    })



    //



    //----------------------------------LC717A10AR ----------Commands

    property var set_touch_mode_value: ({
                                        "cmd":"touch_mode",
                                        "payload": {
                                            "value":"Interval"
                                        },
                                        update: function (value) {
                                            this.set(value)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (value) {
                                            this.payload.value = value;
                                        },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var touch_average_count_value: ({
                                                 "cmd":"touch_average_count",
                                                 "payload": {
                                                     "value":"128"
                                                 },
                                                 update: function (value) {
                                                     this.set(value)
                                                     CorePlatformInterface.send(this)
                                                 },
                                                 set: function (value) {
                                                     this.payload.value = value;
                                                 },
                                                 show: function () { CorePlatformInterface.show(this) }
                                             })

    property var set_touch_filter_parameter1_value: ({
                                                     "cmd":"touch_filter_parameter1",
                                                     "payload": {
                                                         "value":"12"
                                                     },
                                                     update: function (value) {
                                                         this.set(value)
                                                         CorePlatformInterface.send(this)
                                                     },
                                                     set: function (value) {
                                                         this.payload.value = value;
                                                     },
                                                     show: function () { CorePlatformInterface.show(this) }
                                                 })

    property var touch_filter_parameter2_value: ({
                                                     "cmd":"touch_filter_parameter2",
                                                     "payload": {
                                                         "value":"0"
                                                     },
                                                     update: function (value) {
                                                         this.set(value)
                                                         CorePlatformInterface.send(this)
                                                     },
                                                     set: function (value) {
                                                         this.payload.value = value;
                                                     },
                                                     show: function () { CorePlatformInterface.show(this) }
                                                 })

    property var touch_dct1_value: ({
                                        "cmd":"touch_dct1",
                                        "payload": {
                                            "value":"1"
                                        },
                                        update: function (value) {
                                            this.set(value)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (value) {
                                            this.payload.value = value;
                                        },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })
    property var touch_dct2_value: ({
                                        "cmd":"touch_dct2",
                                        "payload": {
                                            "value":"1"
                                        },
                                        update: function (value) {
                                            this.set(value)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (value) {
                                            this.payload.value = value;
                                        },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var touch_sival_value: ({
                                         "cmd":"touch_sival",
                                         "payload": {
                                             "value":"5"
                                         },
                                         update: function (value) {
                                             this.set(value)
                                             CorePlatformInterface.send(this)
                                         },
                                         set: function (value) {
                                             this.payload.value = value;
                                         },
                                         show: function () { CorePlatformInterface.show(this) }
                                     })

    property var touch_lival_value: ({
                                         "cmd":"touch_lival",
                                         "payload": {
                                             "value":"100"
                                         },
                                         update: function (value) {
                                             this.set(value)
                                             CorePlatformInterface.send(this)
                                         },
                                         set: function (value) {
                                             this.payload.value = value;
                                         },
                                         show: function () { CorePlatformInterface.show(this) }
                                     })

    property var touch_dc_plus_value: ({
                                           "cmd":"touch_dc_plus",
                                           "payload": {
                                               "value":"5"
                                           },
                                           update: function (value) {
                                               this.set(value)
                                               CorePlatformInterface.send(this)
                                           },
                                           set: function (value) {
                                               this.payload.value = value;
                                           },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

    property var touch_dc_minus_value: ({
                                            "cmd":"touch_dc_minus",
                                            "payload": {
                                                "value":"5"
                                            },
                                            update: function (value) {
                                                this.set(value)
                                                CorePlatformInterface.send(this)
                                            },
                                            set: function (value) {
                                                this.payload.value = value;
                                            },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var touch_sc_cdac_value: ({
                                           "cmd":"touch_sc_cdac",
                                           "payload": {
                                               "value":"5"
                                           },
                                           update: function (value) {
                                               this.set(value)
                                               CorePlatformInterface.send(this)
                                           },
                                           set: function (value) {
                                               this.payload.value = value;
                                           },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

    property var touch_dc_mode_value: ({
                                           "cmd":"touch_dc_mode",
                                           "payload": {
                                               "value":"Threshold"
                                           },
                                           update: function (value) {
                                               this.set(value)
                                               CorePlatformInterface.send(this)
                                           },
                                           set: function (value) {
                                               this.payload.value = value;
                                           },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

    property var touch_off_thres_mode_value: ({
                                                  "cmd":"touch_off_thres_mode",
                                                  "payload": {
                                                      "value":"0"
                                                  },
                                                  update: function (value) {
                                                      this.set(value)
                                                      CorePlatformInterface.send(this)
                                                  },
                                                  set: function (value) {
                                                      this.payload.value = value;
                                                  },
                                                  show: function () { CorePlatformInterface.show(this) }
                                              })

    property var touch_cref0_7_value: ({
                                           "cmd":"touch_cref0_7",
                                           "payload": {
                                               "value":"CREF+CADD"
                                           },
                                           update: function (value) {
                                               this.set(value)
                                               CorePlatformInterface.send(this)
                                           },
                                           set: function (value) {
                                               this.payload.value = value;
                                           },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

    property var touch_cref8_15_value: ({
                                            "cmd":"touch_cref8_15",
                                            "payload": {
                                                "value":"CREF+CADD"
                                            },
                                            update: function (value) {
                                                this.set(value)
                                                CorePlatformInterface.send(this)
                                            },
                                            set: function (value) {
                                                this.payload.value = value;
                                            },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var touch_li_start_value: ({
                                            "cmd":"touch_li_start",
                                            "payload": {
                                                "value":"0"
                                            },
                                            update: function (value) {
                                                this.set(value)
                                                CorePlatformInterface.send(this)
                                            },
                                            set: function (value) {
                                                this.payload.value = value;
                                            },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var touch_first_gain0_7_value: ({
                                                 "cmd":"touch_first_gain0_7",
                                                 "payload": {
                                                     "value":"1600"
                                                 },
                                                 update: function (value) {
                                                     this.set(value)
                                                     CorePlatformInterface.send(this)
                                                 },
                                                 set: function (value) {
                                                     this.payload.value = value;
                                                 },
                                                 show: function () { CorePlatformInterface.show(this) }
                                             })

    property var touch_first_gain8_15_value: ({
                                                  "cmd":"touch_first_gain8_15",
                                                  "payload": {
                                                      "value":"1600"
                                                  },
                                                  update: function (value) {
                                                      this.set(value)
                                                      CorePlatformInterface.send(this)
                                                  },
                                                  set: function (value) {
                                                      this.payload.value = value;
                                                  },
                                                  show: function () { CorePlatformInterface.show(this) }
                                              })

    property var touch_second_gain_value: ({
                                               "cmd":"touch_second_gain",
                                               "payload": {
                                                   "cin":0,
                                                   "gain":1
                                               },
                                               update: function (cin,gain) {
                                                   this.set(cin,gain)
                                                   CorePlatformInterface.send(this)
                                               },
                                               set: function (cin,gain) {
                                                   this.payload.cin = cin
                                                   this.payload.gain = gain
                                               },
                                               send: function () { CorePlatformInterface.send(this) },
                                               show: function () { CorePlatformInterface.show(this) }
                                           })

    property var touch_cin_thres_value: ({
                                             "cmd":"touch_cin_en",
                                             "payload": {
                                                 "cin":0,
                                                 "thres":1
                                             },
                                             update: function (cin,thres) {
                                                 this.set(cin,thres)
                                                 CorePlatformInterface.send(this)
                                             },
                                             set: function (cin,thres) {
                                                 this.payload.cin = cin
                                                 this.payload.thres = thres
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }
                                         })

    property var touch_cin_en_value: ({
                                          "cmd":"touch_cin_en",
                                          "payload": {
                                              "cin":0,
                                              "enable":1
                                          },
                                          update: function (cin,enable) {
                                              this.set(cin,enable)
                                              CorePlatformInterface.send(this)
                                          },
                                          set: function (cin,enable) {
                                              this.payload.cin = cin
                                              this.payload.enable = enable
                                          },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }
                                      })

    property var touch_export_registers_value: ({
                                                    "cmd":"touch_export_registers",
                                                    update: function () {
                                                        CorePlatformInterface.send(this)
                                                    },
                                                    send: function () { CorePlatformInterface.send(this) },
                                                    show: function () { CorePlatformInterface.show(this) }
                                                })

    property var touch_sw_reset_value: ({
                                            "cmd":"touch_sw_reset",
                                            update: function () {
                                                CorePlatformInterface.send(this)
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var touch_hw_reset_value: ({
                                            "cmd":"touch_hw_reset",
                                            update: function () {
                                                CorePlatformInterface.send(this)
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var touch_wakeup_value: ({
                                          "cmd":"touch_wakeup",
                                          update: function () {
                                              CorePlatformInterface.send(this)
                                          },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }
                                      })


    //----------------------------------LC717A10AR ----------Notifications

    property var touch_mode: {
        "caption":"Mode",
        "value":"Sleep",
        "state":"enabled",
        "values":["Interval","Sleep"],
        "scales":[]
    }

    property var touch_mode_caption: {
         "caption":"Mode"
    }

    property var touch_mode_value: {
         "value":"Sleep"
    }

    property var touch_mode_state: {
        "state":"enabled"
    }

    property var touch_mode_values: {
        "values":["Interval","Sleep"]
    }

    property var touch_average_count: {
        "caption":"Average Count",
        "value":"128",
        "state":"enabled",
        "values":["8","16","32","64","128"],
        "scales":[]
    }


    property var touch_filter_parameter1: {
        "caption":"Filter Parameter 1",
        "value":"12",
        "state":"enabled",
        "values":["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"],
        "scales":[]
    }


    property var touch_filter_parameter1_caption: {
          "caption":"Filter Parameter 1"
    }

    property var touch_filter_parameter1_value: {
         "value":"12"
    }

    property var touch_filter_parameter1_state: {
         "state":"enabled"
    }

    property var touch_filter_parameter1_values: {
         "values":["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"]
    }



    property var touch_filter_parameter2: {
        "caption":"Filter Parameter 2",
        "value":"0",
        "state":"enabled",
        "values":["0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15"],
        "scales":[]
    }

    property var touch_dct1: {
        "caption":"Debounce Count (Off to On)",
        "value":"1",
        "state":"enabled",
        "values":[],
        "scales":["255","0","1"]
    }

    property var touch_dct2: {
        "caption":"Debounce Count (On to Off)",
        "value":"1",
        "state":"enabled",
        "values":[],
        "scales":["255","0","1"]
    }

    property var touch_sival: {
        "caption":"Short Interval Time (ms)",
        "value":"5",
        "state":"enabled",
        "values":[],
        "scales":["255","0","1"]
    }

    property var touch_lival: {
        "caption":"Long Interval Time (ms)",
        "value":"100",
        "state":"enabled",
        "values":[],
        "scales":["355","0","1"]
    }

    property var touch_si_dc_cyc: {
        "caption":"Short Interval Dyn Off Cal Cycles",
        "value":"4",
        "state":"enabled",
        "values":[],
        "scales":["355","0","1"]
    }

    property var touch_dc_plus: {
        "caption":"Dyn Off Cal Count Plus",
        "value":"1",
        "state":"enabled",
        "values":[],
        "scales":["255","0","1"]
    }

    property var touch_dc_minus: {
        "caption":"Dyn Off Cal Count Minus",
        "value":"1",
        "state":"enabled",
        "values":[],
        "scales":["255","0","1"]
    }

    property var touch_sc_cdac: {
        "caption":"Static Calibration CDAC (pF)",
        "value":"2",
        "state":"enabled",
        "values":["1","2","4"],
        "scales":[]
    }

    property var touch_dc_mode: {
        "caption":"Dyn Off Cal Mode",
        "value":"Threshold",
        "state":"enabled",
        "values":["Threshold","Enabled"],
        "scales":[]
    }

    property var touch_off_thres_mode: {
        "caption":"Offset Threshold",
        "value":"0.5 Peak",
        "state":"enabled",
        "values":["0.5 Peak","0.75 Peak"],
        "scales":[]
    }

    property var touch_cref0_7: {
        "caption":"CIN0-7 CREF",
        "value":"CREF+CADD",
        "state":"enabled",
        "values":["CREF+CADD","CREF"],
        "scales":[]
    }

    property var touch_cref8_15: {
        "caption":"CIN8-15 CREF",
        "value":"CREF",
        "state":"enabled",
        "values":["CREF+CADD","CREF"],
        "scales":[]
    }

    property var touch_li_start: {
        "caption":"Long Interval Start Intervals",
        "value":"24",
        "state":"enabled",
        "values":[],
        "scales":["1020","0","4"]
    }

    property var touch_first_gain0_7: {
        "caption":"CIN0-7 1st Gain (fF)",
        "value":"200",
        "state":"enabled",
        "values":["1600","1500","1400","1300","1200","1100","1000","900","800","700","600","500","400","300","200","100"],
        "scales":[]
    }
    property var touch_first_gain8_15: {
        "caption":"CIN8-15 1st Gain (fF)",
        "value":"1600",
        "state":"enabled",
        "values":["1600","1500","1400","1300","1200","1100","1000","900","800","700","600","500","400","300","200","100"],
        "scales":[]
    }

    property var touch_second_gain: {
        "caption":"2nd Gain",
        "value":"",
        "state":"enabled",
        "values":["5","5","5","5","5","5","5","5","5","5","5","5","13","10","6","3"],
        "scales":[]
    }

    property var touch_cin_thres: {
        "caption":"Threshold",
        "value":"",
        "state":"enabled",
        "values":["50","50","50","50","50","50","50","50","50","50","50","50","3","3","3","3"],
        "scales":[]
    }

    property var touch_cin_en: {
        "caption":"Gain",
        "value":"",
        "state":"enabled",
        "values":["0","1","1","1","1","1","1","1","1","1","1","1","0","0","0","0"],
        "scales":[]
    }


    property var touch_calerr: {
        "caption":"CALERR",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[]
    }

    property var touch_calerr_caption: {
        "caption":"CALERR"
    }

    property var touch_calerr_value: {
        "value":"0"
    }

    property var touch_calerr_state: {
        "state":"disabled_and_grayed_out"
    }




    property var touch_syserr: {
        "caption":"SYSERR",
        "value":"0",
        "state":"disabled_and_grayed_out",
        "values":[],
        "scales":[]
    }

    property var touch_syserr_caption: {
        "caption":"SYSERR"
    }

    property var touch_syserr_value: {
        "value":"0"
    }

    property var touch_syserr_state: {
        "state":"disabled_and_grayed_out"
    }

    //New sensor Type

    property var set_sensor_type:({
                                      "cmd" : "sensor",
                                      "payload": {
                                          "value": ""
                                      },
                                      update: function (value) {
                                          this.set(value)
                                          CorePlatformInterface.send(this)
                                      },
                                      set: function (value) {
                                          this.payload.value = value;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }

                                  })


    property var sensor_value: {
        "value": "touch"
    }





    // -------------------------------------------------------------------
    // Connect to CoreInterface notification signals
    //
    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }

    property var conv_noti
    property var conv_alert_noti
    property var therm_hyst
    property var therm_ext
    property var therm_int
    // DEBUG Window for testing motor vortex UI without a platform
    //    Window {
    //        id: debug
    //        visible: true
    //        width: 200
    //        height: 400

    //        Button {
    //            id: button1
    //            //   anchors { top: button1.bottom }
    //            text: "send conv rate"
    //            onClicked: {
    //                platformInterface.get_conv_rate.update()
    //                var items = ["16 s", "8 s", "4 s", "2 s", "1 s", "500 ms", "250 ms", "125 ms", "62.5 ms", "31.25 ms", "15.5 ms"]
    //                var value = items[Math.floor(Math.random()*items.length)]
    //                console.log("value", value)
    //                conv_noti = value
    //                CorePlatformInterface.data_source_handler('{
    //                                "value":"nct72_get_conv_rate",
    //                                "payload":{
    //                                            "conv_rate": " '+ value +'"
    //                                           }
    //                                         }')
    //            }
    //        }
    //        Button {
    //            id: button2
    //            anchors { top: button1.bottom }
    //            text: "send ext low lim"
    //            onClicked: {
    //                platformInterface.get_ext_low_lim.update()
    //                //                CorePlatformInterface.data_source_handler('{
    //                //                            "value":"nct72_get_ext_low_lim",
    //                //                            "payload":{
    //                //                                        "integer": ' + Math.random() + ' ,
    //                //                                        "fraction": "' + Math.random() + '"
    //                //                                       }
    //                //                                     }')

    //            }
    //        }
    //        Button {
    //            id: button3
    //            anchors { top: button2.bottom }
    //            text: "send conv alert"
    //            onClicked: {
    //                platformInterface.get_cons_alert.update()
    //                var items = ["1","2","3","4"]
    //                var value = items[Math.floor(Math.random()*items.length)]
    //                conv_alert_noti = value
    //                CorePlatformInterface.data_source_handler('{
    //                                "value":"nct72_get_cons_alert",
    //                                "payload":{
    //                                            "cons_alert:" '+ (value) +'
    //                                           }
    //                                         }')

    //            }
    //        }
    //        Button {
    //            id: button4
    //            anchors { top: button3.bottom }
    //            text: "get manufacturers ID "
    //            onClicked: {
    //                platformInterface.get_man_id.update()
    //            }
    //        }
    //        Button {
    //            id: button5
    //            anchors { top: button4.bottom }
    //            text: "get Therm Hyst "
    //            onClicked: {
    //                platformInterface.get_therm_hyst.update()
    //                var value = Math.random() * 256
    //                therm_hyst = parseInt(value)
    //                CorePlatformInterface.data_source_handler('{
    //                                "value":"nct72_get_therm_hyst",
    //                                "payload":{
    //                                            "hyst:" '+therm_hyst+'
    //                                           }
    //                                         }')

    //            }
    //        }
    //        Button {
    //            id: button6
    //            anchors { top: button5.bottom }
    //            text: "get Therm ext "
    //            onClicked: {
    //                platformInterface.get_therm_limits.update()
    //                var value_ext = Math.random() * 256
    //                var value_int = Math.random() * 256
    //                therm_ext = parseInt(value_ext)
    //                therm_int = parseInt(value_int)
    //                CorePlatformInterface.data_source_handler('{
    //                                "value":"nct72_get_therm_limits",
    //                                "payload":{
    //                                            "external:" '+value_ext+',
    //                                            "internal:" '+value_int+'

    //                                           }
    //                                         }')

    //            }
    //        }
    //        Button {
    //            id: button7
    //            anchors { top: button6.bottom }
    //            text: "get config "
    //            onClicked: {
    //                platformInterface.get_nct72_config.update()


    //            }
    //        }



    // }
    //        Button {
    //            anchors { top: button2.bottom }
    //            text: "send"
    //            onClicked: {
    //                CorePlatformInterface.data_source_handler('{
    //                            "value":"read_temperature_sensor",
    //                            "payload":{
    //                                     "temperature": '+ (Math.random()*100).toFixed(0) +'
    //                            }
    //                    }
    //            ')
    //            }
    //        }
    //   }


}
