import QtQuick 2.9
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
    //  Can also synchronize control state across multiple UI views;
    //  just bind all controls to this state as in #2 above.
    //
    //  ** All internal property names for PlatformInterface must avoid name
    //  ** collisions with notification/cmd message properties.
    //  **    Use Naming Convention: 'property var _name'

//    property bool auto_cal_start: platformInterface.stateAutoCalSwitch
//    onAuto_cal_startChanged: {
//        if (auto_cal_start === true){
//            platformInterface.auto_cal_command.update(1)

//        } else {
//            platformInterface.auto_cal_command.update(0)
//        }
//    }

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

    // @command: motor_running_command
    // @description: sends motor running command to platform
    //

//    property var auto_cal_command : ({
//                                     "cmd" : "auto_cal",
//                                     "payload": {
//                                         "state": 1 // default value
//                                     },

//                                     update: function (state) {
//                                         this.set(state)
//                                         this.send(state)
//                                     },
//                                     set: function (state) {
//                                         this.payload.state = state
//                                     },
//                                     send: function () { CorePlatformInterface.send(this) },
//                                     show: function () { CorePlatformInterface.show(this) }
//                                 })

//    property var start_peroidic_hdl : ({
//                                           "cmd" : "start_periodic",
//                                           "payload": {
//                                               "function":"power_notification",
//                                               "run_count":-1,
//                                               "interval": 1000
//                                           },

//                                           update: function () {
//                                               this.set()
//                                               this.send()
//                                           },

//                                           set: function () {
//                                           },

//                                           send: function () { CorePlatformInterface.send(this) },
//                                           show: function () { CorePlatformInterface.show(this) }
//                                       })

//    property var stop_peroidic_hdl : ({
//                                          "cmd" : "stop_periodic",
//                                          "payload": {
//                                              "function":"power_notification"
//                                          },

//                                          update: function () {
//                                              this.set()
//                                              this.send()
//                                          },

//                                          set: function () {
//                                          },

//                                          send: function () { CorePlatformInterface.send(this) },
//                                          show: function () { CorePlatformInterface.show(this) }
//                                      })

    // -------------------------------------------------------------------
    // Incoming Notification Messages
    //
    // Define and document incoming notification messages here.
    //
    // The property name *must* match the associated notification value.
    // Sets UI Control State when changed.


    // @notification: power_notification
    // @description: update all information (e.g.input voltage, curent, power, line freqency, output voltage, current, power, loss and efficiency
    property var auto_cal_response:  {
        "response" : "finish"
    }


    property var power_notification : {
        "vin": 0,
        "iin": 0,
        "lfin": 0,
        "rpin": 0,
        "apin": 0,
        "acpin": 0,
        "pfin": 0,
        "vout": 0,
        "iout": 0,
        "pout": 0,
        "loss": 0,
        "n": 0
    }

//    property bool stateAutoCalSwitch: false
//    property bool lockAutoCalSwithc: false

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
