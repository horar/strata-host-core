import QtQuick 2.12

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




    // -------------------------------------------------------------------
    // Incoming Notification Messages
    //
    // Define and document incoming notification messages here.
    //
    // The property name *must* match the associated notification value.
    // Sets UI Control State when changed.

    property var led_out_en: {
        "caption":"OUT EN",
        "scales":[],
        "state":"enabled",
        "value":"",
        "values":[true,true,true,true,true,true,true,true,true,true,true,true]
    }

    property var led_out_en_caption: {
        "caption":"OUT EN"
    }

    property var led_out_en_state: {
        "state":"enabled"
    }
    property var led_out_en_values: {
        "values": [true,true,true,true,true,true,true,true,true,true,true,true]
    }

    property var led_ext: {
        "caption":"External LED",
        "scales":[],
        "state":"enabled",
        "value":"",
        "values":[false,false,false,false,false,false,false,false,false,false,false,false]
    }


    property var led_ext_caption: {
        "caption":"External LED"
    }

    property var led_ext_state: {
        "state":"enabled"
    }
    property var led_ext_values: {
        "values": [false,false,false,false,false,false,false,false,false,false,false,false]
    }

    property var led_fault_status: {
        "caption":"Fault Status",
        "scales":[],
        "state":"disabled",
        "value":"",
        "values":[false,false,false,false,false,false,false,false,false,false,false,false]
    }


    property var led_fault_status_caption: {
        "caption":"Fault Status"
    }


    property var led_fault_status_state: {
        "state":"disabled"
    }
    property var led_fault_status_values: {
        "values": [false,false,false,false,false,false,false,false,false,false,false,false]
    }

    property var led_pwm_enables: {
        "caption":"PWM Enable",
        "scales":[],
        "state":"enabled",
        "value":"",
        "values":[true,true,true,true,true,true,true,true,true,true,true,true]
    }


    property var led_pwm_enables_caption: {
        "caption": "PWM Enable"
    }

    property var led_pwm_enables_state: {
        "state":"enabled"
    }

    property var led_pwm_enables_values: {
        "values": [true,true,true,true,true,true,true,true,true,true,true,true]
    }



    property var led_pwm_duty: {
        "caption":"PWM Duty",
        "scales":[127,0,1],
        "state":"enabled",
        "value":"",
        "values":[3,3,3,3,3,3,3,3,3,3,3,3]
    }

    property var led_pwm_duty_caption: {
        "caption": "PWM Duty"
    }

    property var led_pwm_duty_scales: {
        "scales":[127,0,1]
    }

    property var led_pwm_duty_state: {
        "state":"enabled"
    }

    property var led_pwm_duty_values: {
        "values": [3,3,3,3,3,3,3,3,3,3,3,3]
    }


    property var led_iset: {
        "caption":"Global Current Set (ISET)",
        "scales":[60,0,1],
        "state":"enabled",
        "value":30,
        "values":[]
    }


    property var led_iset_caption: {
        "caption": "Global Current Set (ISET)"
    }

    property var led_iset_scales: {
        "scales":[60,0,1]
    }

    property var led_iset_state: {
        "state":"enabled"
    }

    property var led_iset_value: {
        "value": 30
    }

    property var led_sc_iset: {
        "caption":"SC_Iset",
        "scales":[],
        "state":"disabled",
        "value":false,
        "values":[]
    }

    property var led_sc_iset_caption: {
        "caption": "SC_Iset"
    }

    property var led_sc_iset_state: {
        "state":"disabled"
    }

    property var led_sc_iset_value: {
        "value":false
    }


    property var led_i2cerr: {
        "caption":"I2Cerr",
        "scales":[],
        "state":"disabled",
        "value":false,
        "values":[]
    }

    property var led_i2cerr_caption: {
        "caption": "I2Cerr"
    }

    property var led_i2cerr_state: {
        "state":"disabled"
    }

    property var led_i2cerr_value: {
        "value": false
    }

    property var led_uv: {
        "caption":"UV",
        "scales":[],
        "state":"disabled",
        "value":false,
        "values":[]
    }

    property var led_uv_caption: {
        "caption": "UV"
    }

    property var led_uv_state: {
        "state":"disabled"
    }

    property var led_uv_value: {
        "value": false
    }

    property var led_diagrange: {
        "caption":"diagRange",
        "scales":[],
        "state":"disabled",
        "value":false,
        "values":[]
    }

    property var led_diagrange_caption: {
        "caption": "diagRange"
    }

    property var led_diagrange_state: {
        "state":"disabled"
    }

    property var led_diagrange_value: {
        "value": false
    }

    property var led_tw: {
        "caption":"TW",
        "scales":[],
        "state":"disabled",
        "value":false,
        "values":[]
    }

    property var led_tw_caption: {
        "caption": "TW"
    }

    property var led_tw_state: {
        "state":"disabled"
    }

    property var led_tw_value: {
        "value": false
    }

    property var led_tsd: {
        "caption":"TSD",
        "scales":[],
        "state":"disabled",
        "value":false,
        "values":[]
    }

    property var led_tsd_caption: {
        "caption": "TSD"
    }

    property var led_tsd_state: {
        "state":"disabled"
    }

    property var led_tsd_value: {
        "value": false
    }

    property var led_diagerr: {
        "caption":"DIAGERR",
        "scales":[],
        "state":"disabled",
        "value":false,
        "values":[]
    }

    property var led_diagerr_caption: {
        "caption": "DIAGERR"
    }

    property var led_diagerr_state: {
        "state":"disabled"
    }

    property var led_diagerr_value: {
        "value": false
    }


    property var led_ol: {
        "caption":"OL",
        "scales":[],
        "state":"disabled",
        "value":false,
        "values":[]
    }

    property var led_ol_caption: {
        "caption": "OL"
    }

    property var led_ol_state: {
        "state":"disabled"
    }

    property var led_ol_value: {
        "value": false
    }

    property var led_oen: {
        "caption":"Output EN (OEN)",
        "scales":[],
        "state":"disabled_and_grayed_out",
        "value":true,
        "values":[]
    }

    property var led_oen_caption: {
        "caption": "Output EN (OEN)"
    }

    property var led_oen_state: {
        "state":"disabled_and_grayed_out"
    }

    property var led_oen_value: {
        "value": true
    }

    property var led_pwm_enable: {
        "caption":"PWM Enable",
        "scales":[],
        "state":"enabled",
        "value":true,
        "values":[]
    }

    property var led_pwm_enable_caption: {
        "caption": "PWM Enable"
    }

    property var led_pwm_enable_state: {
        "state":"enabled"
    }

    property var led_pwm_enable_value: {
        "value": true
    }

    property var led_pwm_duty_lock: {
        "caption":"Lock PWM Duty Together",
        "scales":[],
        "state":"disabled_and_grayed_out",
        "value":true,
        "values":[]
    }

    property var led_pwm_duty_lock_caption: {
        "caption":"Lock PWM Duty Together"
    }

    property var led_pwm_duty_lock_state: {
        "state":"disabled_and_grayed_out"
    }

    property var led_pwm_duty_lock_value: {
        "value": true
    }

    property var led_pwm_en_lock: {
        "caption":"Lock PWM EN Together",
        "scales":[],
        "state":"disabled_and_grayed_out",
        "value":true,
        "values":[]
    }

    property var led_pwm_en_lock_caption: {
        "caption":"Lock PWM EN Together"
    }

    property var led_pwm_en_lock_state: {
        "state":"disabled_and_grayed_out"
    }

    property var led_pwm_en_lock_value: {
        "value": true
    }

    property var led_linear_log: {
        "caption":"PWM Linear/Log",
        "scales":[],
        "state":"enabled",
        "value":"Linear",
        "values":["Linear","Log"]
    }

    property var led_linear_log_caption: {
        "caption":"PWM Linear/Log"
    }

    property var led_linear_log_state: {
        "state":"enabled"
    }

    property var led_linear_log_value: {
        "value": "Linear"
    }

    property var led_linear_log_values: {
        "values": ["Linear","Log"]
    }

    property var led_pwm_freq: {
        "caption":"PWM Frequency (Hz)",
        "scales":[],
        "state":"enabled",
        "value":"125 Hz",
        "values":["125 Hz","250 Hz","300 Hz"]
    }

    property var led_pwm_freq_caption: {
        "caption":"PWM Frequency (Hz)"
    }

    property var led_pwm_freq_state: {
        "state":"enabled"
    }

    property var led_pwm_freq_value: {
        "value": "125 Hz"
    }

    property var led_pwm_freq_values: {
        "values": ["125 Hz","250 Hz"," 300 Hz"]
    }

    property var led_open_load_diagnostic: {
        "caption":"I2C Open Load Diagnostic",
        "scales":[],
        "state":"enabled",
        "value":"No Diagnostic",
        "values":["No Diagnostic","Auto Retry","Diagnostic Only"]
    }

    property var led_open_load_diagnostic_caption: {
        "caption":"I2C Open Load \n Diagnostic"
    }

    property var led_open_load_diagnostic_state: {
        "state":"enabled"
    }

    property var led_open_load_diagnostic_value: {
        "value": "No Diagnostic"
    }

    property var led_open_load_diagnostic_values: {
        "values": ["No Diagnostic","Auto Retry","Diagnostic Only"]
    }


    //Car demo Notification

    property var car_demo_brightness: {
        "value": "0.18"
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

    // @command: led_i2c_enable_commands
    // @description: sends LED I2C enable command to platform


    property var set_led_out_en : ({
                                       "cmd" : "led_out_en",
                                       "payload": {
                                           "values":[0,0,0,0,0,0,0,0,0,0,0,0]
                                       },

                                       update: function (values) {
                                           this.set(values)
                                           this.send(this)
                                       },
                                       set: function (values) {
                                           this.payload.values = values
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var set_led_ext : ({
                                    "cmd" : "led_ext",
                                    "payload": {
                                        "values":[0,0,0,0,0,0,0,0,0,0,0,0]
                                    },

                                    update: function (values) {
                                        this.set(values)
                                        this.send(this)
                                    },
                                    set: function (values) {
                                        this.payload.values = values
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })

    property var set_led_oen : ({
                                    "cmd" : "led_oen",
                                    "payload": {
                                        "value":true
                                    },

                                    update: function (value) {
                                        this.set(value)
                                        this.send(this)
                                    },
                                    set: function (value) {
                                        this.payload.value = value
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })

    property var set_led_pwm_enable : ({
                                           "cmd" : "led_pwm_enable",
                                           "payload": {
                                               "value":true
                                           },

                                           update: function (value) {
                                               this.set(value)
                                               this.send(this)
                                           },
                                           set: function (value) {
                                               this.payload.value = value
                                           },
                                           send: function () { CorePlatformInterface.send(this) },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

    property var set_led_pwm_duty_lock : ({
                                              "cmd" : "led_pwm_duty_lock",
                                              "payload": {
                                                  "value":true
                                              },

                                              update: function (value) {
                                                  this.set(value)
                                                  this.send(this)
                                              },
                                              set: function (value) {
                                                  this.payload.value = value
                                              },
                                              send: function () { CorePlatformInterface.send(this) },
                                              show: function () { CorePlatformInterface.show(this) }
                                          })

    property var set_led_pwm_en_lock : ({
                                            "cmd" : "led_pwm_en_lock",
                                            "payload": {
                                                "value":true
                                            },

                                            update: function (value) {
                                                this.set(value)
                                                this.send(this)
                                            },
                                            set: function (value) {
                                                this.payload.value = value
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })


    property var set_led_pwm_conf : ({
                                         "cmd" : "led_pwm_conf",
                                         "payload": {
                                             "pwm_freq":"125 Hz",
                                             "pwm_lin":true,
                                             "pwm_duty":[3,3,3,3,3,3,3,3,3,3,3,3],
                                             "pwm_en":[1,1,1,1,1,1,1,1,1,1,1,1]
                                         },

                                         update: function (pwm_freq,pwm_lin,pwm_duty,pwm_en) {
                                             this.set(pwm_freq,pwm_lin,pwm_duty,pwm_en)
                                             this.send(this)
                                         },
                                         set: function (pwm_freq,pwm_lin,pwm_duty,pwm_en) {
                                             this.payload.pwm_freq = pwm_freq
                                             this.payload.pwm_lin = pwm_lin
                                             this.payload.pwm_duty = pwm_duty
                                             this.payload.pwm_en = pwm_en
                                         },
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }
                                     })

    property var set_led_diag_mode : ({
                                          "cmd" : "led_diag_mode",
                                          "payload": {
                                              "value":"No Diagnostic"
                                          },

                                          update: function (value) {
                                              this.set(value)
                                              this.send(this)
                                          },
                                          set: function (value) {
                                              this.payload.value = value
                                          },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }
                                      })



    // -------------------------------------------------------------------
    // Listens to message notifications coming from CoreInterface.cpp
    // Forward messages to core_platform_interface.js to process


    property real outputEnable0: 0
    property real outputEnable1: 0
    property real outputEnable2: 0
    property real outputEnable3: 0
    property real outputEnable4: 0
    property real outputEnable5: 0
    property real outputEnable6: 0
    property real outputEnable7: 0
    property real outputEnable8: 0
    property real outputEnable9: 0
    property real outputEnable10: 0
    property real outputEnable11: 0

    property real outputExt0: 0
    property real outputExt1: 0
    property real outputExt2: 0
    property real outputExt3: 0
    property real outputExt4: 0
    property real outputExt5: 0
    property real outputExt6: 0
    property real outputExt7: 0
    property real outputExt8: 0
    property real outputExt9: 0
    property real outputExt10: 0
    property real outputExt11: 0

    property real outputDuty0: 0
    property real outputDuty1: 0
    property real outputDuty2: 0
    property real outputDuty3: 0
    property real outputDuty4: 0
    property real outputDuty5: 0
    property real outputDuty6: 0
    property real outputDuty7: 0
    property real outputDuty8: 0
    property real outputDuty9: 0
    property real outputDuty10: 0
    property real outputDuty11: 0

    property bool pwm_lin_state: false


    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }
}
