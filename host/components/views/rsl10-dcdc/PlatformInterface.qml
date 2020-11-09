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
        "vin": 0,		// in mVolts
        "vout": 0,      // in mVolts
        "iin":	0,    	// in mAmps
        "iout": 0,     	// in mAmps
    }

    property var status_IO: {
        "dio12": "",
        "dio13": "",
        "dio14": "",
        "dio04": ""
    }

    // @notification read_temperature_sensor
    // @description: Read temperature
    //
    property var status_temperature_sensor : {
        "temperature":	0
    }

    property var status_enable: {
        "enable": "",
        "dio12_enable": "",
        "dio13_enable": "",
        "dio14_enable": "",
        "dio04_enable": ""
    }

    property var status_vin_good: {
        "vingood": ""
    }

    property var initial_status:{
        "enable_status":"",
        "vin_mon_status":"",
        "power_mode_status":"",
        "dio12_status":"",
        "dio13_status":"",
        "dio14_status":"",
        "dio04_status":""
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

    property var read_dio12: ({ "cmd" : "read_dio12",

                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }

                               })

    property var read_dio13: ({ "cmd" : "read_dio13",

                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }

                               })

    property var read_dio14: ({ "cmd" : "read_dio14",

                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }

                               })

    property var read_dio04: ({ "cmd" : "read_dio04",

                                   update: function () {
                                       CorePlatformInterface.send(this)
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


    property var set_dio12: ({
                                  "cmd" : "set_dio12",
                                  "payload": {
                                      "dio12_enable": " ",
                                  },

                                  // Update will set and send in one shot
                                  update: function (dio12_enabled) {
                                      this.set(dio12_enabled)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (dio12_enabled) {
                                      this.payload.dio12_enable = dio12_enabled;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })

    property var set_dio13: ({
                                  "cmd" : "set_dio13",
                                  "payload": {
                                      "dio13_enable": " ",
                                  },

                                  // Update will set and send in one shot
                                  update: function (dio13_enabled) {
                                      this.set(dio13_enabled)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (dio13_enabled) {
                                      this.payload.dio13_enable = dio13_enabled;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })

    property var set_dio14: ({
                                  "cmd" : "set_dio14",
                                  "payload": {
                                      "dio14_enable": " ",
                                  },

                                  // Update will set and send in one shot
                                  update: function (dio14_enabled) {
                                      this.set(dio14_enabled)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (dio14_enabled) {
                                      this.payload.dio14_enable = dio14_enabled;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })


    property var set_dio04: ({
                                  "cmd" : "set_dio04",
                                  "payload": {
                                      "dio04_enable": " ",
                                  },

                                  // Update will set and send in one shot
                                  update: function (dio04_enabled) {
                                      this.set(dio04_enabled)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (dio04_enabled) {
                                      this.payload.dio04_enable = dio04_enabled;
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

    property var msg_dbg:{      //debug strings
            "cmd":""
    }

    property var set_mode: {
        "system_mode" : ""
    }

    property var dimmensional_mode: {
        "dimmensional_mode" : ""
    }


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

    property var setFrequency: ({
                                    "cmd" : "set_frequency",
                                    "payload": {
                                        "frequency_target": 0 // default value
                                    },

                                    // Update will set and send in one shot
                                    update: function (frequency) {
                                        this.set(frequency)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (frequency) {
                                        this.payload.frequency_target = frequency;
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })

    property var setPWM: ({
                                    "cmd" : "set_duty",
                                    "payload": {
                                        "duty_target": 100 // default value
                                    },

                                    // Update will set and send in one shot
                                    update: function (duty) {
                                        this.set(duty)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (duty) {
                                        this.payload.pwm_target = duty;
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }
                                })

    /*
       system_mode_selection Command
     */
    property var system_mode_selection: ({
                                             "cmd" : "set_system_mode",
                                             "payload": {
                                                 "system_mode":" " // "automatic" or "normal"
                                             },

                                             // Update will set and send in one shot
                                             update: function (system_mode) {
                                                 this.set(system_mode)
                                                 CorePlatformInterface.send(this)
                                             },
                                             // Set can set single or multiple properties before sending to platform
                                             set: function (system_mode) {
                                                 this.payload.system_mode = system_mode;
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }
                                         })

    /*
       dimmensional_mode_selection Command
     */
    property var dimmensional_mode_selection: ({
                                             "cmd" : "set_dimmensional_mode",
                                             "payload": {
                                                 "dimmensional_mode":" " // "automatic" or "normal"
                                             },

                                             // Update will set and send in one shot
                                             update: function (dimmensional_mode) {
                                                 this.set(dimmensional_mode)
                                                 CorePlatformInterface.send(this)
                                             },
                                             // Set can set single or multiple properties before sending to platform
                                             set: function (dimmensional_mode) {
                                                 this.payload.dimmensional_mode = dimmensional_mode;
                                             },
                                             send: function () { CorePlatformInterface.send(this) },
                                             show: function () { CorePlatformInterface.show(this) }
                                         })

    // This is a HACK implementation//////////////////////////////
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

    // -------------------------------------------------------------------
    // Connect to CoreInterface notification signals
    // -------------------------------------------------------------------
    // Listens to message notifications coming from CoreInterface.cpp
    // Forward messages to core_platform_interface.js to process
    // -------------------------------------------------------------------

    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
            pause_periodic = false
        }
    }

    //-----------------------------------------
    // add all syncrhonized controls here
    //-----------------------------------------

    property bool systemMode: true
    onSystemModeChanged: {
        if(systemMode){
            console.log("Normal Operation")
            system_mode_selection.update("normal")
        }
        else{
            console.log("Load Transient")
            system_mode_selection.update("automatic")
        }
    }

    property bool dimmensionalMode: true
    onDimmensionalModeChanged: {
        if(dimmensionalMode){
            console.log("2D")
            dimmensional_mode_selection.update("2D")
        }
        else{
            console.log("3D")
            dimmensional_mode_selection.update("3D")
        }
    }

    property int frequency: 0
    onFrequencyChanged: {
        setFrequency.update(frequency)
    }

    property int duty: 0
    onDutyChanged: {
        setPWM.update(duty)
    }
    // -------------------------------------------------------------------

    /*
      property to sync the views and set the initial state
    */
    property bool enabled: false
    property bool dio12_enabled: false
    property bool dio13_enabled: false
    property bool dio14_enabled: false
    property bool dio04_enabled: false
    property bool power_mode: false
    property bool advertise
}
