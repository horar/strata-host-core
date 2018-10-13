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
                                show: function () { CorePlatformInterface.show(this) }
                            })


    property var read_io: ({
                               "cmd":"nl7sz58_read_io",
                               update: function () {
                                   CorePlatformInterface.send(this)
                               },
                               send: function () { CorePlatformInterface.send(this) },
                               show: function () { CorePlatformInterface.show(this) }
                           })

    property var off_led : ({
                                "cmd":"nl7sz58_off",
                                update: function () {
                                    CorePlatformInterface.send(this)
                                },
                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }
                            })

    property var nand: ({
                            "cmd":"nl7sz58_nand",
                            update: function () {
                                CorePlatformInterface.send(this)
                            },
                            send: function () { CorePlatformInterface.send(this) },
                            show: function () { CorePlatformInterface.show(this) }
                        })


    property var and_nb : ({
                               "cmd":"nl7sz58_and_nb",
                               update: function () {
                                   CorePlatformInterface.send(this)
                               },
                               send: function () { CorePlatformInterface.send(this) },
                               show: function () { CorePlatformInterface.show(this) }
                           })

    property var and_nc: ({
                              "cmd":"nl7sz58_and_nc",
                              update: function () {
                                  CorePlatformInterface.send(this)
                              },
                              send: function () { CorePlatformInterface.send(this) },
                              show: function () { CorePlatformInterface.show(this) }
                          })

    property var or:( {"cmd":"nl7sz58_or",
                         update: function () {
                             CorePlatformInterface.send(this)
                         },
                         send: function () { CorePlatformInterface.send(this) },
                         show: function () { CorePlatformInterface.show(this) }
                     })

    property var xor : ({"cmd":"nl7sz58_xor",
                            update: function () {
                                CorePlatformInterface.send(this)
                            },
                            send: function () { CorePlatformInterface.send(this) },
                            show: function () { CorePlatformInterface.show(this) }
                        })

    property var  buffer:  ({"cmd":"nl7sz58_buffer",
                                update: function () {
                                    CorePlatformInterface.send(this)
                                },
                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }
                            })

    property var inverter: ({"cmd":"nl7sz58_inverter",
                                update: function () {
                                    CorePlatformInterface.send(this)
                                },
                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }
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
                                   show: function () { CorePlatformInterface.show(this) }
                               })

    property var read_io_97: ({
                                  "cmd":"nl7sz97_read_io",
                                  update: function () {
                                      CorePlatformInterface.send(this)
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })

    property var off_97_led : ({"cmd":"nl7sz97_off",
                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }
                               })

    property var mux_97 : ({"cmd":"nl7sz97_mux",
                               update: function () {
                                   CorePlatformInterface.send(this)
                               },
                               send: function () { CorePlatformInterface.send(this) },
                               show: function () { CorePlatformInterface.show(this) }
                           })

    property var and_97 : ({"cmd":"nl7sz97_and",
                               update: function () {
                                   CorePlatformInterface.send(this)
                               },
                               send: function () { CorePlatformInterface.send(this) },
                               show: function () { CorePlatformInterface.show(this) }
                           })

    property var or_nc_97 : ({"cmd":"nl7sz97_or_nc",
                                 update: function () {
                                     CorePlatformInterface.send(this)
                                 },
                                 send: function () { CorePlatformInterface.send(this) },
                                 show: function () { CorePlatformInterface.show(this) }
                             })

    property var and_nc_97 : ({"cmd":"nl7sz97_and_nc",
                                  update: function () {
                                      CorePlatformInterface.send(this)
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })

    property var or_97: ({"cmd":"nl7sz97_or",
                             update: function () {
                                 CorePlatformInterface.send(this)
                             },
                             send: function () { CorePlatformInterface.send(this) },
                             show: function () { CorePlatformInterface.show(this) }
                         })

    property var  buffer_97:  ({"cmd":"nl7sz97_buffer",
                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }
                               })

    property var inverter_97: ({"cmd":"nl7sz97_inverter",
                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }
                               })


    // -------------------  end commands

