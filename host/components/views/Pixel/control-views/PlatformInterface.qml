 import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------------------------------------------------------
    // UI Control States
    //
    // EXAMPLE:
    //    1) Create control state:
    //          property bool _motor_running_control: false
    //
    //    2) Control in UI is bound to _motor_running_control so it will follow
    //       the state, but can also set it. Like so:
    //          checked: platformInterface._motor_running_control
    //          onCheckedChanged: platformInterface._motor_running_control = checked
    //
    //    3) This state can optionally be sent as a command when controls set it:
    //          on_Motor_running_controlChanged: {
    //              motor_running_command.update(_motor_running_control)
    //          }
    //
    //  Can also synchronize control state across multiple UI views;
    //  just bind all controls to this state as in #2 above.
    //
    //  ** All internal property names for PlatformInterface must avoid name
    //  ** collisions with notification/cmd message properties.
    //  **    Use Naming Convention: 'property var _name'

    // @control_state: _motor_running_control
    // @description: set by notification and UI control sends command
    //



    // -------------------------------------------------------------------
    // Incoming Notification Messages
    //
    // Define and document incoming notification messages here.
    //
    // The property name *must* match the associated notification value.
    // Sets UI Control State when changed.

    // @notification: motor_running_notification
    // @description: update motor running status
    //
    property var system_init_status : {
        "init_state": "NG"
    }

    property var boost_state : {
        "state": "boost_off"
    }

    property var buck_state : {
        "state": "buck1_off"
    }

    property var auto_addressing : {
        "state": "off"
    }

    property var demo_led_state: {
        "led" : 1
    }

    property var demo_state: {
        "status": ""
    }

    property var bhall: {
        "position": ""
    }

    property var curtain: {
        "position": ""
    }

    property var diag1_boost: {
        "hwr"           : 0,
        "boost2_status" : 0,
        "boost1_status" : 0,
        "boost_ov"      : 0,
        "temp_out"      : 0,
        "spierr"        : 0,
        "tsd"           : 0,
        "tw"            : 0,
        "status"        : 0
    }

    property var diag2_boost: {
        "enable2_status"    : 0,
        "enable1_status"    : 0,
        "vdrive_nok"        : 0,
        "vbstdiv_uv"        : 0
    }

    property var diag1_buck: {
        "device"    : 0,
        "openled1"  : 0,
        "shortled1" : 0,
        "ocled1"    : 0,
        "openled2"  : 0,
        "shortled2" : 0,
        "ocled2"    : 0,
        "status"    : 0
    }

    property var diag2_buck: {
        "device"    : 0,
        "hwr"       : 0,
        "led1val"   : 0,
        "led2val"   : 0,
        "spierr"    : 0,
        "tsd"       : 0,
        "tw"        : 0
    }

    property var diag3_buck: {
        "device"    : 0,
        "vled1on"   : 0,
        "vled1"     : 0,
        "vled2on"   : 0,
        "vled2"     : 0,
        "vtemp"     : 0,
        "vboost"    : 0
    }

    property var pxn_diag_15_0: {
        "sw6"       : 4,
        "sw5"       : 4,
        "sw4"       : 4,
        "sw3"       : 4,
        "sw2"       : 4,
        "sw1"       : 4
    }

    property var pxn_diag_15_1: {
        "sw12"      : 4,
        "sw11"      : 4,
        "sw10"      : 4,
        "sw9"       : 4,
        "sw8"       : 4,
        "sw7"       : 4
    }

    property var pxn_diag_16_0: {
        "tw"        : 0,
        "tsd"       : 0,
        "gswerr"    : 0,
        "dmwarn"    : 0,
        "dmerr"     : 0,
        "hwr"       : 0,
        "cap_uv"    : 0,
        "otp_zap_uv": 0,
        "vbb_low"   : 0,
        "gnd_loss"  : 0
    }

    property var pxn_diag_16_1: {
        "pwm_cnt_ovf"   : 0,
        "mapena_stat"   : 0,
        "pxn_glob_err"  : 0,
        "pxn_loc_err"   : 0,
        "pxn_frm_err"   : 0,
        "pxn_syn_err"   : 0,
        "timeout"       : 0,
        "otp_crc_fal2"  : 0,
        "otp_crc_fal0"  : 0,
        "pxn_crc_err"   : 0
    }

    property var pxn_diag_1718: {
        "vdd"       :   0,
        "temp"      :   0,
        "vled"      :   0,
        "vbb"       :   0
    }

    property var stop_periodic: {
        "status"    : ""
    }

    // -------------------------------------------------------------------
    // Outgoing Commands
    //
    // Define and document platform commands here.
    //
    // Built-in functions:
    //   update(): sets properties and sends command in one call
    //   set():    can set single or multiple properties before sending to platform
    //   send():   sends current command
    //   show():   console logs current command and properties

    // @command: motor_running_command
    // @description: sends motor running command to platform
    //
    property var set_boost_enable : ({
                                         "cmd" : "set_boost_enable",
                                         "payload": {
                                             "enable": 1
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

    property var set_buck_enable : ({
                                        "cmd" : "set_buck_enable",
                                        "payload": {
                                            "buck": 1,
                                            "enable": 1
                                        },

                                        update: function (buck_a,enable_a) {
                                            this.set(buck_a,enable_a)
                                            this.send(this)
                                        },

                                        set: function (buck_a,enable_a) {
                                            this.payload.buck = buck_a
                                            this.payload.enable = enable_a
                                        },

                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var boost_v_control : ({
                                        "cmd" : "boost_v_control",
                                        "payload": {
                                            "data": 60
                                        },

                                        update: function (data) {
                                            this.set(data)
                                            this.send(this)
                                        },
                                        set: function (data_a) {
                                            this.payload.data = data_a
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var boost_diag_read : ({
                                        "cmd" : "boost_diag_read",
                                        "payload": {
                                            "num": 0
                                        },

                                        update: function (num) {
                                            this.set(num)
                                            this.send(this)
                                        },
                                        set: function (num_a) {
                                            this.payload.num = num_a
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var buck_i_control : ({
                                       "cmd" : "buck_i_control",
                                       "payload": {
                                           "ch": 1,
                                           "data": 200
                                       },

                                       update: function (ch_a,data_a) {
                                           this.set(ch_a,data_a)
                                           this.send(this)
                                       },

                                       set: function (ch_a,data_a) {
                                           this.payload.ch = ch_a
                                           this.payload.data = data_a
                                       },

                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var dim_control : ({
                                    "cmd" : "dim_control",
                                    "payload": {
                                        "ch": 1,
                                        "dim_data": 100
                                    },

                                    update: function (ch_a,dim_data_a) {
                                        this.set(ch_a,dim_data_a)
                                        this.send(this)
                                    },

                                    set: function (ch_a,dim_data_a) {
                                        this.payload.ch = ch_a
                                        this.payload.dim_data = dim_data_a
                                    },

                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })

    property var buck_diag_read : ({
                                    "cmd" : "buck_diag_read",
                                    "payload": {
                                        "device": 1,
                                        "num": 1
                                    },

                                    update: function (device_a,num_a) {
                                        this.set(device_a,num_a)
                                        this.send(this)
                                    },

                                    set: function (device_a,num_a) {
                                        this.payload.device = device_a
                                        this.payload.num = num_a
                                    },

                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })

    property var pxn_status_read : ({
                                    "cmd" : "pxn_status_read",
                                    "payload": {
                                        "ch": 1,
                                        "index" : 1                    },

                                    update: function (ch_a,index_a) {
                                        this.set(ch_a,index_a)
                                        this.send(this)
                                    },

                                    set: function (ch_a,index_a) {
                                        this.payload.ch = ch_a
                                        this.payload.index= index_a
                                    },

                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })

    property var pxn_datasend : ({
                                     "cmd" : "pxn_data",
                                     "payload": {
                                         "ch": 1,
                                         "led_num": 1,
                                         "data": 80
                                     },

                                     update: function (ch_a,led_num_a,data_a) {
                                         this.set(ch_a,led_num_a,data_a)
                                         this.send(this)
                                     },

                                     set: function (ch_a,led_num_a,data_a) {
                                         this.payload.ch = ch_a
                                         this.payload.led_num = led_num_a
                                         this.payload.data = data_a
                                     },

                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }
                                 })

    property var pxn_datasend_all : ({
                                         "cmd" : "pxn_set_all_data",
                                         "payload": {
                                             "data": 80
                                         },

                                         update: function (data_a) {
                                             this.set(data_a)
                                             this.send(this)
                                         },

                                         set: function (data_a) {
                                             this.payload.data = data_a
                                         },

                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }
                                     })


    property var pxn_autoaddr : ({
                                     "cmd" : "pxn_config",
                                     "payload": {
                                         "auto_config": 1
                                     },

                                     update: function (auto_config_a) {
                                         this.set(auto_config_a)
                                         this.send(this)
                                     },

                                     set: function (auto_config_a) {
                                         this.payload.auto_config = auto_config_a
                                     },

                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }
                                 })


    property var pxn_demo_setting : ({
                                         "cmd" : "pxn_demo_setting",
                                         "payload": {
                                             "mode": 1,
                                             "led_num": 1,
                                             "intensity": 50
                                         },

                                         update: function (mode_a, led_num_a, intensity_a) {
                                             this.set(mode_a, led_num_a, intensity_a)
                                             this.send(this)
                                         },

                                         set: function (mode_a, led_num_a, intensity_a) {
                                             this.payload.mode = mode_a
                                             this.payload.led_num = led_num_a
                                             this.payload.intensity = intensity_a
                                         },

                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }
                                     })

    property var pxn_led_position: ({
                                        "cmd" : "pxn_demo_led_position",
                                        "payload": {
                                            "position": 1

                                        },

                                        update: function (position_a) {
                                            this.set(position_a)
                                            this.send(this)
                                        },

                                        set: function (position_a) {
                                            this.payload.position = position_a
                                        },

                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var pxn_bhall_position : ({
                                           "cmd" : "pxn_demo_bhall_position",
                                           "payload": {
                                               "position": 1
                                           },

                                           update: function (position_a) {
                                               this.set(position_a)
                                               this.send(this)
                                           },

                                           set: function (position_a) {
                                               this.payload.position = position_a
                                           },

                                           send: function () { CorePlatformInterface.send(this) },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

    property var system_init : ({
                                    "cmd" : "system_initialization",

                                    update: function () {
                                        this.set()
                                        this.send()
                                    },

                                    set: function () {
                                    },

                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })

    property var start_peroidic_hdl : ({
                                           "cmd" : "start_periodic",
                                           "payload": {
                                               "function":"pxn_demo_led_state",
                                               "run_count":-1,
                                               "interval": 50
                                           },

                                           update: function () {
                                               this.set()
                                               this.send()
                                           },

                                           set: function () {
                                           },

                                           send: function () { CorePlatformInterface.send(this) },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

    property var update_peroidic_hdl : ({
                                           "cmd" : "update_periodic",
                                           "payload": {
                                               "function":"pxn_demo_led_state",
                                               "run_count":-1,
                                               "interval": 100
                                           },

                                           update: function (interval_a) {
                                               this.set(interval_a)
                                               this.send(this)
                                           },

                                           set: function (interval_a) {
                                               this.payload.interval = interval_a
                                           },

                                           send: function () { CorePlatformInterface.send(this) },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

    property var stop_peroidic_hdl : ({
                                          "cmd" : "stop_periodic",
                                          "payload": {
                                              "function":"pxn_demo_led_state"
                                          },

                                          update: function () {
                                              this.set()
                                              this.send()
                                          },

                                          set: function () {
                                          },

                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }
                                      })

//20201002YI
    property var start_periodic_mapena : ({
                                       "cmd" : "start_periodic",
                                       "payload": {
                                           "function":"pxnBRCMAPENCommand",
                                           "run_count":-1,
                                           "interval":100
                                       },

                                       update: function (function_a,run_count_a,interval_a) {
                                           this.set(function_a,run_count_a,interval_a)
                                           this.send(this)
                                           },
                                       set: function (function_a,run_count_a,interval_a) {
                                           this.payload.function = function_a
                                           this.payload.run_count = run_count_a
                                           this.payload.interval = interval_a
                                       },
                                           send: function () { CorePlatformInterface.send(this) },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

//20201002YI
    property var stop_periodic_mapena : ({
                                      "cmd" : "stop_periodic",
                                      "payload": {
                                          "function":"pxnBRCMAPENCommand"
                                      },

                                      update: function () {
                                          this.set()
                                          this.send()
                                      },

                                      set: function () {
                                      },

                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })


//    //20201023YI
//        property var start_periodic_diagread : ({
//                                           "cmd" : "start_periodic_diagread",
//                                           "payload": {
//                                               "function":"pxn_diag_clear",
//                                               "run_count":-1,
//                                               "interval":500
//                                           },

//                                           update: function (function_a,run_count_a,interval_a) {
//                                               this.set(function_a,run_count_a,interval_a)
//                                               this.send(this)
//                                               },
//                                           set: function (function_a,run_count_a,interval_a) {
//                                               this.payload.function = function_a
//                                               this.payload.run_count = run_count_a
//                                               this.payload.interval = interval_a
//                                           },
//                                               send: function () { CorePlatformInterface.send(this) },
//                                               show: function () { CorePlatformInterface.show(this) }
//                                           })

//    //20201023YI
//        property var stop_periodic_diagread : ({
//                                          "cmd" : "stop_periodic_diagread",
//                                          "payload": {
//                                              "function":"pxn_diag_clear"
//                                          },

//                                          update: function () {
//                                              this.set()
//                                              this.send()
//                                          },

//                                          set: function () {
//                                          },

//                                          send: function () { CorePlatformInterface.send(this) },
//                                          show: function () { CorePlatformInterface.show(this) }
//                                      })



    property bool boost_enable_state: false
    property bool buck1_enable_state: false
    property bool buck2_enable_state: false
    property bool buck3_enable_state: false
    property bool buck4_enable_state: false
    property bool buck5_enable_state: false
    property bool buck6_enable_state: false
    property bool auto_addr_enable_state: false
    property bool auto_addr_led_state: false
    property bool demo_mode_enable_state: false

    property bool boost_led_state: false
    property bool buck1_led_state: false
    property bool buck2_led_state: false
    property bool buck3_led_state: false
    property bool buck4_led_state: false
    property bool buck5_led_state: false
    property bool buck6_led_state: false

    property bool demo_led_num_1: true
    property bool demo_led_num_2: false
    property bool demo_led_num_3: false
    property bool demo_led_num_4: false
    property bool demo_led_num_5: false

    property bool demo_count_1: false
    property bool demo_count_2: false
    property bool demo_count_3: false
    property bool demo_count_4: false
    property bool demo_count_5: false

    property bool star_demo: true
    property bool curtain_demo: false
    property bool bhall_demo: false
    property bool mix_demo: false

    property string demo_led11_color: "off"
    property string demo_led12_color: "off"
    property string demo_led13_color: "off"
    property string demo_led14_color: "off"
    property string demo_led15_color: "off"
    property string demo_led16_color: "off"
    property string demo_led17_color: "off"
    property string demo_led18_color: "off"
    property string demo_led19_color: "off"
    property string demo_led1A_color: "off"
    property string demo_led1B_color: "off"
    property string demo_led1C_color: "off"

    property string demo_led21_color: "off"
    property string demo_led22_color: "off"
    property string demo_led23_color: "off"
    property string demo_led24_color: "off"
    property string demo_led25_color: "off"
    property string demo_led26_color: "off"
    property string demo_led27_color: "off"
    property string demo_led28_color: "off"
    property string demo_led29_color: "off"
    property string demo_led2A_color: "off"
    property string demo_led2B_color: "off"
    property string demo_led2C_color: "off"

    property string demo_led31_color: "off"
    property string demo_led32_color: "off"
    property string demo_led33_color: "off"
    property string demo_led34_color: "off"
    property string demo_led35_color: "off"
    property string demo_led36_color: "off"
    property string demo_led37_color: "off"
    property string demo_led38_color: "off"
    property string demo_led39_color: "off"
    property string demo_led3A_color: "off"
    property string demo_led3B_color: "off"
    property string demo_led3C_color: "off"

    property bool handler_start: false

    property bool buck1_diag: false
    property bool buck2_diag: false
    property bool buck3_diag: false

    property bool buck1_monitor: false
    property bool buck2_monitor: false
    property bool buck3_monitor: false

    property bool pxn1_diag: false
    property bool pxn2_diag: false
    property bool pxn3_diag: false

    property bool buck_diag_openled1_led: false
    property bool buck_diag_shortled1_led: false
    property bool buck_diag_ocled1_led: false
    property bool buck_diag_openled2_led: false
    property bool buck_diag_shortled2_led: false
    property bool buck_diag_ocled2_led: false

    property bool buck_diag_hwr_led: false
    property bool buck_diag_led1val_led: false
    property bool buck_diag_led2val_led: false
    property bool buck_diag_spierr_led: false
    property bool buck_diag_tsd_led: false
    property bool buck_diag_tw_led: false

    property bool clear_intensity_slider_led1: true
    property bool clear_intensity_slider_led2: true
    property bool clear_intensity_slider_led3: true

    property bool clear_demo_setup: true

    property bool auto_addr_sw_block: false


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
