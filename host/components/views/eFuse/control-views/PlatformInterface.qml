import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface



    property var board_id: {
        "board_id": "NIS5020"
    }

    property var status: {
        "temperature1":	25,		//temperature of sensor 1 in degrees C (-55 to 125)
        "temperature2":	50,		//temperature of sensor 2 in degrees C (-55 to 125)
        "vin": 12.00,			//input voltage (float) two decimal point accuracy
        "vout": 13.00,			//output voltage (float) two decimal point accuracy
        "iin": 1.00	,			//input current (float) two decimal point accuracy
        "iout": 11.00			//output current (float) two decimal point accuracy
    }

    property var periodic_status: {
        "temperature1":	25,		//temperature of sensor 1 in degrees C (-55 to 125)
        "temperature2":	25,		//temperature of sensor 2 in degrees C (-55 to 125)
        "vin": 12.00,			//input voltage (float) two decimal point accuracy
        "vout": 12.00,			//output voltage (float) two decimal point accuracy
        "iin": 1.00	,			//input current (float) two decimal point accuracy
        "iout": 1.00,			//output current (float) two decimal point accuracy
        "vin_led": "good"
    }

    property var enable_status: {
         "en1":	"off",		//on or off for state of the enable switch
         "en2":	"on"
    }


    property var thermal_shutdown_eFuse1: {
        "status": ""
    }

    property var thermal_shutdown_eFuse2: {
        "status": ""
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

    // @command: motor_running_command
    // @description: sends motor running command to platform
    //
    property var set_enable_1: ({
                                    "cmd" : "set_enable_1",
                                    "payload": {
                                        "enable": " ",
                                    },

                                    // Update will set and send in one shot
                                    update: function (enable) {
                                        this.set(enable)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (enable) {
                                        this.payload.enable = enable;
                                    },

                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }

                                })

    property var set_enable_2: ({
                                    "cmd" : "set_enable_2",
                                    "payload": {
                                        "enable": " ",
                                    },

                                    // Update will set and send in one shot
                                    update: function (enable) {
                                        this.set(enable)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (enable) {
                                        this.payload.enable = enable;
                                    },

                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }

                                })

    property var set_SR_1: ({
                                "cmd" : "set_slew_rate_1",
                                "payload": {
                                    "slew_rate": "slow",
                                },

                                // Update will set and send in one shot
                                update: function (slew_rate) {
                                    this.set(slew_rate)
                                    CorePlatformInterface.send(this)
                                },
                                // Set can set single or multiple properties before sending to platform
                                set: function (slew_rate) {
                                    this.payload.slew_rate = slew_rate;
                                },

                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }

                            })

    property var set_SR_2: ({
                                "cmd" : "set_slew_rate_2",
                                "payload": {
                                    "slew_rate": "slow",
                                },

                                // Update will set and send in one shot
                                update: function (slew_rate) {
                                    this.set(slew_rate)
                                    CorePlatformInterface.send(this)
                                },
                                // Set can set single or multiple properties before sending to platform
                                set: function (slew_rate) {
                                    this.payload.slew_rate = slew_rate;
                                },

                                send: function () { CorePlatformInterface.send(this) },
                                show: function () { CorePlatformInterface.show(this) }

                            })

    property var set_rlim_1: ({
                                  "cmd" : "set_rlim_1",
                                  "payload": {
                                      "rlim": "55",
                                  },

                                  // Update will set and send in one shot
                                  update: function (rlim) {
                                      this.set(rlim)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (rlim) {
                                      this.payload.rlim = rlim;
                                  },

                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })

    property var set_rlim_2: ({
                                  "cmd" : "set_rlim_2",
                                  "payload": {
                                      "rlim": "55",
                                  },

                                  // Update will set and send in one shot
                                  update: function (rlim) {
                                      this.set(rlim)
                                      CorePlatformInterface.send(this)
                                  },
                                  // Set can set single or multiple properties before sending to platform
                                  set: function (rlim) {
                                      this.payload.rlim = rlim;
                                  },

                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })

    property var short_circuit_en: ({ "cmd" : "short_circuit_en",
                                        "payload": {
                                            "enable": " ",
                                        },

                                        // Update will set and send in one shot
                                        update: function (enable) {
                                            this.set(enable)
                                            CorePlatformInterface.send(this)
                                        },
                                        // Set can set single or multiple properties before sending to platform
                                        set: function (enable) {
                                            this.payload.enable = enable;
                                        },

                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }

                         })

    property var reset: ({ "cmd" : "reset",
                             update: function () {
                                 CorePlatformInterface.send(this)
                             },
                             send: function () { CorePlatformInterface.send(this) },
                             show: function () { CorePlatformInterface.show(this) }

                         })

    property var get_board_id: ({ "cmd" : "get_board_id",
                                    update: function () {
                                        CorePlatformInterface.send(this)
                                    },
                                    send: function () { CorePlatformInterface.send(this) },
                                    show: function () { CorePlatformInterface.show(this) }

                                })

    property var get_status: ({ "cmd" : "get_status",
                                  update: function () {
                                      CorePlatformInterface.send(this)
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })

    property var get_enable_status: ({ "cmd" : "get_enable_status",
                                  update: function () {
                                      CorePlatformInterface.send(this)
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }

                              })

    property bool enable_1: false
    property bool enable_2: false
    property bool short_circuit_state: false
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
