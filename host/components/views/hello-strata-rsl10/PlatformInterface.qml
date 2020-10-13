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
                                      "cmd":"ctl_state",
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

    property string pot_switch_state: ""
    property var pot: {
        "volts":0.0,
        "bits":1000
    }

    // -------------------------------------------------------------------
    // DAC and PWM to LED APIs

    // UI state
    property real pwm_led_ui_freq: 1
    property real pwm_led_ui_duty: 0
    property real dac_led_ui_volt: 0

    // notification for control state
    property var led_pwm_ctl_value: {
        "duty":0,
        "frequency": 10
    }
    onLed_pwm_ctl_valueChanged: {
        pwm_led_ui_duty = (led_pwm_ctl_value.duty * 100).toFixed(0)
        pwm_led_ui_freq = (Number(led_pwm_ctl_value.frequency))
    }

    property var dac_led_ctl_value: {
        "dac_led":0
    }
    onDac_led_ctl_valueChanged: dac_led_ui_volt = dac_led_ctl_value.dac_led


    property var set_pwm_led: ({
                                   "cmd": "led_pwm_control",
                                   "payload": {
                                       "duty":0.00,
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

    property var dac_led_set_voltage: ({
                                           "cmd":"dac_led",
                                           "payload": {
                                               "value":0
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
    // PWM Motor Control APIs

    // UI state
    property real pwm_mot_ui_duty: 0
    property real pwm_mot_ui_freq: 0
    property string pwm_mot_ui_control: "Forward"
    property bool pwm_mot_ui_enable: false

    // notification for control state
    property var motor_ctl_value: {
        "duty":0,
        "direction":"Forward",
        "enable":false,
        "frequency":0
    }
    onMotor_ctl_valueChanged: {
        pwm_mot_ui_freq = motor_ctl_value.frequency.toFixed(1)
        pwm_mot_ui_duty = (motor_ctl_value.duty*100).toFixed(0)
        pwm_mot_ui_control = motor_ctl_value.direction
        pwm_mot_ui_enable = motor_ctl_value.enable
    }

    property var set_motor_control: ({
                                         "cmd":"motor_control",
                                         "payload": {
                                             "enable": true,
                                             "direction":"Forward",
                                             "duty":0.0,
                                             "frequency":0.0
                                         },
                                         update: function (enable,direction,duty,frequency) {
                                             this.set(enable,direction,duty,frequency)
                                             this.send()
                                         },
                                         set: function (enable,direction,duty,frequency) {
                                             this.payload.enable = enable
                                             this.payload.direction = direction
                                             this.payload.duty = duty
                                             this.payload.frequency = frequency
                                         },
                                         send: function () { CorePlatformInterface.send(this) }
                                     })

    // -------------------------------------------------------------------
    // PWM Heat Generator APIs

    // UI state


    property var temp_ctl_value: {
        "duty":0.30,
        "os_alert":false,
        "tos":50
    }

    property int duty_slider_value: 0
    // Notification i2c_temp_alert
    property var temp_os_alert: {
        "value": false
    }

    //Notification i2c_temp_value
    property var temp: {
        "value": 0
    }


    property var temp_duty: ({
                                 "cmd":"temp_duty",
                                 "payload": {
                                     "value": 1
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

    property var set_temp_threshold: ({
                                          "cmd":"set_temp_threshold",
                                          "payload": {
                                              "tos": 50
                                          },
                                          update: function (tos) {
                                              this.set(tos)
                                              this.send()
                                          },
                                          set: function (tos) {
                                              this.payload.tos = tos
                                          },
                                          send: function () { CorePlatformInterface.send(this) }
                                      })

    property var reset_temp_sensor: ({
                                         "cmd":"reset_temp_sensor",
                                         "payload": {
                                         },
                                         update: function () {
                                             this.send()
                                         },
                                         send: function () { CorePlatformInterface.send(this) }
                                     })

    // -------------------------------------------------------------------
    // Light Sensor APIs

    // UI state
    property bool i2c_light_ui_start: false //Manual Integration
    property bool i2c_light_ui_active: false //status
    property string i2c_light_ui_time: "12.5ms" //integ_time
    property string i2c_light_ui_gain: "1" //
    property real i2c_light_ui_sensitivity: 100

    property var light_sensor: {
        "available":false
    }

    // Notification for control state
    property var light_ctl_value: {
        "status": false,
        "sensitivity":100,
        "gain":"1",
        "integ_time":"100ms",
        "manual_integ":false


    }
    onLight_ctl_valueChanged: {
        i2c_light_ui_start = light_ctl_value.manual_integ
        i2c_light_ui_active = light_ctl_value.status
        i2c_light_ui_time = light_ctl_value.integ_time
        i2c_light_ui_gain = light_ctl_value.gain
        i2c_light_ui_sensitivity = light_ctl_value.sensitivity.toFixed(1)
    }


    // Control enable
    property var light_ctl_enable: {
        "status":true,
        "sensitivity":true,
        "gain":true,
        "integ_time":true,
        "manual_integ":false
    }


    // Notification for i2c light lux
    property var light_lux: {
        "value": 0
    }

    // Set Manual Integration to start (true) or stop (false)
    property var i2c_light_start: ({
                                       "cmd":"light_manual_integ",
                                       "payload":{
                                           "value": false
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

    // Set Status to Active (true) or Sleep (false)
    property var i2c_light_active: ({
                                        "cmd":"light_status",
                                        "payload":{
                                            "value": false
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

    // Set Integration Time with possible values: "12.5ms", "100ms", "200ms", or "Manual"
    property var i2c_light_set_integration_time: ({
                                                      "cmd":"light_integ_time",
                                                      "payload":{
                                                          "value": "12.5ms"
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
    // Set gain to possible values: "0.25", "1", "2", or "8"
    property var i2c_light_set_gain: ({
                                          "cmd":"light_gain",
                                          "payload":{
                                              "value": 1
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
    // Set sensitivity (66.7 - 150)
    property var i2c_light_set_sensitivity: ({
                                                 "cmd":"light_sensitivity",
                                                 "payload":{
                                                     "value": 100
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
    // PWM Filters APIs

    // UI state
    //    property string pwm_fil_ui_rc_mode: "volts"
    property string pwm_filter_mode: ""
    property real pwm_fil_ui_duty: 0
    property real pwm_fil_ui_freq: 100

    // notification for control state of pwm filter
    property var filter_ctl_value: {
        "frequency":200,
        "duty":0.20
    }
    onFilter_ctl_valueChanged: {
        pwm_fil_ui_duty = (filter_ctl_value.duty*100).toFixed(0)
        pwm_fil_ui_freq =  filter_ctl_value.frequency
    }

    // notification for control state of pwm filter analog
    property var filter: {
        "volts":2.44,
        "bits":3044,
        "miliamps":5
    }

    property var pwm_fil_set_duty_freq: ({
                                             "cmd":"filter_control",
                                             "payload": {
                                                 "duty":0.0,
                                                 "frequency": 10
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

    // Notification for control state for led driver
    property var led_driver_ctl_value: {
        "blink_1_duty":0.5,
        "blink_1_freq":1,
        "blink_0_duty":0.5,
        "blink_0_freq":1,
        "states":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    }
    onLed_driver_ctl_valueChanged: {
        led_driver_ui_duty1 = (led_driver_ctl_value.blink_1_duty*100).toFixed(0)
        led_driver_ui_freq1 = led_driver_ctl_value.blink_1_freq.toFixed(1)
        led_driver_ui_duty0 = (led_driver_ctl_value.blink_0_duty*100).toFixed(0)
        led_driver_ui_freq0 = led_driver_ctl_value.blink_0_freq.toFixed(1)
        led_driver_ui_y1 = led_driver_ctl_value.states[11]
        led_driver_ui_y2 = led_driver_ctl_value.states[10]
        led_driver_ui_y3 = led_driver_ctl_value.states[9]
        led_driver_ui_y4 = led_driver_ctl_value.states[8]
        led_driver_ui_b1 = led_driver_ctl_value.states[7]
        led_driver_ui_b2 = led_driver_ctl_value.states[6]
        led_driver_ui_b3 = led_driver_ctl_value.states[5]
        led_driver_ui_b4 = led_driver_ctl_value.states[4]
        led_driver_ui_g1 = led_driver_ctl_value.states[3]
        led_driver_ui_g2 = led_driver_ctl_value.states[2]
        led_driver_ui_g3 = led_driver_ctl_value.states[1]
        led_driver_ui_g4 = led_driver_ctl_value.states[0]
    }

    property var set_led_driver: ({
                                      "cmd":"led_driver",
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
                                            "cmd": "led_driver_freq0",
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
                                            "cmd":"led_driver_duty0",
                                            "payload": {
                                                "duty":0.5
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
                                            "cmd": "led_driver_freq1",
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
                                            "cmd":"led_driver_duty1",
                                            "payload": {
                                                "duty":0.5
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
                                        "cmd":"led_driver_reset",
                                        "payload": {},
                                        update: function () { CorePlatformInterface.send(this) }
                                    })

    // -------------------------------------------------------------------
    // Mechanical Buttons APIs

    // notification
    property var int_button1: {
        "value": false
    }

    property bool pwm_motor: true
    property bool dac_pwm: false
    property bool pwm_LED_filter: true

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
