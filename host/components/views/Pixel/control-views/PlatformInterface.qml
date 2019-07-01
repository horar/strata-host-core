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
    property var boost_state : {
        "state": "boost_off"
    }

    property var buck_state : {
        "state": "buck1_off"
    }

    property var auto_addressing : {
        "state": "off"

    }

    //    property var demo_mode : {
    //        "state": "off"

    //    }




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
                                             "intensity": 50,
                                             "demo_time": 1.00

                                         },

                                         update: function (mode_a, led_num_a, intensity_a, time_a) {
                                             this.set(mode_a,led_num_a,intensity_a,time_a)
                                             this.send(this)
                                         },

                                         set: function (mode_a,led_num_a,intensity_a,time_a) {
                                             this.payload.mode = mode_a
                                             this.payload.led_num = led_num_a
                                             this.payload.intensity = intensity_a
                                             this.payload.time = time_a
                                         },

                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }
                                     })

    property var device_init : ({
                                    "cmd" : "device_initialization",
                                    "payload": {
                                        "init": 1
                                    },

                                    update: function (init_a) {
                                        this.set(init_a)
                                        this.send(this)
                                    },

                                    set: function (init_a) {
                                        this.payload.init = init_a
                                    },

                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })


    property var periodic_hdl_start : ({
                                           "cmd" : "start_periodic",
                                           "payload": {
                                               "function": "periodic_example_response",
                                               "run_count":-1,
                                               "interval": 1000
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

    property var periodic_hdl_update : ({
                                           "cmd" : "update_periodic",
                                           "payload": {
                                               "function": "periodic_example_response",
                                               "run_count":-1,
                                               "interval": 1000
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

    property var periodic_hdl_stop : ({
                                           "cmd" : "stop_periodic",
                                           "payload": {
                                               "function": "periodic_example_response"
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


    property bool boost_enable_state: false
    property bool buck1_enable_state: false
    property bool buck2_enable_state: false
    property bool buck3_enable_state: false
    property bool buck4_enable_state: false
    property bool buck5_enable_state: false
    property bool buck6_enable_state: false
    property bool auto_addr_enable_state: false
    property bool demo_mode_enable_state: false
    property bool demo_stop : true

    property bool boost_led_state: false
    property bool buck1_led_state: false
    property bool buck2_led_state: false
    property bool buck3_led_state: false
    property bool buck4_led_state: false
    property bool buck5_led_state: false
    property bool buck6_led_state: false

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
