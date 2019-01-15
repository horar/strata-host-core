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

    property var nl7sz58_io_state: {
                                        "a":0,
                                        "b":1,
                                        "c":0,
                                        "y":1
    }

    property var nl7sz97_io_state: {
                                        "a":1,
                                        "b":0,
                                        "c":1,
                                        "y":1
    }

    // @notification input_voltage_notification

    // -------------------  end notification messages


    // -------------------
    // Commands
    // TO SEND A COMMAND DO THE FOLLOWING:
    // EXAMPLE: To send the motor speed: platformInterface.motor_speed.update(motorSpeedSliderValue)
    // where motorSpeedSliderValue is the value set as speed and send to platform.
    // motor_speed is the command and update is the function in the command which sends the
    // notification

    // TO SYNCHRONIZE THE SPEED ON ALL THE VIEW DO THE FOLLOWING:
    // EXAMPLE: platformInterface.motorSpeedSliderValue

    /*********
      Logic Gate Commands
    *********/

    property var write_io: ({
                                "cmd":"nl7sz58_write_io",
                                "payload":{
                                            "a":1,
                                            "b":0,
                                            "c":1
                                },
                                update: function (a,b,c) {
                                    this.set(a,b,c)
                                    CorePlatformInterface.send(this)
                                },
                                set: function (a,b,c) {
                                    this.payload.a = a
                                    this.payload.b = b
                                    this.payload.c = c
                                },
                                send: function () { CorePlatformInterface.send(this) },
                            })


    property var read_io: ({
                               "cmd":"nl7sz58_read_io",
                               update: function () {
                                   CorePlatformInterface.send(this)
                               },
                               send: function () { CorePlatformInterface.send(this) },
                           })

    property var off_led : ({
                                "cmd":"nl7sz58_off",
                                update: function () {
                                    CorePlatformInterface.send(this)
                                },
                                send: function () { CorePlatformInterface.send(this) },
                            })

    property var nand: ({
                            "cmd":"nl7sz58_nand",
                            update: function () {
                                CorePlatformInterface.send(this)
                            },
                            send: function () { CorePlatformInterface.send(this) },
                        })


    property var and_nb : ({
                               "cmd":"nl7sz58_and_nb",
                               update: function () {
                                   CorePlatformInterface.send(this)
                               },
                               send: function () { CorePlatformInterface.send(this) },
                           })

    property var and_nc: ({
                              "cmd":"nl7sz58_and_nc",
                              update: function () {
                                  CorePlatformInterface.send(this)
                              },
                              send: function () { CorePlatformInterface.send(this) },
                          })

    property var or:( {"cmd":"nl7sz58_or",
                         update: function () {
                             CorePlatformInterface.send(this)
                         },
                         send: function () { CorePlatformInterface.send(this) },
                     })

    property var xor : ({"cmd":"nl7sz58_xor",
                            update: function () {
                                CorePlatformInterface.send(this)
                            },
                            send: function () { CorePlatformInterface.send(this) },
                        })

    property var  buffer:  ({"cmd":"nl7sz58_buffer",
                                update: function () {
                                    CorePlatformInterface.send(this)
                                },
                                send: function () { CorePlatformInterface.send(this) },
                            })

    property var inverter: ({"cmd":"nl7sz58_inverter",
                                update: function () {
                                    CorePlatformInterface.send(this)
                                },
                                send: function () { CorePlatformInterface.send(this) },
                            })

    /******
      NL7SZ97 logic gate
    *******/

    property var write_io_97: ({
                                   "cmd":"nl7sz97_write_io",
                                   "payload":{
                                               "a":1,
                                               "b":0,
                                               "c":1
                                   },
                                   update: function (a,b,c) {
                                       this.set(a,b,c)
                                       CorePlatformInterface.send(this)
                                   },
                                   set: function (a,b,c) {
                                       this.payload.a = a
                                       this.payload.b = b
                                       this.payload.c = c

                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                               })

    property var read_io_97: ({
                                  "cmd":"nl7sz97_read_io",
                                  update: function () {
                                      CorePlatformInterface.send(this)
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                              })

    property var off_97_led : ({"cmd":"nl7sz97_off",
                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                               })

    property var mux_97 : ({"cmd":"nl7sz97_mux",
                               update: function () {
                                   CorePlatformInterface.send(this)
                               },
                               send: function () { CorePlatformInterface.send(this) },
                           })

    property var and_97 : ({"cmd":"nl7sz97_and",
                               update: function () {
                                   CorePlatformInterface.send(this)
                               },
                               send: function () { CorePlatformInterface.send(this) },
                           })

    property var or_nc_97 : ({"cmd":"nl7sz97_or_nc",
                                 update: function () {
                                     CorePlatformInterface.send(this)
                                 },
                                 send: function () { CorePlatformInterface.send(this) },
                             })

    property var and_nc_97 : ({"cmd":"nl7sz97_and_nc",
                                  update: function () {
                                      CorePlatformInterface.send(this)
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                              })

    property var or_97: ({"cmd":"nl7sz97_or",
                             update: function () {
                                 CorePlatformInterface.send(this)
                             },
                             send: function () { CorePlatformInterface.send(this) },
                         })

    property var  buffer_97:  ({"cmd":"nl7sz97_buffer",
                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                               })

    property var inverter_97: ({"cmd":"nl7sz97_inverter",
                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                               })

    // -------------------  end commands

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
//            console.log("when in connection")
            CorePlatformInterface.data_source_handler(payload)
        }
    }
}
