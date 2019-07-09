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
    // Potentiometer to ADC APIs

    // UI state
    property string pot_ui_mode: "volts"

    // notification
    property var pot_noti: {
        "cmd_data": 0
    }

    // change mode between "volts" and "bits"
    property var pot_mode: ({
                                "cmd":"pot_mode",
                                "payload":{
                                    "mode":"volts"
                                },
                                update: function (mode) {
                                    this.set(mode)
                                    this.send()
                                },
                                set: function (mode) {
                                    this.payload.mode = mode
                                },
                                send: function () { CorePlatformInterface.send(this) }
                            })

    // -------------------------------------------------------------------
    // DAC and PWM to LED APIs

    // UI state
    property real pwm_led_ui_freq: 0
    property real pwm_led_ui_duty: 0
    property real dac_led_ui_volt: 0

    property var pwm_led_set_freq: ({
                                    "cmd": "pwm_led_set_freq",
                                     "payload": {
                                         "frequency":0
                                     },
                                     update: function (frequency) {
                                         this.set(frequency)
                                         this.send()
                                     },
                                     set: function (frequency) {
                                         this.payload.frequency = frequency
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    property var pwm_led_set_duty: ({
                                     "cmd":"pwm_led_set_duty",
                                     "payload": {
                                         "duty":0
                                     },
                                     update: function (duty) {
                                         this.set(duty)
                                         this.send()
                                     },
                                     set: function (duty) {
                                         this.payload.duty = duty
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    property var dac_led_set_voltage: ({
                                 "cmd":"dac_led_set_voltage",
                                 "payload": {
                                     "voltage":0
                                 },
                                 update: function (voltage) {
                                     this.set(voltage)
                                     this.send()
                                 },
                                 set: function (voltage) {
                                     this.payload.voltage = voltage
                                 },
                                 send: function () { CorePlatformInterface.send(this) }
                             })

    // -------------------------------------------------------------------
    // PWM Motor Control APIs

    // UI state
    property real pwm_mot_ui_duty: 0
    property bool pwm_mot_ui_forward: true
    property bool pwm_mot_ui_enable: false

    property var pwm_mot_enable: ({
                                   "cmd":"pwm_mot_enable",
                                   "payload": {
                                       "enable":false
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

    property var pwm_mot_brake: ({
                                  "cmd":"pwm_mot_brake",
                                  "payload": {
                                      "brake":false
                                  },
                                  update: function (brake) {
                                      this.set(brake)
                                      this.send()
                                  },
                                  set: function (brake) {
                                      this.payload.brake = brake
                                  },
                                  send: function () { CorePlatformInterface.send(this) }
                              })

    property var pwm_mot_set_duty: ({
                                  "cmd":"pwm_mot_set_duty",
                                  "payload": {
                                      "duty":.5
                                  },
                                  update: function (duty) {
                                      this.set(duty)
                                      this.send()
                                  },
                                  set: function (duty) {
                                      this.payload.duty = duty
                                  },
                                  send: function () { CorePlatformInterface.send(this) }
                              })

    property var pwm_mot_set_direction: ({
                                  "cmd":"pwm_mot_set_direction",
                                  "payload": {
                                      "forward":true
                                  },
                                  update: function (forward) {
                                      this.set(forward)
                                      this.send()
                                  },
                                  set: function (forward) {
                                      this.payload.forward = forward
                                  },
                                  send: function () { CorePlatformInterface.send(this) }
                              })

    // -------------------------------------------------------------------
    // PWM Heat Generator APIs

    // UI state
    property real i2c_temp_ui_duty: 0

    // notification
    property var i2c_temp_noti_alert: {
        "value": false
    }
    property var i2c_temp_noti_value: {
        "value": 0
    }

    property var i2c_temp_set_duty: ({
                                  "cmd":"i2c_temp_set_duty",
                                  "payload": {
                                      "duty":.5
                                  },
                                  update: function (duty) {
                                      this.set(duty)
                                      this.send()
                                  },
                                  set: function (duty) {
                                      this.payload.duty = duty
                                  },
                                  send: function () { CorePlatformInterface.send(this) }
                              })

    // -------------------------------------------------------------------
    // Light Sensor APIs

    // UI state
    property bool i2c_light_ui_start: false
    property bool i2c_light_ui_active: false
    property int i2c_light_ui_time: 0
    property int i2c_light_ui_gain: 1
    property real i2c_light_ui_sensitivity: 1

    // notification
    property var i2c_light_noti_lux: {
        "value": 0
    }
    property var i2c_light_noti_light_intensity: {
        "value": 0
    }

    property var i2c_light_start: ({
                                "cmd":"i2c_light_start",
                                "payload":{
                                    "start": false
                                },
                                update: function (start) {
                                    this.set(start)
                                    this.send()
                                },
                                set: function (start) {
                                    this.payload.start = start
                                },
                                send: function () { CorePlatformInterface.send(this) }
                            })

    property var i2c_light_active: ({
                                "cmd":"i2c_light_active",
                                "payload":{
                                    "active": false
                                },
                                update: function (active) {
                                    this.set(active)
                                    this.send()
                                },
                                set: function (active) {
                                    this.payload.active = active
                                },
                                send: function () { CorePlatformInterface.send(this) }
                            })

    property var i2c_light_set_integration_time: ({
                                "cmd":"i2c_light_set_integration_time",
                                "payload":{
                                    "time": 12.5
                                },
                                update: function (time) {
                                    this.set(time)
                                    this.send()
                                },
                                set: function (time) {
                                    this.payload.time = time
                                },
                                send: function () { CorePlatformInterface.send(this) }
                            })

    property var i2c_light_set_gain: ({
                                "cmd":"i2c_light_set_gain",
                                "payload":{
                                    "gain": 1
                                },
                                update: function (gain) {
                                    this.set(gain)
                                    this.send()
                                },
                                set: function (gain) {
                                    this.payload.gain = gain
                                },
                                send: function () { CorePlatformInterface.send(this) }
                            })

    property var i2c_light_set_sensitivity: ({
                                "cmd":"i2c_light_set_sensitivity",
                                "payload":{
                                    "sensitivity": 1
                                },
                                update: function (sensitivity) {
                                    this.set(sensitivity)
                                    this.send()
                                },
                                set: function (sensitivity) {
                                    this.payload.sensitivity = sensitivity
                                },
                                send: function () { CorePlatformInterface.send(this) }
                            })

    // -------------------------------------------------------------------
    // PWM Filters APIs

    // UI state
    property string pwm_fil_ui_rc_mode: "volts"
    property string pwm_fil_ui_lc_mode: "volts"
    property real pwm_fil_ui_duty: 0
    property real pwm_fil_ui_freq: 0

    // notification
    property var pwm_fil_noti_rc_out: {
        "rc_out": 0
    }
    property var pwm_fil_noti_lc_out: {
        "lc_out": 0
    }

    property var pwm_fil_set_rc_out_mode: ({
                                "cmd":"pwm_fil_set_rc_out_mode",
                                "payload":{

                                },
                                update: function (mode) {
                                    this.set(mode)
                                    this.send()
                                },
                                set: function (mode) {
                                    this.payload.mode = mode
                                },
                                send: function () { CorePlatformInterface.send(this) }
                            })

    property var pwm_fil_set_lc_out_mode: ({
                                "cmd":"pwm_fil_set_lc_out_mode",
                                "payload":{

                                },
                                update: function (mode) {
                                    this.set(mode)
                                    this.send()
                                },
                                set: function (mode) {
                                    this.payload.mode = mode
                                },
                                send: function () { CorePlatformInterface.send(this) }
                            })

    property var pwm_fil_set_freq: ({
                                    "cmd": "pwm_fil_set_freq",
                                     "payload": {
                                         "frequency":0
                                     },
                                     update: function (frequency) {
                                         this.set(frequency)
                                         this.send()
                                     },
                                     set: function (frequency) {
                                         this.payload.frequency = frequency
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    property var pwm_fil_set_duty: ({
                                     "cmd":"pwm_fil_set_duty",
                                     "payload": {
                                         "duty":0
                                     },
                                     update: function (duty) {
                                         this.set(duty)
                                         this.send()
                                     },
                                     set: function (duty) {
                                         this.payload.duty = duty
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    // -------------------------------------------------------------------
    // LED Driver APIs

    // UI state
    property bool led_driver_ui_y1: false
    property bool led_driver_ui_y2: false
    property bool led_driver_ui_y3: false
    property bool led_driver_ui_y4: false

    property bool led_driver_ui_r1: false
    property bool led_driver_ui_r2: false
    property bool led_driver_ui_r3: false
    property bool led_driver_ui_r4: false

    property bool led_driver_ui_b1: false
    property bool led_driver_ui_b2: false
    property bool led_driver_ui_b3: false
    property bool led_driver_ui_b4: false

    property bool led_driver_ui_g1: false
    property bool led_driver_ui_g2: false
    property bool led_driver_ui_g3: false
    property bool led_driver_ui_g4: false

    property int led_driver_ui_state: 0
    property real led_driver_ui_freq0: 1
    property real led_driver_ui_pwm0: 50
    property real led_driver_ui_freq1: 1
    property real led_driver_ui_pwm1: 50

    property var set_led_driver: ({
                                "cmd":"set_led_driver",
                                "payload":{
                                    "led": 1,
                                    "state": 1
                                },
                                update: function (led, state) {
                                    this.set(led, state)
                                    this.send()
                                },
                                set: function (led, state) {
                                    this.payload.led = led
                                    this.payload.state = state
                                },
                                send: function () { CorePlatformInterface.send(this) }
                            })

    property var set_led_driver_freq0: ({
                                    "cmd": "set_led_driver_freq0",
                                     "payload": {
                                         "frequency":0
                                     },
                                     update: function (frequency) {
                                         this.set(frequency)
                                         this.send()
                                     },
                                     set: function (frequency) {
                                         this.payload.frequency = frequency
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    property var set_led_driver_duty0: ({
                                     "cmd":"set_led_driver_duty0",
                                     "payload": {
                                         "duty":0
                                     },
                                     update: function (duty) {
                                         this.set(duty)
                                         this.send()
                                     },
                                     set: function (duty) {
                                         this.payload.duty = duty
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    property var set_led_driver_freq1: ({
                                    "cmd": "set_led_driver_freq1",
                                     "payload": {
                                         "frequency":0
                                     },
                                     update: function (frequency) {
                                         this.set(frequency)
                                         this.send()
                                     },
                                     set: function (frequency) {
                                         this.payload.frequency = frequency
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    property var set_led_driver_duty1: ({
                                     "cmd":"set_led_driver_duty1",
                                     "payload": {
                                         "duty":0
                                     },
                                     update: function (duty) {
                                         this.set(duty)
                                         this.send()
                                     },
                                     set: function (duty) {
                                         this.payload.duty = duty
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    // -------------------------------------------------------------------
    // Mechanical Buttons APIs

    // notification
    property var mechanical_buttons_noti_sw1: {
        "value": false
    }
    property var mechanical_buttons_noti_sw2: {
        "value": false
    }
    property var mechanical_buttons_noti_sw3: {
        "value": false
    }
    property var mechanical_buttons_noti_sw4: {
        "value": false
    }

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
