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

    // @notification read_voltage_current
    // @description: read values
    //
    property var  status_voltage_current : {
        "vin":	0,          //in Volts
        "vout": 0,          //in Volts
        "iin":	0,          //in mA
        "iout": 0,          //in mA
        "vin_bad": "on",	// on (red) or off(green)
        "efficiency": 0,
        "power_dissipated": 0,
        "output_power" : 0,

    }

    // @notification read_temperature_sensor
    // @description: Read temperature
    //
    property var status_temperature_sensor : {
        "temperature":	0
    }

    property var status_enable: {
        "enable": ""
    }

    property var status_vin_good: {
        "vingood": ""
    }

    property var initial_status_0:{
        "enable_status": "",
        "vingood_status": "",
        "vsel_status": "",
        "pgood_status": "",
        "vout_vsel0_status": 4,
        "vout_vsel1_status": 4,
        "pgood_enable_status": "",
        "dvs_pgood_enable_status":	"",
        "reset_timeout_pgood_status": 1,
        "active_discharge_status": ""
    }

    property var initial_status_1:{
        "dvs_speed_status":         0,
        "delay_enable_status":      5,
        "sleep_mode_status":		"",
        "dvs_mode_status":			"",
        "ppwmvsel1_mode_status":	"",
        "ppwmvsel0_mode_status":    "",
        "reset_indicator_status":	"",
        "thermal_pre_status":		0,
        "ipeak_status":             0,
        "read_int_sen":				0
    }

    property var power_cycle_status: {
        "reset": ""
    }

    property var status_sense_register: {
        "sense_reg_value": 0
    }

    property var status_interrupt: {
        "pgood": ""
    }


    property var  status_ack_register: {
        "events_detected":[ ]

    }

    property var  status_mcu_reset: {
        "mcu_reset": ""
    }

    // -------------------  end notification messages


    // -------------------
    // Commands
    // TO SEND A COMMAND DO THE FOLLOWING:
    // EXAMPLE: To send the motor speed: platformInterface.set_enable.update("on")

    // TO SYNCHRONIZE THE SPEED ON ALL THE VIEW DO THE FOLLOWING:
    // EXAMPLE: platformInterface.enabled

    property var read_enable_state: ({ "cmd" : "read_enable",

                                         update: function () {
                                             CorePlatformInterface.send(this)
                                         },
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }

                                     })


    property var set_enable: ({
                                  "cmd" : "set_enable",
                                  "payload": {
                                      "enable": " ",
                                  },

                                  // Update will set and send in one shot
                                  update: function (enabled) {
                                      this.set(enabled)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (enabled) {
                                      this.payload.enable = enabled;
                                  },
                                  get: function() {
                                      return this.payload.enable
                                  },

                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })


    property var  check_vin_good: ({

                                       "cmd":"check_vin_good",
                                       update: function () {
                                           CorePlatformInterface.send(this)
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var  set_vselect: ({

                                    "cmd": "set_vselect",
                                    "payload": {
                                        "vsel": " ",
                                    },

                                    // Update will set and send in one shot
                                    update: function (vsel) {
                                        this.set(vsel)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (vsel) {
                                        this.payload.vsel = vsel;
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })


    property var  set_prog_vselect0: ({

                                          "cmd": "set_prog_vsel0",
                                          "payload": {
                                              "prog_vsel0": " ",
                                          },

                                          // Update will set and send in one shot
                                          update: function (prog_vsel0) {
                                              this.set(prog_vsel0)
                                              CorePlatformInterface.send(this)
                                          },
                                          // Set can set single or multiple properties before sending to platform
                                          set: function (prog_vsel0) {
                                              this.payload.prog_vsel0 = prog_vsel0;
                                          },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }
                                      })


    property var  read_initial_status: ({

                                            "cmd":"read_initial_status",
                                            update: function () {
                                                CorePlatformInterface.send(this)
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }

                                        })

    property var set_prog_vsel1: ({
                                      "cmd" : "set_prog_vsel1",
                                      "payload": {
                                          "prog_vsel1": 0,
                                      },

                                      update: function (prog_vsel1) {
                                          this.set(prog_vsel1)
                                          CorePlatformInterface.send(this)
                                      },
                                      set: function (prog_vsel1) {
                                          this.payload.prog_vsel1 = prog_vsel1;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }

                                  })

    property var enable_prog1: ({
                                    "cmd" : "set_enable_vsel1",
                                    "payload": {
                                        "enable_vsel1": "",
                                    },

                                    // Update will set and send in one shot
                                    update: function (enable_vsel1) {
                                        this.set(enable_vsel1)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (enable_vsel1) {
                                        this.payload.enable_vsel1 = enable_vsel1;
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }

                                })


    property var enable_prog0: ({
                                    "cmd" : "set_enable_vsel0",
                                    "payload": {
                                        "enable_vsel0": "",  //on or off
                                    },

                                    // Update will set and send in one shot
                                    update: function (enable_vsel0) {
                                        this.set(enable_vsel0)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (enable_vsel0) {
                                        this.payload.enable_vsel0 = enable_vsel0;
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }

                                })

    property var vselect_prog0: ({
                                     "cmd" : "set_prog_vsel0",
                                     "payload": {
                                         "prog_vsel0": 0,
                                     },

                                     update: function (prog_vsel0) {
                                         this.set(prog_vsel0)
                                         CorePlatformInterface.send(this)
                                     },
                                     set: function (prog_vsel0) {
                                         this.payload.prog_vsel0 = prog_vsel0;
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })

    property var pgood_on_dvs: ({
                                    "cmd" : "set_pgood_on_dvs",
                                    "payload": {
                                        "pgood": "",
                                    },

                                    update: function (pgood) {
                                        this.set(pgood)
                                        CorePlatformInterface.send(this)
                                    },
                                    set: function (pgood) {
                                        this.payload.pgood = pgood;
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }

                                })

    property var active_discharge: ({
                                        "cmd" : "enable_active_discharge",
                                        "payload": {
                                            "active_discharge": "",
                                        },

                                        update: function (active_discharge) {
                                            this.set(active_discharge)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (active_discharge) {
                                            this.payload.active_discharge = active_discharge;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }

                                    })

    property var sleep_mode: ({
                                  "cmd" : "set_sleep_mode",
                                  "payload": {
                                      "sleep_mode": "",
                                  },

                                  update: function (sleep_mode) {
                                      this.set(sleep_mode)
                                      CorePlatformInterface.send(this)
                                  },
                                  set: function (sleep_mode) {
                                      this.payload.sleep_mode = sleep_mode;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })

    property var dvs_mode: ({
                                "cmd" : "set_dvs_mode",
                                "payload": {
                                    "dvs_mode": "",
                                },

                                update: function (dvs_mode) {
                                    this.set(dvs_mode)
                                    CorePlatformInterface.send(this)
                                },
                                set: function (dvs_mode) {
                                    this.payload.dvs_mode = dvs_mode;
                                },
                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }

                            })

    property var ppwm_vsel1_mode: ({
                                       "cmd" : "set_ppwm_vsel1_mode",
                                       "payload": {
                                           "ppwm_mode": "",
                                       },

                                       update: function (ppwm_mode) {
                                           this.set(ppwm_mode)
                                           CorePlatformInterface.send(this)
                                       },
                                       set: function (ppwm_mode) {
                                           this.payload.ppwm_mode = ppwm_mode;
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }

                                   })

    property var ppwm_vsel0_mode: ({
                                       "cmd" : "set_ppwm_vsel0_mode",
                                       "payload": {
                                           "ppwm_mode": "",
                                       },

                                       update: function (ppwm_mode) {
                                           this.set(ppwm_mode)
                                           CorePlatformInterface.send(this)
                                       },
                                       set: function (ppwm_mode) {
                                           this.payload.ppwm_mode = ppwm_mode;
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }

                                   })

    property var set_debounce_time: ({
                                         "cmd" : "set_debounce_time",
                                         "payload": {
                                             "debounce_time": 0 ,
                                         },

                                         update: function (debounce_time) {
                                             this.set(debounce_time)
                                             CorePlatformInterface.send(this)
                                         },
                                         set: function (debounce_time) {
                                             this.payload.debounce_time = debounce_time;
                                         },
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }

                                     })

    property var set_dvs_speed: ({
                                     "cmd" : "set_dvs_speed",
                                     "payload": {
                                         "dvs_speed": 0 ,
                                     },

                                     update: function (dvs_speed) {
                                         this.set(dvs_speed)
                                         CorePlatformInterface.send(this)
                                     },
                                     set: function (dvs_speed) {
                                         this.payload.dvs_speed = dvs_speed;
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })

    property var set_delay_on_enable: ({
                                           "cmd" : "set_delay_on_enable",
                                           "payload": {
                                               "delay": 0 ,
                                           },

                                           update: function (delay) {
                                               this.set(delay)
                                               CorePlatformInterface.send(this)
                                           },
                                           set: function (delay) {
                                               this.payload.delay = delay;
                                           },
                                           send: function () { CorePlatformInterface.send(this) },
                                           show: function () { CorePlatformInterface.show(this) }

                                       })


    property var set_vsel_gating: ({
                                       "cmd" : "set_vsel_gating",
                                       "payload": {
                                           "vsel_gating": "" ,
                                       },

                                       update: function (vsel_gating) {
                                           this.set(vsel_gating)
                                           CorePlatformInterface.send(this)
                                       },
                                       set: function (vsel_gating) {
                                           this.payload.vsel_gating = vsel_gating;
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }

                                   })

    property var rearm_device: ({
                                    "cmd" : "rearm_device_setting",
                                    "payload": {
                                        "rearm_device": "" ,
                                    },

                                    update: function (rearm_device) {
                                        this.set(rearm_device)
                                        CorePlatformInterface.send(this)
                                    },
                                    set: function (rearm_device) {
                                        this.payload.rearm_device = rearm_device;
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }

                                })

    property var force_reset_registers: ({
                                             "cmd" : "force_reset_registers",
                                             "payload": {
                                                 "reset_status": "" ,
                                             },

                                             update: function (reset_status) {
                                                 this.set(reset_status)
                                                 CorePlatformInterface.send(this)
                                             },
                                             set: function (reset_status) {
                                                 this.payload.reset_status = reset_status;
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }
                                         })

    property var reset_status_indicator: ({
                                              "cmd" : "reset_status_indicator",
                                              "payload": {
                                                  "reset_status": "" ,
                                              },

                                              update: function (reset_status) {
                                                  this.set(reset_status)
                                                  CorePlatformInterface.send(this)
                                              },
                                              set: function (reset_status) {
                                                  this.payload.reset_status = reset_status;
                                              },
                                              send: function () { CorePlatformInterface.send(this) },
                                              show: function () { CorePlatformInterface.show(this) }

                                          })


    property var set_thermal_threshold: ({
                                             "cmd" : "set_thermal_threshold",
                                             "payload": {
                                                 "thermal_threshold": 0 ,
                                             },

                                             update: function (thermal_threshold) {
                                                 this.set(thermal_threshold)
                                                 CorePlatformInterface.send(this)
                                             },
                                             set: function (thermal_threshold) {
                                                 this.payload.thermal_threshold = thermal_threshold;
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }


                                         })
    property var set_ipeak_current: ({
                                         "cmd" : "set_ipeak_current",
                                         "payload": {
                                             "ipeak_current": 0 ,
                                         },

                                         update: function (ipeak_current) {
                                             this.set(ipeak_current)
                                             CorePlatformInterface.send(this)
                                         },
                                         set: function (ipeak_current) {
                                             this.payload.ipeak_current = ipeak_current;
                                         },
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }
                                     })

    property var read_sense_register: ({
                                           "cmd":"read_sense_register",
                                           update: function () {
                                               CorePlatformInterface.send(this)
                                           },
                                           send: function () { CorePlatformInterface.send(this) },
                                           show: function () { CorePlatformInterface.show(this) }


                                       })

    property var set_pgood_enable : ({
                                         "cmd" : "set_pgood_enable",
                                         "payload": {
                                             "pgood": "" ,
                                         },

                                         update: function (pgood) {
                                             this.set(pgood)
                                             CorePlatformInterface.send(this)
                                         },
                                         set: function (pgood) {
                                             this.payload.pgood = pgood;
                                         },
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }
                                     })

    property var set_pgood_on_dvs: ({
                                        "cmd" : "set_pgood_on_dvs",
                                        "payload": {
                                            "pgood": "" ,
                                        },

                                        update: function (pgood) {
                                            this.set(pgood)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (pgood) {
                                            this.payload.pgood = pgood;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var set_timeout_reset_pgood: ({
                                               "cmd" : "set_timeout_reset_pgood",
                                               "payload": {
                                                   "timeout_reset": "" ,
                                               },

                                               update: function (timeout_reset) {
                                                   this.set(timeout_reset)
                                                   CorePlatformInterface.send(this)
                                               },
                                               set: function (timeout_reset) {
                                                   this.payload.timeout_reset = timeout_reset;
                                               },
                                               send: function () { CorePlatformInterface.send(this) },
                                               show: function () { CorePlatformInterface.show(this) }
                                           })

    property var pause_periodic: ({
                                      "cmd" : "pause_periodic",
                                      "payload": {
                                          "pause_flag": "",
                                      },

                                      // Update will set and send in one shot
                                      update: function (pause_flag) {
                                          this.set(pause_flag)
                                          CorePlatformInterface.send(this)
                                      },
                                      // Set can set single or multiple properties before sending to platform
                                      set: function (pause_flag) {
                                          this.payload.pause_flag = pause_flag;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    // -------------------  end commands


    // NOTE:
    //  All internal property names for PlatformInterface must avoid name collisions with notification/cmd message properties.
    //  naming convention to avoid name collisions;
    //  property var _name


    // -------------------------------------------------------------------
    // Connect to CoreInterface notification signals
    // -------------------------------------------------------------------
    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }

    /*
      property to sync the views and set the initial state
    */
    property bool enabled: false
    property bool advertise
    property bool hide_enable
    property bool intd_state
    property bool vsel_state
    //    property bool inbt_state
    property bool pgood_state
    property bool warning_visibility
    property int output_voltage_selector0
    property int output_voltage_selector1
    property int dcdc_mode0
    property int dcdc_mode1
    property int ipeak_state
    property int dvs_speed_state
    property int delay_enable_state
    property int thermal_prewarn_state
    property bool sleep_mode_state
    property bool active_discharge_state
    property string reset_indicator
    property var mask_register_state
    property bool reset_flag: false
    property var pgood_enable_status
    property var pgood_enable
    property int timeout_status

    // DEBUG Window for testing motor vortex UI without a platform
    Window {
        id: debug
        visible: true
        width: 200
        height: 200

        //        Button {
        //            id: button2
        //            //   anchors { top: button1.bottom }
        //            text: "send vin"
        //            onClicked: {
        //                CorePlatformInterface.data_source_handler('{
        //                        "value":"initial_status_0",
        //                        "payload":{
        //                                "enable_status":"on",
        //                                "vingood_status": "good",
        //                                "vsel_status": "off",
        //                                "pgood_status": "bad",
        //                                "vout_vsel0_status": '+ (Math.floor(Math.random() * 216) + 0).toFixed(0) +',
        //                                "vout_vsel1_status": 4,
        //                                "pgood_enable_status": "on",
        //                                "dvs_pgood_enable_status":	"on",
        //                                "reset_timeout_pgood_status": 1,
        //                                "active_discharge_status": "off"

        //                                   }
        //                                 }')
        //            }
        //        }
        Button {
            anchors { top: parent.top }
            text: "send"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                                "value":"status_ack_register",
                                "payload":{
                                         "events_detected":  ["d", "d"]
                                }
                        }
                ')
            }
        }
    }
}
