import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------------------------------------------------------
    // Test platform interface command

    property var test: ({
                            "cmd":"request_platform_id",
                            update: function () {
                                CorePlatformInterface.send(this)
                            },
                            send: function () { CorePlatformInterface.send(this) }
                        })

    // -------------------------------------------------------------------
    // Get initial states

    property var get_all_states: ({
                                      "cmd":"get_all_states",
                                      update: function () {
                                          CorePlatformInterface.send(this)
                                      },
                                      send: function () { CorePlatformInterface.send(this) }
                                  })

    property var control_states: ({
                                      "enable":false,
                                      "slew_rate":"13.7 kV/s",
                                      "sc_en":false,
                                      "vcc_sel":"5"
                                  })

    // -------------------------------------------------------------------
    // Telemetry

    property var telemetry: ({
                                 "temperature":"0",
                                 "vcc":"0",
                                 "vin":"0",
                                 "vout":"0",
                                 "iin":"0",
                                 "vdrop":"0",
                                 "ploss":"0"
                             })

    // -------------------------------------------------------------------
    // Interrupts

    property var int_vin_lw_th: ({
                                     "value":false
                                 })

    property var int_vin_up_th: ({
                                     "value":false
                                 })

    property var int_pg: ({
                              "value":false
                          })

    property var int_os_alert: ({
                                    "value":false
                                })

    property var i_lim_popup: ({
                                   "i_lim": "15.000",

                               })

    property var sc_status: ({
                                 "value": "success"
                             })
    // -------------------------------------------------------------------
    // Enables

    property var set_enable: ({
                                  "cmd":"set_enable",
                                  "payload":{
                                      "enable":"on"
                                  },
                                  update: function (enable) {
                                      this.set(enable)
                                      this.send()
                                  },
                                  set: function (enable) {
                                      this.payload.enable = enable
                                  },
                                  send: function () { CorePlatformInterface.send(this) }
                              })


    property var check_i_lim: ({
                                   "cmd":"check_i_lim",
                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) }
                               })



    property var short_circuit_enable: ({
                                            "cmd":"short_circuit_enable",
                                            update: function () {
                                                CorePlatformInterface.send(this)
                                            },
                                            send: function () { CorePlatformInterface.send(this) }
                                        })

    // -------------------------------------------------------------------
    // Set Slew Rate

    property var set_slew_rate: ({
                                     "cmd":"set_slew_rate",
                                     "payload":{
                                         "slew_rate":"13.7 kV/s"
                                     },
                                     update: function (slew_rate) {
                                         this.set(slew_rate)
                                         this.send()
                                     },
                                     set: function (slew_rate) {
                                         this.payload.slew_rate = slew_rate
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    // -------------------------------------------------------------------
    // Set VCC

    property var set_vcc: ({
                               "cmd":"set_vcc",
                               "payload":{
                                   "value":"3.3"
                               },
                               update: function (value) {
                                   this.set(value)
                                   this.send()
                               },
                               set: function (value) {
                                   this.payload.value = value
                               },
                               send: function () { CorePlatformInterface.send(this) }
                           })

    // -------------------------------------------------------------------
    // Helper functions

    function send (command) {
        console.log("send:", JSON.stringify(command));
        coreInterface.sendCommand(JSON.stringify(command))
    }

    function show (command) {
        console.log("show:", JSON.stringify(command));
    }

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
