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
    // Get initial control states
    property var get_all_states: ({
                                      "cmd":"get_all_states",
                                      "payload":{},
                                      update: function () { CorePlatformInterface.send(this) }
                                  })

    // -------------------------------------------------------------------
    // Potentiometer to ADC APIs

    // UI state
    property string pot_ui_mode: "volts"

    // notification for control state
    property var pot_mode_ctrl_state: {
        "value":"volts"
    }
    onPot_mode_ctrl_stateChanged: pot_ui_mode = pot_mode_ctrl_state.value

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
    property real pwm_led_ui_freq: 1
    property real pwm_led_ui_duty: 0
    property real dac_led_ui_volt: 0

    // notification for control state
    property var pwm_led_ctrl_state: {
        "duty":0
    }
    onPwm_led_ctrl_stateChanged: pwm_led_ui_duty = (pwm_led_ctrl_state.duty * 100).toFixed(0)
    property var dac_led_ctrl_state: {
        "value":0
    }
    onDac_led_ctrl_stateChanged: dac_led_ui_volt = dac_led_ctrl_state.value

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
    property string pwm_mot_ui_control: "Forward"
    property bool pwm_mot_ui_enable: false

    // notification for control state
    property var pwm_mot_ctrl_state: {
        "pwm":0,
        "control":"Forward",
        "enable":false
    }
    onPwm_mot_ctrl_stateChanged: {
        pwm_mot_ui_duty = (pwm_mot_ctrl_state.pwm*100).toFixed(0)
        pwm_mot_ui_control = pwm_mot_ctrl_state.control
        pwm_mot_ui_enable = pwm_mot_ctrl_state.enable
    }

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

    property var pwm_mot_set_control: ({
                                  "cmd":"pwm_mot_set_control",
                                  "payload": {
                                      "control":"Forward"
                                  },
                                  update: function (control) {
                                      this.set(control)
                                      this.send()
                                  },
                                  set: function (control) {
                                      this.payload.control = control
                                  },
                                  send: function () { CorePlatformInterface.send(this) }
                              })

    // -------------------------------------------------------------------
    // PWM Heat Generator APIs

    // UI state
    property real i2c_temp_ui_duty: 0

    // notification for control state
    property var i2c_temp_ctrl_state: {
        "value":0
    }
    onI2c_temp_ctrl_stateChanged: i2c_temp_ui_duty = (i2c_temp_ctrl_state.value*100).toFixed(0)

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
    // Light Sensor APIs

    // UI state
    property bool i2c_light_ui_start: false
    property bool i2c_light_ui_active: false
    property string i2c_light_ui_time: "12.5ms"
    property string i2c_light_ui_gain: "1"
    property real i2c_light_ui_sensitivity: 100

    // notification for control state
    property var i2c_light_ctrl_state: {
        "start": false,
        "active":false,
        "gain":"1",
        "refresh_time":"100ms",
        "sensitivity":100
    }
    onI2c_light_ctrl_stateChanged: {
        i2c_light_ui_start = i2c_light_ctrl_state.start
        i2c_light_ui_active = i2c_light_ctrl_state.active
        i2c_light_ui_time = i2c_light_ctrl_state.refresh_time
        i2c_light_ui_gain = i2c_light_ctrl_state.gain
        i2c_light_ui_sensitivity = i2c_light_ctrl_state.sensitivity.toFixed(1)
    }

    // notification
    property var i2c_light_noti_lux: {
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
                                    "time": "12.5ms"
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
                                    "sensitivity": 100
                                },
                                update: function (sensitivity) {
                                    console.log("GOT HERE")
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
    property real pwm_fil_ui_duty: 0
    property real pwm_fil_ui_freq: 200

    // notification for control state
    property var pwm_fil_ctrl_state: {
        "rc_value":"volts",
        "pwm_duty":0
    }
    onPwm_fil_ctrl_stateChanged: {
        pwm_fil_ui_rc_mode = pwm_fil_ctrl_state.rc_value
        pwm_fil_ui_duty = (pwm_fil_ctrl_state.pwm_duty*100).toFixed(0)
    }

    // notification
    property var pwm_fil_noti_rc_out: {
        "rc_out": 0
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

    property var pwm_fil_set_duty_freq: ({
                                     "cmd":"pwm_fil_set_duty_freq",
                                     "payload": {
                                         "duty":0,
                                         "frequency":0
                                     },
                                     update: function (duty,frequency) {
                                         this.set(duty,frequency)
                                         this.send()
                                     },
                                     set: function (duty,frequency) {
                                         this.payload.duty = duty
                                         this.payload.frequency = frequency
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    // -------------------------------------------------------------------
    // LED Driver APIs

    // UI state
    property int led_driver_ui_y1: 0
    property int led_driver_ui_y2: 0
    property int led_driver_ui_y3: 0
    property int led_driver_ui_y4: 0

    property int led_driver_ui_r1: 0
    property int led_driver_ui_r2: 0
    property int led_driver_ui_r3: 0
    property int led_driver_ui_r4: 0

    property int led_driver_ui_b1: 0
    property int led_driver_ui_b2: 0
    property int led_driver_ui_b3: 0
    property int led_driver_ui_b4: 0

    property int led_driver_ui_g1: 0
    property int led_driver_ui_g2: 0
    property int led_driver_ui_g3: 0
    property int led_driver_ui_g4: 0

    property real led_driver_ui_freq0: 1
    property real led_driver_ui_duty0: 50
    property real led_driver_ui_freq1: 1
    property real led_driver_ui_duty1: 50

    // notification for control state
    property var led_driver_ctrl_state: {
        "blink_1_duty":0.5,
        "blink_1_freq":1,
        "blink_0_duty":0.5,
        "blink_0_freq":1,
        "states":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    }
    onLed_driver_ctrl_stateChanged: {
        led_driver_ui_duty1 = (led_driver_ctrl_state.blink_1_duty*100).toFixed(0)
        led_driver_ui_freq1 = led_driver_ctrl_state.blink_1_freq
        led_driver_ui_duty0 = (led_driver_ctrl_state.blink_0_duty*100).toFixed(0)
        led_driver_ui_freq0 = led_driver_ctrl_state.blink_0_freq
        led_driver_ui_y1 = led_driver_ctrl_state.states[15]
        led_driver_ui_y2 = led_driver_ctrl_state.states[14]
        led_driver_ui_y3 = led_driver_ctrl_state.states[13]
        led_driver_ui_y4 = led_driver_ctrl_state.states[12]
        led_driver_ui_r1 = led_driver_ctrl_state.states[11]
        led_driver_ui_r2 = led_driver_ctrl_state.states[10]
        led_driver_ui_r3 = led_driver_ctrl_state.states[9]
        led_driver_ui_r4 = led_driver_ctrl_state.states[8]
        led_driver_ui_b1 = led_driver_ctrl_state.states[7]
        led_driver_ui_b2 = led_driver_ctrl_state.states[6]
        led_driver_ui_b3 = led_driver_ctrl_state.states[5]
        led_driver_ui_b4 = led_driver_ctrl_state.states[4]
        led_driver_ui_g1 = led_driver_ctrl_state.states[3]
        led_driver_ui_g2 = led_driver_ctrl_state.states[2]
        led_driver_ui_g3 = led_driver_ctrl_state.states[1]
        led_driver_ui_g4 = led_driver_ctrl_state.states[0]
    }

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

    property var clear_led_driver: ({
                                        "cmd":"clear_led_driver",
                                        "payload": {},
                                        update: function () { CorePlatformInterface.send(this) }
                                    })

    // -------------------------------------------------------------------
    // Mechanical Buttons APIs

    // notification
    property var mechanical_buttons_noti_sw1: {
        "value": true
    }
    property var mechanical_buttons_noti_sw2: {
        "value": true
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
