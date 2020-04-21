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


    property var led_OL_value: {
        "value":false
    }

    property var led_DIAGERR_value: {
        "value":false
    }

    property var led_TSD_value: {
        "value":false
    }

    property var led_TW_value: {
        "value":false
    }

    property var led_diagRange_value: {
        "value":false
    }

    property var led_UV_value: {
        "value":false
    }

    property var led_I2Cerr_value: {
        "value":false
    }

    property var led_SC_Iset_value: {
        "value":false
    }

    property var led_ch_enable_read_values: {
        "values": [true,true,true,true,true,true,true,true,true,true,true,true]
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