//    // NOTE:
//    //  All internal property names for PlatformInterface must avoid name collisions with notification/cmd message properties.
//    //   naming convention to avoid name collisions;
//    // property var _name


//    // -------------------------------------------------------------------
//    // Connect to CoreInterface notification signals
//    //
//    Connections {
//        target: coreInterface
//        onNotification: {
//            console.log("when in connection")
//            CorePlatformInterface.data_source_handler(payload)
//        }
//    }

//    //-------------------------------------
//    //
//    // add all syncrhonized controls here
//    //-----------------------------------------
//    property int motorSpeedSliderValue: 1500

//    onMotorSpeedSliderValueChanged: {
//        motor_speed.update(motorSpeedSliderValue)
//    }

//    property bool sliderUpdateSignal: false
//    property int rampRateSliderValue: 3

//    onRampRateSliderValueChanged: {
//        set_ramp_rate.update(rampRateSliderValue)
//    }

//    property int rampRateSliderValueForFae: 3

//    onRampRateSliderValueForFaeChanged: {
//        set_ramp_rate.update(rampRateSliderValueForFae)
//    }

//    property int phaseAngle : 15

//    onPhaseAngleChanged: {
//        set_phase_angle.update(phaseAngle)
//    }

//    property int ledSlider: 128

//    onLedSliderChanged: {
//        console.log("in signal control")
//    }

//    property real singleLEDSlider :  0

//    property int ledPulseSlider: 150

//    onLedPulseSliderChanged:  {
//        set_blink0_frequency.update(ledPulseSlider)
//    }

//    property bool driveModePseudoSinusoidal: false

//    onDriveModePseudoSinusoidalChanged: {

//        if(driveModePseudoSinusoidal == true) {
//            set_drive_mode.update(1)
//        }
//    }

//    property bool driveModePseudoTrapezoidal: true

//    onDriveModePseudoTrapezoidalChanged: {
//        if(driveModePseudoTrapezoidal == true) {
//            set_drive_mode.update(0)
//        }
//    }

//    property bool systemModeManual: true

//    onSystemModeManualChanged: {
//        console.log("manual mode")
//        system_mode_selection.update("manual")

//    }

//    property bool systemModeAuto: false

//    onSystemModeAutoChanged: {
//        system_mode_selection.update("automation")

//    }

//    property bool motorState: false

//    onMotorStateChanged: {
//        console.log("in motor state")
//        if(motorState === true) {
//            set_motor_on_off.update(0)
//        }
//        else  {
//            /*
//              Tanya: To fast on mac and we lose the first command send.
//              Works on Windows. Would need a Timer in Mac
//            */
//            motor_speed.update(motorSpeedSliderValue);
//            set_motor_on_off.update(1);

//        }

//    }

//    property bool advertise;





    /*    // DEBUG - TODO: Faller - Remove before merging back to Dev
    Window {
        id: debug
        visible: true
        width: 200
        height: 200

        // This button sends 2 notifications in 1 JSON, future possible implementation
        Button {
            id: button1
            text: "send pi_stats and voltage"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                                        "input_voltage_notification": {
                                            "vin": '+ (Math.random()*5+10).toFixed(2) +'
                                        },
                                        "pi_stats": {
                                            "speed_target": 3216,
                                            "current_speed": '+ (Math.random()*2000+3000).toFixed(0) +',
                                            "error": -1104,
                                            "sum": -0.01,
                                            "duty_now": 0.67,
                                            "mode": "manual"
                                        }
                                    }')
            }
        }

        Button {
            id: button2
            anchors { top: button1.bottom }
            text: "send vin"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                    "value":"pi_stats",
                    "payload":{
                                "speed_target":3216,
                                "current_speed": '+ (Math.random()*2000+3000).toFixed(0) +',
                                "error":-1104,
                                "sum":-0.01,
                                "duty_now":0.67,
                                "mode":"manual"
                               }
                             }')
            }
        }
        Button {
            anchors { top: button2.bottom }
            text: "send"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"input_voltage_notification",
                            "payload":{
                                     "vin":'+ (Math.random()*5+10).toFixed(2) +'
                            }
                    }
            ')
            }
        }
    }*/
}
