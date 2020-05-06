import QtQuick 2.12
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

    property var car_demo: {
        "brake":false,
        "left":false,
        "reverse":true,
        "right":true
    }

    //----------- ---

    // -------------------------------------------------------------------
    // Outgoing Commands For Car Demo
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
    property var set_car_demo : ({
                                     "cmd" : "car_demo",
                                     "payload": {
                                         "left":true,
                                         "right":false,
                                         "brake":true,
                                         "hazard":true,
                                         "reverse":false
                                     },

                                     update: function (left,right,brake,hazard,reverse) {
                                         this.set(left,right,brake,hazard,reverse)
                                         this.send(this)
                                     },
                                     set: function (left,right,brake,hazard,reverse) {
                                         this.payload.left = left
                                         this.payload.right = right
                                         this.payload.brake = brake
                                         this.payload.hazard = hazard
                                         this.payload.reverse = reverse
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }
                                 })


    //Mode commands
    property var mode : ({
                             "cmd" : "mode",
                             "payload": {
                                 "value":"Car Demo"
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



    // Power notification and commands
    /*****************/

    property var power_vled_type: {
        "caption":"VLED Input Voltage Type",
        "scales":[],
        "state":"enabled",
        "value":"Boost",
        "values":["Boost","Buck","Bypass"]
    }

    property var power_vled_type_caption: {
        "caption":"VLED Input Voltage\nType"
    }

    property var power_vled_type_state: {
        "state":"enabled"
    }

    property var power_vled_type_value: {
        "value": "Boost"
    }

    property var power_vled_type_values: {
        "values":["Boost","Buck","Bypass"]
    }

    property var power_boost_ocp: {
        "caption":"Boost OCP",
        "scales":[],
        "state":"disabled",
        "value":false,
        "values":[]
    }

    property var power_boost_ocp_caption: {
        "caption":"Boost\nOCP"
    }

    property var power_boost_ocp_state: {
        "state":"disabled"
    }

    property var power_boost_ocp_value: {
        "value": false
    }

    property var power_voltage_set: {
        "caption":"Boost Voltage Set",
        "scales":[12.0,5.5,0.1],
        "state":"enabled",
        "value":8.0,
        "values":[]
    }

    property var power_voltage_set_caption: {
        "caption":"Boost Voltage Set"
    }

    property var power_voltage_set_scales: {
        "scales":[12.0,5.5,0.1]
    }

    property var power_voltage_set_state: {
        "state":"enabled"
    }

    property var power_voltage_set_value: {
        "value":  8.0
    }


    property var power_vs_select: {
        "caption":"VS Voltage Select",
        "scales":[],
        "state":"enabled",
        "value":"5V_USB",
        "values":["5V_USB","VLED"]
    }

    property var power_vs_select_caption: {
        "caption":"VS Voltage Select"
    }

    property var power_vs_select_state: {
        "state":"enabled"
    }

    property var power_vs_select_value: {
        "value": "5V_USB"
    }

    property var power_vs_select_values: {
        "values": ["5V_USB","VLED"]
    }

    property var power_vled: {
        "caption":"LED Voltage (VLED)",
        "scales":[],
        "state":"disabled",
        "value":0,
        "values":[]
    }

    property var power_vled_caption: {
        "caption":"LED Voltage\n(VLED)"
    }

    property var power_vled_state: {
        "state":"disabled"
    }

    property var power_vled_value: {
        "value": 0
    }

    property var power_vs: {
        "caption":"Supply Voltage (VS)",
        "scales":[],
        "state":"disabled",
        "value":0,
        "values":[]
    }

    property var power_vs_caption: {
        "caption":"Supply Voltage\n(VS)"
    }

    property var power_vs_state: {
        "state":"disabled"
    }

    property var power_vs_value: {
        "value": 0
    }

    property var power_vdd: {
        "caption":"Digital Voltage (VDD)",
        "scales":[],
        "state":"disabled",
        "value":0,
        "values":[]
    }

    property var power_vdd_caption: {
        "caption": "Digital Voltage\n(VDD)"
    }

    property var power_vdd_state: {
        "state":"disabled"
    }

    property var power_vdd_value: {
        "value": 0
    }

    property var power_vbat: {
        "caption":"Battery Voltage\n(VBAT)",
        "scales":[],
        "state":"disabled",
        "value":0,
        "values":[]
    }

    property var power_vbat_caption: {
        "caption": "Battery Voltage\n(VBAT)"
    }

    property var power_vbat_state: {
        "state":"disabled"
    }

    property var power_vbat_value: {
        "value": 0
    }

    property var power_iled: {
        "caption":"LED Current\n(ILED)",
        "scales":[],
        "state":"disabled",
        "value":0,
        "values":[]
    }

    property var power_iled_caption: {
        "caption": "LED Current\n(ILED)"
    }

    property var power_iled_state: {
        "state":"disabled"
    }

    property var power_iled_value: {
        "value": 0
    }

    property var power_is: {
        "caption":"Supply Current (IS)",
        "scales":[],
        "state":"disabled",
        "value":0,
        "values":[]
    }

    property var power_is_caption: {
        "caption": "Supply Current\n(IS)"
    }

    property var power_is_state: {
        "state":"disabled"
    }

    property var power_is_value: {
        "value": 0
    }

    property var power_idd: {
        "caption":"Digital Current\n(IDD)",
        "scales":[],
        "state":"disabled",
        "value":0,
        "values":[]
    }

    property var power_idd_caption: {
        "caption": "Digital Current\n(IDD)"
    }

    property var power_idd_state: {
        "state":"disabled"
    }

    property var power_idd_value: {
        "value": 0
    }

    property var power_vcc: {
        "caption":"Reference Voltage (VCC)",
        "scales":[],
        "state":"disabled",
        "value":0,
        "values":[]
    }

    property var power_vcc_caption: {
        "caption": "Reference Voltage\n(VCC)"
    }

    property var power_vcc_state: {
        "state":"disabled"
    }

    property var power_vcc_value: {
        "value": 0
    }

    property var power_led_driver_temp_top: {
        "caption":"LED Driver Temp Top (°C)",
        "scales":[150,0,1],
        "state":"disabled",
        "value":0,
        "values":[]
    }


    property var power_led_driver_temp_top_caption: {
        "caption": "LED Driver Temp Top \n (°C)"
    }

    property var power_led_driver_temp_top_state: {
        "state":"disabled"
    }

    property var power_led_driver_temp_top_scales: {
        "scales":[150,0,10]
    }

    property var power_led_driver_temp_top_value: {
        "value": 0
    }


    property var power_led_driver_temp_bottom: {
        "caption":"LED Driver Temp Bottom (°C)",
        "scales":[150,0,10],
        "state":"disabled",
        "value":0,
        "values":[]
    }


    property var power_led_driver_temp_bottom_caption: {
        "caption": "LED Driver Temp Bottom \n (°C)"
    }

    property var power_led_driver_temp_bottom_state: {
        "state":"disabled"
    }

    property var power_led_driver_temp_bottom_scales: {
        "scales":[150,0,10]
    }

    property var power_led_driver_temp_bottom_value: {
        "value": 0
    }

    property var power_led_temp: {
        "caption":"LED Temperature (°C)",
        "scales":[150,0,10],
        "state":"disabled",
        "value":0,
        "values":[]
    }

    property var power_led_temp_caption: {
        "caption": "LED Temperature \n (°C)"
    }

    property var power_led_temp_state: {
        "state":"disabled"
    }

    property var power_led_temp_scales: {
        "scales":[150,0,10]
    }

    property var power_led_temp_value: {
        "value": 0
    }

    property var power_total_power_loss: {
        "caption":"Total Power Loss (W)",
        "scales":[5.00,0.00,0.5],
        "state":"disabled",
        "value":0,
        "values":[]
    }


    property var power_total_power_loss_caption: {
        "caption": "Total Power Loss \n (W)"
    }

    property var power_total_power_loss_state: {
        "state":"disabled"
    }

    property var power_total_power_loss_scales: {
        "scales":[5.00,0.00,0.5]
    }

    property var power_total_power_loss_value: {
        "value": 0
    }


    // -------------------------------------------------------------------
    // Listens to message notifications coming from CoreInterface.cpp
    // Forward messages to core_platform_interface.js to process


    property bool outputEnable0: true
    property bool outputEnable1: true
    property bool outputEnable2: true
    property bool outputEnable3: true
    property bool outputEnable4: true
    property bool outputEnable5: true
    property bool outputEnable6: true
    property bool outputEnable7: true
    property bool outputEnable8: true
    property bool outputEnable9: true
    property bool outputEnable10: true
    property bool outputEnable11: true

    property bool outputExt0: false
    property bool outputExt1: false
    property bool outputExt2: false
    property bool outputExt3: false
    property bool outputExt4: false
    property bool outputExt5: false
    property bool outputExt6: false
    property bool outputExt7: false
    property bool outputExt8: false
    property bool outputExt9: false
    property bool outputExt10: false
    property bool outputExt11: false

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

    property bool outputPwm0: true
    property bool outputPwm1: true
    property bool outputPwm2: true
    property bool outputPwm3: true
    property bool outputPwm4: true
    property bool outputPwm5: true
    property bool outputPwm6: true
    property bool outputPwm7: true
    property bool outputPwm8: true
    property bool outputPwm9: true
    property bool outputPwm10: true
    property bool outputPwm11: true

    property bool left_value: false
    property bool right_value: false
    property bool brake_value: false
    property bool hazard_value: false
    property bool reverse_value: false

    // property real startUI: 0


    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }

    //    Window {
    //        id: debug
    //        visible: true
    //        width: 400
    //        height: 400



    //        Rectangle {
    //            anchors.left: button2.right
    //            anchors.leftMargin: 10
    //            width: parent.width
    //            height: 50
    //            Slider {
    //                id: slider

    //                orientation: Qt.Horizontal
    //                from: -1
    //                to: 1
    //            }
    //        }

    //        Button {
    //            id: button2
    //            anchors { top: parent.top }
    //            text: "send car brightness"
    //            onClicked: {

    //                CorePlatformInterface.data_source_handler('{
    //                    "value":"car_demo_brightness",
    //                    "payload":{
    //                                  "value": ' + slider.value + '
    //                               }
    //                             }')


    //            }
    //        }
    //        Button {
    //            id: button3
    //            anchors { top: button2.bottom }
    //            text: "send car_demo random"
    //            onClicked: {
    //                CorePlatformInterface.data_source_handler('{
    //                            "value":"car_demo",
    //                            "payload":{
    //                                        "brake": ' + Boolean(Math.round(Math.random())) + ',
    //                                        "left": ' + Boolean(Math.round(Math.random())) + ',
    //                                        "reverse": ' + Boolean(Math.round(Math.random())) + ',
    //                                        "right": ' + Boolean(Math.round(Math.random())) + '
    //                            }

    //            }')



    //            }
    //        }

    //        Button {
    //            id: button4
    //            anchors { top: button3.bottom }
    //            text: "send car_demo reset"
    //            onClicked: {
    //                CorePlatformInterface.data_source_handler('{
    //                            "value":"car_demo",
    //                            "payload":{
    //                                        "brake":  false,
    //                                        "left": false,
    //                                        "reverse": false,
    //                                        "right": false
    //                            }
    //                    }
    //            ')

    //            }
    //        }

    //        Button {
    //            id: button5
    //            anchors { top: button4.bottom }
    //            text: "send led_oen_value & led_oen_state"
    //            onClicked: {
    //                CorePlatformInterface.data_source_handler('{
    //                            "value":"led_oen_value",
    //                            "payload":{
    //                                  "value": ' + Boolean(Math.round(Math.random())) + '
    //                            }
    //                    }
    //            ')
    //                CorePlatformInterface.data_source_handler('{
    //                            "value":"led_oen_state",
    //                            "payload":{
    //                                  "state": "enabled"
    //                            }
    //                    }
    //            ')



    //            }
    //        }

    //        /*
    //    property var led_fault_status_values: {
    //        "values": [false,false,false,false,false,false,false,false,false,false,false,false]

    //    property var led_linear_log_values: {
    //        "values": ["Linear","Log"]
    //    }
    //    }

    //     */
    //        Button {
    //            id: button6


    //            anchors { top: button5.bottom }
    //            text: "send_led_linear_log_value"
    //            onClicked: {
    //                CorePlatformInterface.data_source_handler ('{
    //                                "value": "led_linear_log_value" ,
    //                                "payload":{
    //                                  "value": "Log"
    //                                }
    //                            }')

    //                led_out_en_values.values = enableArray
    //                console.log(platformInterface.led_out_en_values.values)

    //            }
    //        }

    //        Button {
    //            id: button7

    //            anchors { top: button6.bottom }
    //            text: "send led_ext_caption"
    //            onClicked: {
    //                CorePlatformInterface.data_source_handler ('{
    //                                "value": "led_ext_caption" ,
    //                                "payload":{
    //                                  "caption":"abc"
    //                                }
    //                            }')


    //            }
    //        }

    //        Button {
    //            id: button8
    //            anchors { top: button7.bottom }
    //            text: "send led_i2cerr_value"
    //            onClicked: {
    //                CorePlatformInterface.data_source_handler ('{
    //                                "value": "led_i2cerr_value" ,
    //                                "payload":{
    //                                  "value": true
    //                                }
    //                            }')


    //            }
    //        }

    //        Button {
    //            id: button9
    //            anchors { top: button8.bottom }
    //            text: "send led_open_load_diagnostic_state"

    //            onClicked: {
    //                CorePlatformInterface.data_source_handler ('{
    //                                "value": "led_open_load_diagnostic_state" ,
    //                                "payload":{
    //                                  "state":"disabled_and_grayed_out"
    //                                }
    //                            }')
    //            }
    //        }
    //    }
}

