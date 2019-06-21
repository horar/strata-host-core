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

    // @notification get_sensor_type
    // @description: read values
    //

    property var lc717a10ar_cin_act_touch: {
        "cin": [0,0,0,0,0,0,0,0]
    }
    property var lc717a10ar_cin_act_proximity: {
        "cin": [0,0,0,0]
    }

    property var lc717a10ar_reset: {
        "status": ""
    }

    property var lv0104cs_get_light: {
        "lux": 598
    }

    property var nct72_get_temp: {
        "internal": 0,
        "external": 0
    }
    property var nct72_get_status: {
        "LTHRM": 0,
        "RTHRM": 0,
        "OPEN": 0,
        "RLOW": 0,
        "RHIGH": 0,
        "LLOW": 0,
        "LHIGH": 1,
        "BUSY": 0,
        "byte": 128
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
    property var nct72_get_ext_high_lim: {
        "integer":0,
        "fraction":"0"
    }

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

    property var control_properties: {
        "nct72_remote_low_limit":{
            "caption": "Remote Low Limit:",
            "value": "35",
            "state": "enabled",
            "scales": [-50.00, 150.00, 0.5]
        },
        "nct72_alert_therm2":{
            "caption":"ALERT",
            "value":"ALERT",
            "state":"disabled"
        },
        "nct72_cons_alert": {
            "caption": "Consecutive ALERTs:",
            "value": "2",
            "state": "enabled",
            "values": ["1", "2", "3", "45"]
        }
    }



    // -------------------
    // Commands
    // TO SEND A COMMAND DO THE FOLLOWING:
    //

    // TO SYNCHRONIZE THE SPEED ON ALL THE VIEW DO THE FOLLOWING:
    //

    property var start_periodic: ({
                                      "cmd" : "start_periodic",
                                      "payload": {
                                          "function":"board_startup",
                                          "run_count":1,
                                          "interval":0
                                      },
                                      update: function (function_name,run_count,interval) {
                                          this.set(function_name,run_count,interval)
                                          CorePlatformInterface.send(this)
                                      },
                                      set: function (function_name,run_count,interval) {
                                          this.payload.function = function_name;
                                          this.payload.run_count = run_count;
                                          this.payload.interval = interval
                                      },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }


                                      })

    property var set_sensor_type:({
                                      "cmd" : "set_sensor_type",
                                      "payload": {
                                          "sensor": ""
                                      },
                                      update: function (sensor) {
                                          this.set(sensor)
                                          CorePlatformInterface.send(this)
                                      },
                                      set: function (sensor) {
                                          this.payload.sensor = sensor;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }

                                  })

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

    property var get_nct72_config: ({
                                        "cmd":"nct72_get_config",
                                        update: function () {
                                            CorePlatformInterface.send(this)
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }

                                    })

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
    property var set_config_range: ({
                                        "cmd": "nct72_set_config_range",
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
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })



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



    property var set_config_alert_therm2 : ({
                                                "cmd": "nct72_set_config_alert_therm2",
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
                                                send: function () { CorePlatformInterface.send(this) },
                                                show: function () { CorePlatformInterface.show(this) }
                                            })

    property var set_config_run_stop : ({
                                            "cmd": "nct72_set_config_run_stop",
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
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })
    property var set_config_alert : ({
                                         "cmd": "nct72_set_config_alert",
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
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }
                                     })

    //Conversion rate
    property var set_conv_rate : ({
                                      "cmd": "nct72_set_conv_rate",
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
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var get_conv_rate: ({
                                     "cmd":"nct72_get_conv_rate",
                                     update: function () {
                                         CorePlatformInterface.send(this)
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })
    property var get_ext_low_lim: ({
                                       "cmd":"nct72_get_ext_low_lim",
                                       update: function () {
                                           CorePlatformInterface.send(this)
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })
    property var set_ext_low_lim_integer: ({
                                               "cmd":"nct72_set_ext_low_lim_integer",
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
                                               send: function () { CorePlatformInterface.send(this) },
                                               show: function () { CorePlatformInterface.show(this) }
                                           })
    property var set_ext_low_lim_fraction: ({
                                                "cmd":"nct72_set_ext_low_lim_fraction",
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
                                                send: function () { CorePlatformInterface.send(this) },
                                                show: function () { CorePlatformInterface.show(this) }
                                            })

    //// external high limit get
    property var get_ext_high_lim: ({
                                        "cmd":"nct72_get_ext_high_lim",
                                        update: function () {
                                            CorePlatformInterface.send(this)
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })
    property var set_ext_high_lim_integer: ({
                                                "cmd":"nct72_set_ext_high_lim_integer",
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
                                                send: function () { CorePlatformInterface.send(this) },
                                                show: function () { CorePlatformInterface.show(this) }
                                            })
    property var set_ext_high_lim_fraction: ({
                                                 "cmd":"nct72_set_ext_high_lim_fraction",
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
                                                 send: function () { CorePlatformInterface.send(this) },
                                                 show: function () { CorePlatformInterface.show(this) }
                                             })



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
    property var get_therm_hyst: ({
                                      "cmd":"nct72_get_therm_hyst",
                                      update: function () {
                                          CorePlatformInterface.send(this)
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })


    property var set_therm_hyst: ({
                                      "cmd":"nct72_set_therm_hyst",
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
    //Remote and Local THERM Limits
    property var get_therm_limits: ({
                                        "cmd":"nct72_get_therm_limits",
                                        update: function () {
                                            CorePlatformInterface.send(this)
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var set_ext_therm_limit: ({
                                           "cmd":"nct72_set_ext_therm_limit",
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
    property var set_int_therm_limit: ({
                                           "cmd":"nct72_set_int_therm_limit",
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

    //One-shot
    property var one_shot: ({
                                "cmd":"nct72_one_shot",
                                update: function () {
                                    CorePlatformInterface.send(this)
                                },
                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }
                            })




    //internal low limit get
    property var get_int_low_lim: ({
                                       "cmd":"nct72_get_int_low_lim",
                                       update: function () {
                                           CorePlatformInterface.send(this)
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })
    // internal low limit set
    property var set_int_low_lim: ({
                                       "cmd":"nct72_set_int_low_lim",
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

    //internal high limit get
    property var get_int_high_lim: ({
                                        "cmd":"nct72_get_int_high_lim",
                                        update: function () {
                                            CorePlatformInterface.send(this)
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })
    property var set_int_high_lim: ({
                                        "cmd":"nct72_set_int_high_lim",
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

    property var conv_noti
    property var conv_alert_noti
    property int therm_hyst: 50
    property int therm_ext: 50
    property int therm_int: 50
    // DEBUG Window for testing motor vortex UI without a platform
    Window {
        id: debug
        visible: true
        width: 200
        height: 400

        Button {
            id: button1
            //   anchors { top: button1.bottom }
            text: "send conv rate"
            onClicked: {
                platformInterface.get_conv_rate.update()
                var items = ["16 s", "8 s", "4 s", "2 s", "1 s", "500 ms", "250 ms", "125 ms", "62.5 ms", "31.25 ms", "15.5 ms"]
                var value = items[Math.floor(Math.random()*items.length)]
                console.log("value", value)
                conv_noti = value
                CorePlatformInterface.data_source_handler('{
                            "value":"nct72_get_conv_rate",
                            "payload":{
                                        "conv_rate": " '+ value +'"
                                       }
                                     }')
            }
        }
        Button {
            id: button2
            anchors { top: button1.bottom }
            text: "send ext low lim"
            onClicked: {
                platformInterface.get_ext_low_lim.update()
                //                CorePlatformInterface.data_source_handler('{
                //                            "value":"nct72_get_ext_low_lim",
                //                            "payload":{
                //                                        "integer": ' + Math.random() + ' ,
                //                                        "fraction": "' + Math.random() + '"
                //                                       }
                //                                     }')

            }
        }
        Button {
            id: button3
            anchors { top: button2.bottom }
            text: "send conv alert"
            onClicked: {
                platformInterface.get_cons_alert.update()
                var items = ["1","2","3","4"]
                var value = items[Math.floor(Math.random()*items.length)]
                conv_alert_noti = value
                CorePlatformInterface.data_source_handler('{
                            "value":"nct72_get_cons_alert",
                            "payload":{
                                        "cons_alert:" '+ (value) +'
                                       }
                                     }')

            }
        }
        Button {
            id: button4
            anchors { top: button3.bottom }
            text: "get manufacturers ID "
            onClicked: {
                platformInterface.get_man_id.update()
            }
        }
        Button {
            id: button5
            anchors { top: button4.bottom }
            text: "get Therm Hyst "
            onClicked: {
                platformInterface.get_therm_hyst.update()
                var value = Math.random() * 256
                therm_hyst = parseInt(value)
                CorePlatformInterface.data_source_handler('{
                            "value":"nct72_get_therm_hyst",
                            "payload":{
                                        "hyst:" '+therm_hyst+'
                                       }
                                     }')

            }
        }
        Button {
            id: button6
            anchors { top: button5.bottom }
            text: "get Therm ext "
            onClicked: {
                platformInterface.get_therm_limits.update()
                var value_ext = Math.random() * 256
                var value_int = Math.random() * 256
                therm_ext = parseInt(value_ext)
                therm_int = parseInt(value_int)
                CorePlatformInterface.data_source_handler('{
                            "value":"nct72_get_therm_limits",
                            "payload":{
                                        "external:" '+value_ext+',
                                        "internal:" '+value_int+'

                                       }
                                     }')

            }
        }
        Button {
            id: button7
            anchors { top: button6.bottom }
            text: "get config "
            onClicked: {
                platformInterface.get_nct72_config.update()


            }
        }



    }
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
