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
        "":[],
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
        "":[],
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

    property var led_pwm_enable: {
        "caption":"PWM Enable",
        "scales":[],
        "state":"enabled",
        "value":"",
        "values":[true,true,true,true,true,true,true,true,true,true,true,true]
    }


    property var led_pwm_enable_caption: {
        "caption": "PWM Enable"
    }

    property var led_pwm_enable_state: {
        "state":"enabled"
    }

    property var led_pwm_enable_values: {
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
    //
    property var led_i2c_enable_commands : ({
                                                "cmd" : "led_i2c_enable",
                                                "payload": {
                                                    "value":true // default value
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

    property var led_ch_enable_read : ({
                                           "cmd":"led_ch_enable_read",
                                           update: function () {
                                               CorePlatformInterface.send(this)
                                           },
                                           send: function () { CorePlatformInterface.send(this) },
                                           show: function () { CorePlatformInterface.show(this) }
                                       })

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
