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
        "vin":	3.0,			//in Volts 2 decimal places
        "vout": 2.5,   			//in Volts 2 decimal places
        "vcc": 2.5,   			//in Volts 2 decimal places
        "pvcc": 2.5,   			//in Volts 2 decimal places
        "vout": 2.5,   			//in Volts 2 decimal places
        "vboost": 2.5,   		//in Volts 2 decimal places
        "iin":	1,    			//in A 2 decimal places
        "iout": 1,     			//in A 2 decimal places
        "efficiency": 85,		// in percentage 0 decimal places
        "power_dissipated": 20,         // in mW 2 decimal places
        "output_power": 20, 	        // in mW 2 decimal places
        "vingood": "good"		// good => green, bad => red

    }

    property var status_temperature_sensor : {
        "temperature":	25	//in Celsius
    }


    property var status_pgood:  {
        "pgood":"bad"
    }

    property var status_os_alert:  {
        "os_alert":false
    }

    property var vout_below_threshold:  {
        "vout_below_status":"false"
    }
    property var initial_status: {
        "enable_status":"off",            // "on" slide switch
        "soft_start_status":"1.2ms",      // "2.4ms" dropdown
        "pgood_status":"bad",             // "good" LED good=>green, bad=>red
        "operating_mode_status":"dcm",    // "fccm" drop down
        "vcc_select_status":"external",   // "pvcc" drop down
        "vout_setting_status":5.00,       // slider from 1V to 30V in steps of 0.5V
        "switching_frequency_status":300, // in KHz slider from 100KHz to 1000KHz
        "sync_mode_status":"master",      // "slave" dropdown
        "ocp_status":5,                   // in A from 3.5A to 23A
        "ocp_min":3.5,                    // in A from 3.5A to 5A
        "ocp_max":23,                    // in A from 15A to 23A
        "variant":"FAN65004B"             // used to change the title and OCP limits
    }

    // -------------------  end notification messages


    // -------------------
    // Commands
    // TO SEND A COMMAND DO THE FOLLOWING:
    // EXAMPLE: To send the motor speed: platformInterface.set_enable.update("on")

    // TO SYNCHRONIZE THE SPEED ON ALL THE VIEW DO THE FOLLOWING:
    // EXAMPLE: platformInterface.enabled

    property var read_initial_status: ({
                                           "cmd":"read_initial_status",
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


    property var set_output_voltage: ({
                                          "cmd" : "set_vout",
                                          "payload": {
                                              "vout":5.8
                                          },

                                          // Update will set and send in one shot
                                          update: function (vout) {
                                              this.set(vout)
                                              CorePlatformInterface.send(this)
                                          },
                                          // Set can set single or multiple properties before sending to platform
                                          set: function (vout) {
                                              this.payload.vout = vout;
                                          },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }

                                      })

    property var enable_hiccup_mode: ({
                                          "cmd" : "set_hiccup_enable",
                                          "payload": {
                                              "hiccup_enable":"on"
                                          },

                                          // Update will set and send in one shot
                                          update: function (hiccup_enable) {
                                              this.set(hiccup_enable)
                                              CorePlatformInterface.send(this)
                                          },
                                          // Set can set single or multiple properties before sending to platform
                                          set: function (hiccup_enable) {
                                              this.payload.hiccup_enable = hiccup_enable;
                                          },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }

                                      })

    property var select_mode: ({
                                   "cmd" : "set_cm_sel",
                                   "payload": {
                                       "cm_sel": "fccm"
                                   },

                                   // Update will set and send in one shot
                                   update: function (cm_sel) {
                                       this.set(cm_sel)
                                       CorePlatformInterface.send(this)
                                   },
                                   // Set can set single or multiple properties before sending to platform
                                   set: function (cm_sel) {
                                       this.payload.cm_sel = cm_sel;
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }

                               })


    property var set_soft_start: ({
                                      "cmd" : "set_soft_start",
                                      "payload": {
                                          "soft_start": "6ms"
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

    property var select_VCC_mode: ({
                                       "cmd" : "select_vcc",
                                       "payload": {
                                           "vcc_sel": "pvcc"
                                       },

                                       // Update will set and send in one shot
                                       update: function (vcc_sel) {
                                           this.set(vcc_sel)
                                           CorePlatformInterface.send(this)
                                       },
                                       // Set can set single or multiple properties before sending to platform
                                       set: function (vcc_sel) {
                                           this.payload.vcc_sel = vcc_sel;
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }

                                   })

    property var set_switching_frequency: ({
                                               "cmd" : "set_swn_frequency",
                                               "payload": {
                                                   "swn_frequency": 150
                                               },

                                               // Update will set and send in one shot
                                               update: function (swn_frequency) {
                                                   this.set(swn_frequency)
                                                   CorePlatformInterface.send(this)
                                               },
                                               // Set can set single or multiple properties before sending to platform
                                               set: function (swn_frequency) {
                                                   this.payload.swn_frequency = swn_frequency;
                                               },
                                               send: function () { CorePlatformInterface.send(this) },
                                               show: function () { CorePlatformInterface.show(this) }

                                           })

    property var set_sync_mode: ({
                                     "cmd" : "set_sync_mode",
                                     "payload": {
                                         "sync_mode": "master"
                                     },

                                     // Update will set and send in one shot
                                     update: function (sync_mode) {
                                         this.set(sync_mode)
                                         CorePlatformInterface.send(this)
                                     },
                                     // Set can set single or multiple properties before sending to platform
                                     set: function (sync_mode) {
                                         this.payload.sync_mode = sync_mode;
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })


    property var set_sync_slave_frequency: ({
                                                "cmd" : "set_sync_slave_frequency",
                                                "payload": {
                                                    "sync_frequency":500
                                                },

                                                // Update will set and send in one shot
                                                update: function (sync_frequency) {
                                                    this.set(sync_frequency)
                                                    CorePlatformInterface.send(this)
                                                },
                                                // Set can set single or multiple properties before sending to platform
                                                set: function (sync_frequency) {
                                                    this.payload.sync_frequency = sync_frequency;
                                                },
                                                send: function () { CorePlatformInterface.send(this) },
                                                show: function () { CorePlatformInterface.show(this) }

                                            })
    property var set_ocp: ({
                               "cmd" : "set_ocp",
                               "payload": {
                                   "ocp_setting": 35
                               },

                               // Update will set and send in one shot
                               update: function (ocp_setting) {
                                   this.set(ocp_setting)
                                   CorePlatformInterface.send(this)
                               },
                               // Set can set single or multiple properties before sending to platform
                               set: function (ocp_setting) {
                                   this.payload.ocp_setting = ocp_setting;
                               },
                               send: function () { CorePlatformInterface.send(this) },
                               show: function () { CorePlatformInterface.show(this) }

                           })

    property var vout_warning_response: ({
                                             "cmd" : "vout_warning_response",
                                             "payload": {
                                                 "response": "true"
                                             },

                                             // Update will set and send in one shot
                                             update: function (response) {
                                                 this.set(response)
                                                 CorePlatformInterface.send(this)
                                             },
                                             // Set can set single or multiple properties before sending to platform
                                             set: function (response) {
                                                 this.payload.response = response;
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }

                                         })

    property var set_dlt_connected: ({
                                         "cmd" : "dlt_connected",
                                         "payload": {
                                             "value": false
                                         },

                                         // Update will set and send in one shot
                                         update: function (value) {
                                             this.set(value)
                                             CorePlatformInterface.send(this)
                                         },
                                         // Set can set single or multiple properties before sending to platform
                                         set: function (value) {
                                             this.payload.value = value;
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
    property int switchFrequency: 0


    property int soft_start: 0
    property int vout: 0
    property int ocp_threshold: 0
    property int mode: 0
    property bool advertise
    property bool hideOutputVol

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
