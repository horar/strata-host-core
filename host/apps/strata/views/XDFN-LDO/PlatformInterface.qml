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
        "vout": 0,      //in Volts
        "iin":	0,    	//in mA
        "iout": 0,     	//in mA
        "efficiency": 0,
        "power_dissipated": 0,
        "output_power" : 0,

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

    property var status_vin_good: {
        "vingood": ""
    }

    property var initial_status:{
        "enable_status":"",
        "vin_mon_status":"",
        "power_mode_status":""
    }

    // -------------------  end notification messages


    // -------------------
    // Commands
    // TO SEND A COMMAND DO THE FOLLOWING:
    // EXAMPLE: To send the motor speed: platformInterface.set_enable.update("on")

    // TO SYNCHRONIZE THE SPEED ON ALL THE VIEW DO THE FOLLOWING:
    // EXAMPLE: platformInterface.enabled

    property var set_power_mode: ({
                                      "cmd":"set_power_mode",
                                      "payload":{
                                          "low_power_mode": ""	// on or off (string) (slide switch)
                                      },

                                      // Update will set and send in one shot
                                      update: function (low_power_mode) {
                                          this.set(low_power_mode)
                                          CorePlatformInterface.send(this)
                                      },
                                      // Set can set single or multiple properties before sending to platform
                                      set: function (low_power_mode) {
                                          this.payload.low_power_mode = low_power_mode;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var read_enable: ({ "cmd" : "read_enable",

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


    property var  check_vin_good: ({

                                       "cmd":"check_vin_good",
                                       update: function () {
                                           CorePlatformInterface.send(this)
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    property var  read_initial_status: ({

                                            "cmd":"read_initial_status",
                                            update: function () {
                                                CorePlatformInterface.send(this)
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }

                                        })

    //Tejashree: This is a HACK implementation//////////////////////////////
    property var pause_periodic: ({
                                      "cmd" : "pause_periodic",
                                      "payload": {
                                          "pause_flag": "",
                                      },

                                      // Set can set single or multiple properties before sending to platform
                                      set: function (pause_flag) {
                                          this.payload.pause_flag = pause_flag;
                                      },

                                      // Update will set and send in one shot
                                      update: function (pause_flag) {
                                          this.set(pause_flag)
                                          CorePlatformInterface.send(this)
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
    property bool power_mode: false
    property bool advertise;

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
