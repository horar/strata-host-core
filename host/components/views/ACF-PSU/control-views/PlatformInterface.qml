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


    // -------------------------------------------------------------------
    // Incoming Notification Messages
    //
    // Define and document incoming notification messages here.
    //
    // The property name *must* match the associated notification value.
    // Sets UI Control State when changed.


    // @notification: power_notification
    // @description: update all information (e.g.input voltage, curent, power, line freqency, output voltage, current, power, loss and efficiency
//    property var auto_cal_response:  {
//        "response" : "finish"
//    }


    property var power_notification : {
        "vin"   : "-",
        "iin"   : "-",
        "lfin"  : "-",
        "rpin"  : "-",
        "apin"  : "-",
        "acpin" : "-",
        "pfin"  : "-",
        "vout"  : "-",
        "iout"  : "-",
        "pout"  : "-",
        "loss"  : "-",
        "n"     : "-"
    }

    property var primary_voltage: {
        "vin"   : "-",
        "status" : "NG"
    }

    property var primary_current: {
        "iin"   : "-",
        "status" : "NG"
    }

    property var primary_frequency: {
        "lfin"  : "-",
        "status" : "NG"
    }

    property var primary_apparent_power: {
        "apin"  : "-",
        "status" : "NG"
    }

    property var primary_active_power: {
        "acpin" : "-",
        "status" : "NG"
    }

    property var primary_reactive_power: {
        "rpin"  : "-",
        "status" : "NG"
    }

    property var primary_power_factor: {
        "pfin"  : "-"
    }

    property var secondary_power: {
        "vout"  : "-",
        "iout"  : "-",
        "pout"  : "-"
    }

    property var efficiency_loss: {
        "loss" :  "-",
        "n" :  "-"
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
    property var measure_voltage_cmd : ({
                                            "cmd" : "measure_voltage",

                                            update: function () {
                                                this.set()
                                                this.send()
                                            },
                                            set: function () {
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var measure_current_cmd : ({
                                            "cmd" : "measure_current",

                                            update: function () {
                                                this.set()
                                                this.send()
                                            },
                                            set: function () {
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var measure_frequency_cmd : ({
                                            "cmd" : "measure_frequency",

                                            update: function () {
                                                this.set()
                                                this.send()
                                            },
                                            set: function () {
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var measure_apparent_cmd : ({
                                            "cmd" : "measure_apparent",

                                            update: function () {
                                                this.set()
                                                this.send()
                                            },
                                            set: function () {
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var measure_active_cmd : ({
                                            "cmd" : "measure_active",

                                            update: function () {
                                                this.set()
                                                this.send()
                                            },
                                            set: function () {
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var measure_reactive_cmd : ({
                                            "cmd" : "measure_reactive",

                                            update: function () {
                                                this.set()
                                                this.send()
                                            },
                                            set: function () {
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var measure_pf_cmd : ({
                                            "cmd" : "measure_pf",

                                            update: function () {
                                                this.set()
                                                this.send()
                                            },
                                            set: function () {
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var measure_second_cmd : ({
                                            "cmd" : "measure_second_power",

                                            update: function () {
                                                this.set()
                                                this.send()
                                            },
                                            set: function () {
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var measure_efficiency_cmd : ({
                                            "cmd" : "measure_efficiency",

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
                                               "function":"power_notification",
                                               "run_count":-1,
                                               "interval": 1000
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

    property var stop_peroidic_hdl : ({
                                          "cmd" : "stop_periodic",
                                          "payload": {
                                              "function":"power_notification"
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


    property bool state_debug_vol: false
    property bool state_debug_cur: false
    property bool state_debug_ap_power: false
    property bool state_debug_ac_power: false
    property bool state_debug_ra_power: false
    property bool state_debug_lf: false
    property bool state_debug_pf: false

    property bool state_debug_sec: false
    property bool state_debug_n: false
    property bool state_debug_start_notif: false
    property bool state_stop_periodic_noti: false



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
