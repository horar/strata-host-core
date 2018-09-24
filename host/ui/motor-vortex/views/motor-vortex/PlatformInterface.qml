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

    // @notification pi_stats
    // @description: show motor statistics.
    //
    property var pi_stats : {
        "speed_target": 1500,
                "current_speed": 0,
                "error": 0,
                "sum": 0.5,
                "duty_now": 0.5,
                "mode": "manual"  // "manual" "automation"
    }


    // @notification input_voltage_notification
    // @description: updates voltage
    //
    property var input_voltage_notification : {
        "vin": 0
    }

    // @notification system_error
    // @description: updates faults in AdvancedControl and FAEControl
    //
    property var system_error: {
        "error_and_warnings" : [ ]
    }

    property var motor_off: {
        "enable" : ""
    }

    property var set_mode: {
        "system_mode" : ""
    }


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

    property var motor_speed : ({
                                    "cmd" : "speed_input",
                                    "payload": {
                                        "speed_target": 1500 // default value
                                    },

                                    // Update will set and send in one shot
                                    update: function (speed) {
                                        this.set(speed)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (speed) {
                                        this.payload.speed_target = speed;
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })



    /*
       system_mode_selection Command
     */
    property var system_mode_selection: ({
                                             "cmd" : "set_system_mode",
                                             "payload": {
                                                 "system_mode":" " // "automation" or "manual"
                                             },

                                             // Update will set and send in one shot
                                             update: function (system_mode) {
                                                 this.set(system_mode)
                                                 CorePlatformInterface.send(this)
                                             },
                                             // Set can set single or multiple properties before sending to platform
                                             set: function (system_mode) {
                                                 this.payload.system_mode = system_mode;
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }



                                         })
    /*
      set_drive_mode
    */
    property var set_drive_mode: ({
                                      "cmd" : "set_drive_mode",
                                      "payload": {
                                          "drive_mode" : " ",
                                      },

                                      // Update will set and send in one shot
                                      update: function (drive_mode) {
                                          this.set(drive_mode)
                                          CorePlatformInterface.send(this)
                                      },
                                      // Set can set single or multiple properties before sending to platform
                                      set: function (drive_mode) {
                                          this.payload.drive_mode = drive_mode;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }



                                  })
    /*
      Set Phase Angle
    */
    property var set_phase_angle: ({
                                       "cmd" : "set_phase_angle",
                                       "payload": {
                                           "phase_angle" : 0,
                                       },

                                       // Update will set and send in one shot
                                       update: function (phase_angle) {
                                           this.set(phase_angle)
                                           CorePlatformInterface.send(this)
                                       },
                                       // Set can set single or multiple properties before sending to platform
                                       set: function (phase_angle) {
                                           this.payload.phase_angle = phase_angle;
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }

                                   })


    /*
      Set Motor State
    */
    property var set_motor_on_off: ({
                                        "cmd" : "set_motor_on_off",
                                        "payload": {
                                            "enable": 0,
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
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }

                                    })

    /*
      Set Ramp Rate
    */
    property var set_ramp_rate: ({
                                     "cmd": "set_ramp_rate",
                                     "payload" : {
                                         "ramp_rate": ""
                                     },

                                     // Update will set and send in one shot
                                     update: function (ramp_rate) {
                                         this.set(ramp_rate)
                                         CorePlatformInterface.send(this)
                                     },
                                     // Set can set single or multiple properties before sending to platform
                                     set: function (ramp_rate) {
                                         this.payload.ramp_rate = ramp_rate;
                                         
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })

    /*
      Set Reset mcu
    */
    property var set_reset_mcu: ({
                                     "cmd": "reset_mcu",
                                     // Update will send in one shot
                                     update: function () {
                                         CorePlatformInterface.send(this)
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })

    /*
      Set LED Color Mixing
    */
    property var set_color_mixing : ({
                                         "cmd":"set_color_mixing",
                                         "payload":{
                                             "color1": "red", // color can be "red"/"green"/"blue"
                                             "color_value1": 128,// color_value varies from 0 to 255
                                             "color2": "green", // color can be "red"/"green"/"blue"
                                             "color_value2": 127, // color_value varies from 0 to 255
                                         },
                                         // Update will set and send in one shot
                                         update: function (color_1,color_value_1,color_2,color_value_2) {
                                             this.set(color_1,color_value_1,color_2,color_value_2)
                                             CorePlatformInterface.send(this)
                                         },
                                         // Set can set single or multiple properties before sending to platform
                                         set: function (color_1,color_value_1,color_2,color_value_2) {
                                             this.payload.color1 = color_1;
                                             this.payload.color_value1 = color_value_1;
                                             this.payload.color2 = color_2;
                                             this.payload.color_value2 = color_value_2;
                                         },
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }
                                         
                                     })

    /*
      Set Single Color LED
    */
    
    property var set_single_color: ({
                                        "cmd":"set_single_color",
                                        "payload":{
                                            "color": "red" ,// color can be "red"/"green"/"blue"
                                            "color_value": 120, // color_value varies from 0 to 255
                                        },
                                        // Update will set and send in one shot
                                        update: function (color,color_value) {
                                            this.set(color,color_value)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (color,color_value) {
                                            this.payload.color = color;
                                            this.payload.color_value = color_value;
                                            
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })
    /*
      set Blink0 Frequency
     */
    property var set_blink0_frequency: ({
                                            "cmd":"set_blink0_frequency",
                                            "payload":{
                                                "blink0_frequency": 2
                                            },
                                            // Update will set and send in one shot
                                            update: function (blink_0_frequency) {
                                                this.set(blink_0_frequency)
                                                CorePlatformInterface.send(this)
                                            },
                                            set: function (blink_0_frequency) {
                                                this.payload.blink0_frequency = blink_0_frequency

                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    /*
      set_led_output_on_off
     */
    property var set_led_outputs_on_off:({
                                             "cmd":"set_led_outputs_on_off",
                                             "payload":{
                                                 "led_output": "white"       // "white" for turning all LEDs ON
                                                 // "off" to turn off all the LEDs.
                                             },
                                             update: function (led_output) {
                                                 this.set(led_output)
                                                 CorePlatformInterface.send(this)
                                             },
                                             set: function (led_output) {
                                                 this.payload.led_output = led_output

                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }

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
            CorePlatformInterface.data_source_handler(payload)
        }
    }

    //-------------------------------------
    //
    // add all syncrhonized controls here
    //-----------------------------------------
    property int motorSpeedSliderValue: 1500

    onMotorSpeedSliderValueChanged: {
            motor_speed.update(motorSpeedSliderValue)
    }

    property bool sliderUpdateSignal: false
    property int rampRateSliderValue: 3

    onRampRateSliderValueChanged: {
        set_ramp_rate.update(rampRateSliderValue)
    }

    property int rampRateSliderValueForFae: 3

    onRampRateSliderValueForFaeChanged: {
        set_ramp_rate.update(rampRateSliderValueForFae)
    }

    property int phaseAngle : 15

    onPhaseAngleChanged: {
        set_phase_angle.update(phaseAngle)
    }

    property real ledSlider: 128

    onLedSliderChanged: {
        console.log("in signal control")
    }

    property real singleLEDSlider :  0

    property int ledPulseSlider: 150

    onLedPulseSliderChanged:  {
        set_blink0_frequency.update(ledPulseSlider)
    }

    property bool driveModePseudoSinusoidal: false

    onDriveModePseudoSinusoidalChanged: {

        if(driveModePseudoSinusoidal == true) {
            set_drive_mode.update(1)
        }
    }

    property bool driveModePseudoTrapezoidal: true

    onDriveModePseudoTrapezoidalChanged: {
        if(driveModePseudoTrapezoidal == true) {
            set_drive_mode.update(0)
        }
    }

    property bool systemModeManual: true

    onSystemModeManualChanged: {
        console.log("manual mode")
            system_mode_selection.update("manual")

    }

    property bool systemModeAuto: false

    onSystemModeAutoChanged: {
            system_mode_selection.update("automation")

    }

    property bool motorState: false

    onMotorStateChanged: {
        console.log("in motor state")
        if(motorState === true) {
            set_motor_on_off.update(0)
        }
        else  {
            /*
              Tanya: To fast on mac and we lose the first command send.
              Works on Windows. Would need a Timer in Mac
            */
            motor_speed.update(motorSpeedSliderValue);
            set_motor_on_off.update(1);

        }

    }

    property bool advertise;





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
