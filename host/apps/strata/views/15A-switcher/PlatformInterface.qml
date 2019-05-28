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

    // @notification read_voltage_current
    // @description: read values
    //
    property var status_voltage_current : {
                "vin":	0,		//in Volts
                "vout": 0,   		//in Volts
                "vcc": 0,   		//in Volts
                "vb": 0,   		//in Volts
                "vout": 0,   		//in Volts
                "vboost": 0,   	//in Volts
                "iin":	0,    		//in A
                "iout": 0,     		//in A
                "efficiency": 0,	// in percentage
                "power_dissipated": 0, // in mW
                "output_power": 0, // in mW
                "vingood":	""
    }

    // @notification read_temperature_sensor
    // @description: Read temperature
    //
    property var status_temperature_sensor : {
        "temperature":	0
    }

    property var status_enable: {
        "enable": " "
    }

    property var initial_status: {
       "enable_status":"",
        "soft_start_status":"",
        "vout_selector_status":0,
        "ocp_threshold_status":0,
        "mode_index_status":0
    }

    // -------------------  end notification messages


    // -------------------
    // Commands
    // TO SEND A COMMAND DO THE FOLLOWING:
    // EXAMPLE: To send the motor speed: platformInterface.set_enable.update("on")

    // TO SYNCHRONIZE THE SPEED ON ALL THE VIEW DO THE FOLLOWING:
    // EXAMPLE: platformInterface.enabled

    property var read_initial_status: ({ "cmd" : "read_initial_status",

                                         update: function () {
                                             CorePlatformInterface.send(this)
                                         },
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }

                                     })

    property var read_enable_state: ({ "cmd" : "read_enable",

                                         update: function () {
                                             CorePlatformInterface.send(this)
                                         },
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }

                                     })

    property var set_enable: ({
                                  "cmd" : "set_enable",
                                  "payload": {
                                      "enable": " ",
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

    property var set_mode: ({
                                  "cmd" : "set_mode",
                                  "payload": {
                                      "mode_index": 0,
                                  },

                                  // Update will set and send in one shot
                                  update: function (mode_index) {
                                      this.set(mode_index)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (mode_index) {
                                      this.payload.mode_index = mode_index;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })

    property var set_soft_start: ({
                                  "cmd" : "set_soft_start",
                                  "payload": {
                                      "soft_start":"",
                                  },

                                  // Update will set and send in one shot
                                  update: function (soft_start) {
                                      this.set(soft_start)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (soft_start) {
                                      this.payload.soft_start = soft_start;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })

    property var select_output_voltage: ({
                                  "cmd" : "select_output_voltage",
                                  "payload": {
                                      "output_voltage": 0,
                                  },

                                  // Update will set and send in one shot
                                  update: function (output_voltage) {
                                      this.set(output_voltage)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (output_voltage) {
                                      this.payload.output_voltage = output_voltage;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })

    property var select_ocp_threshold: ({
                                  "cmd" : "select_ocp_threshold",
                                  "payload": {
                                      "ocp_threshold": 0,
                                  },

                                  // Update will set and send in one shot
                                  update: function (ocp_threshold) {
                                      this.set(ocp_threshold)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (ocp_threshold) {
                                      this.payload.ocp_threshold = ocp_threshold;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })

    // -------------------  end commands
    // NOTE:
    //  All internal property names for PlatformInterface must avoid name collisions with notification/cmd message properties.
    //  naming convention to avoid name collisions;
    //  property var _name


    // -------------------------------------------------------------------
    // Connect to CoreInterface notification signals
    // -------------------------------------------------------------------
    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }

    /*
      property to sync the views and set the initial state
    */
    property bool enabled: false
    property int soft_start: 0
    property int vout: 0
    property int ocp_threshold: 0
    property int mode: 0
    property bool advertise
    property bool hideOutputVol: false

  // DEBUG Window for testing motor vortex UI without a platform
    //    Window {
    //        id: debug
    //        visible: true
    //        width: 200
    //        height: 200

    //        Button {
    //            id: button2
    //         //   anchors { top: button1.bottom }
    //            text: "send vin"
    //            onClicked: {
    //                CorePlatformInterface.data_source_handler('{
    //                    "value":"read_voltage_current",
    //                    "payload":{
    //                                "vin":'+ (Math.random()*5+10).toFixed(2) +',
    //                                "vout": '+ (Math.random()*5+10).toFixed(2) +',
    //                                "iin": '+ (Math.random()*5+10).toFixed(2) +',
    //                                "iout": '+ (Math.random()*5+10).toFixed(2) +',
    //                                "vin_bad": "off"

    //                               }
    //                             }')
    //            }
    //        }
    //        Button {
    //            anchors { top: button2.bottom }
    //            text: "send"
    //            onClicked: {
    //                CorePlatformInterface.data_source_handler('{
    //                            "value":"read_temperature_sensor",
    //                            "payload":{
    //                                     "temperature": '+ (Math.random()*100).toFixed(0) +'
    //                            }
    //                    }
    //            ')
    //            }
    //        }
    //    }
}
