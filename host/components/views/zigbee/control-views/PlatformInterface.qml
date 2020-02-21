import QtQuick 2.12
import QtQuick.Window 2.3

import tech.strata.sgwidgets 1.0
import QtQuick.Controls 2.2
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface



    // -------------------------------------------------------------------
    // Incoming Notification Messages
    //
    // Define and document incoming notification messages here.
    //
    // The property name *must* match the associated notification value.
    // Sets UI Control State when changed.


    //
    property var status_onoff : {
        "ele_addr": "8000",     // in dec (16 bit)
        "state":  "on"         // or "off"
    }

    property var status_light_hsl : {
        "ele_addr": "8000",  // in dec (16 bit)
        "h": "120",         // 0 to 360 degrees (string)
        "s": "50",          // 0 to 100% (string)
        "l": "50"           // 0 to 100% (string)
    }

    //a generic status level
    property var status_level : {
        "ele_addr": "8000",  // in dec (16 bit)
        "level": "8000" // in dec (16 bit), (string)
    }

    //a generic sensor model
    //what is this returning? Is there an encoding of models to 16 bit strings?
    property var status_sensor : {
        "uaddr": "",  // in dec (16 bit)
        "sensor_type": "",  // temperature ambient_light, magnetic_rotation, magnetic_detection, strata, default (string)
        "data":""
    }

    property var status_battery : {
        "uaddr": "8000",  // in dec (16 bit)
        "battery_level": "50",      // 0 to 100% (string)
        "battery_voltage": "4.0",   // voltage (string)
        "plugged_in":"true",      //or false
        "battery_state": "charging", //or "not charging" or "charged"
    }

    property var signal_strength : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "100",  // in dB? %?
    }

    property var ambient_light : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "100",  // in lumens?
    }

    property var dimmer_mode : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "true",
    }
    property var relay_mode : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "true",
    }
    property var alarm_mode : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "true",
    }
    property var high_power_mode : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "true",
    }
    property var hsl_color : {
        "node_id": "8000",  // in dec (16 bit)
        "h": "120",         // 0 to 360 degrees (string)
        "s": "50",          // 0 to 100% (string)
        "l": "50"           // 0 to 100% (string)
    }

    property var temperature : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "100",  // in in °C?
    }

    property var network_notification : {
        "nodes": [{
                      "index": "1",
                      "ready": 0,       //or false
                      "color": "#ffffff"    //RGB hex value of the node color
                  }]
    }

    property var node_added : {
        "index": "1",  // in dec (16 bit)
        "color": "green",  //RGB hex value of the node color
    }

    property var node_removed : {
        "node_id": "8000",  // in dec (16 bit)
    }

    property var alarm_triggered:{
                "triggered": "false"  //or false when the alarm is reset
    }

    property var location_clicked_notification:{
                "location": "alarm" //string, with possible values: "doorbell", "alarm", "switch", "temperature", "light", "voltage", "security"
    }


    property var msg_dbg:{      //debug strings
            "msg":""
    }

    // set provisioner client to address (node or  GROUP_ID)
    property var node : ({
                             "cmd" : "node",
                             "payload": {
                                 "send":"abc"// default value
                             },

                             update: function (send) {
                                 this.set(send)
                                 this.send(this)
                             },
                             set: function (send) {
                                 this.payload.send = send
                             },
                             send: function () { CorePlatformInterface.send(this) },
                             show: function () { CorePlatformInterface.show(this) }
                         })
    //_________________________________________________________________________________________
    //    property var onoff_set : ({
    //            "cmd" : "onoff_set",
    //            "payload": {
    //                "ele_addr": 8000,  // in dec (16 bit uint),
    //                "state": "on"       // or "off"
    //            },

    //            update: function (address, state) {
    //                this.set(address, state)
    //                this.send(this)
    //            },
    //            set: function (inAddress, inState) {
    //                this.payload.ele_addr = inAddress;
    //                this.payload.state = inState;
    //            },
    //            send: function () { CorePlatformInterface.send(this) },
    //            show: function () { CorePlatformInterface.show(this) }
    //        })

    //    property var onoff_get : ({
    //            "cmd" : "onoff_get",
    //            "payload": {
    //                "ele_addr": 8000,  // in dec (16 bit uint),
    //            },

    //            update: function (address) {
    //                this.set(address, state)
    //                this.send(this)
    //            },
    //            set: function (inAddress) {
    //                this.payload.ele_addr = inAddress;
    //            },
    //            send: function () { CorePlatformInterface.send(this) },
    //            show: function () { CorePlatformInterface.show(this) }
    //        })

    property var set_dimmer_mode : ({
                                      "cmd" : "set_dimmer_mode",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                          "value":true
                                      },

                                      update: function (address,value) {
                                          this.set(address,value)
                                          this.send(this)
                                      },
                                      set: function (inAddress,inValue) {
                                          this.payload.node_id = inAddress;
                                          this.payload.value = inValue;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var get_dimmer_mode : ({
                                      "cmd" : "get_dimmer_mode",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                      },

                                      update: function (address) {
                                          this.set(address)
                                          this.send(this)
                                      },
                                      set: function (inAddress) {
                                          this.payload.node_id = inAddress;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var set_relay_mode : ({
                                      "cmd" : "set_relay_mode",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                          "value":true
                                      },

                                      update: function (address,value) {
                                          this.set(address,value)
                                          this.send(this)
                                      },
                                      set: function (inAddress,inValue) {
                                          this.payload.node_id = inAddress;
                                          this.payload.value = inValue;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var get_relay_mode : ({
                                      "cmd" : "get_relay_mode",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                      },

                                      update: function (address) {
                                          this.set(address)
                                          this.send(this)
                                      },
                                      set: function (inAddress) {
                                          this.payload.node_id = inAddress;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var set_alarm_mode : ({
                                      "cmd" : "set_alarm_mode",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                          "value":true
                                      },

                                      update: function (address,value) {
                                          this.set(address,value)
                                          this.send(this)
                                      },
                                      set: function (inAddress,inValue) {
                                          this.payload.node_id = inAddress;
                                          this.payload.value = inValue;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var get_alarm_mode : ({
                                      "cmd" : "get_alarm_mode",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                      },

                                      update: function (address) {
                                          this.set(address)
                                          this.send(this)
                                      },
                                      set: function (inAddress) {
                                          this.payload.node_id = inAddress;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var set_high_power_mode : ({
                                      "cmd" : "set_high_power_mode",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                          "value":true
                                      },

                                      update: function (address,value) {
                                          this.set(address,value)
                                          this.send(this)
                                      },
                                      set: function (inAddress,inValue) {
                                          this.payload.node_id = inAddress;
                                          this.payload.value = inValue;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var get_high_power_mode : ({
                                      "cmd" : "get_high_power_mode",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                      },

                                      update: function (address) {
                                          this.set(address)
                                          this.send(this)
                                      },
                                      set: function (inAddress) {
                                          this.payload.node_id = inAddress;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    //light_hsl_get has been depricated
    //use get_hsl_color instead
    property var light_hsl_get : ({
                                      "cmd" : "light_hsl_get",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                      },

                                      update: function (address) {
                                          this.set(address)
                                          this.send(this)
                                      },
                                      set: function (inAddress) {
                                          this.payload.ele_addr = inAddress;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    //light_hsl_set has been depreicated
    //use set_hsl_color instead
    property var light_hsl_set : ({
                                      "cmd" : "light_hsl_set",
                                      "payload": {
                                          "uaddr": 8000,  // in dec (16 bit uint),
                                          "h": 120,         // 0 to 360 degrees
                                          "s": 50,          // 0 to 100%
                                          "l": 50           // 0 to 100%
                                      },

                                      update: function (address, hue, saturation, lightness) {
                                          this.set(address,hue, saturation, lightness)
                                          this.send(this)
                                      },
                                      set: function (inAddress,inHue,inSaturation,inLightness) {
                                          this.payload.uaddr = inAddress;
                                          this.payload.h = inHue;
                                          this.payload.s = inSaturation;
                                          this.payload.l = inLightness;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var get_hsl_color : ({
                                      "cmd" : "get_hsl_color",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                      },

                                      update: function (address) {
                                          this.set(address)
                                          this.send(this)
                                      },
                                      set: function (inAddress) {
                                          this.payload.node_id = inAddress;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var set_hsl_color : ({
                                      "cmd" : "set_hsl_color",
                                      "payload": {
                                          "uaddr": 8000,  // in dec (16 bit uint),
                                          "h": 120,         // 0 to 360 degrees
                                          "s": 50,          // 0 to 100%
                                          "l": 50           // 0 to 100%
                                      },

                                      update: function (address, hue, saturation, lightness) {
                                          this.set(address,hue, saturation, lightness)
                                          this.send(this)
                                      },
                                      set: function (inAddress,inHue,inSaturation,inLightness) {
                                          this.payload.uaddr = inAddress;
                                          this.payload.h = inHue;
                                          this.payload.s = inSaturation;
                                          this.payload.l = inLightness;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var level_get : ({
                                  "cmd" : "level_get",
                                  "payload": {
                                      "ele_addr": 8000,  // in dec (16 bit uint),
                                  },

                                  update: function (address) {
                                      this.set(address)
                                      this.send(this)
                                  },
                                  set: function (inAddress) {
                                      this.payload.ele_addr = inAddress;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })

    property var sensor_set : ({
                                  "cmd" : "sensor_set",
                                  "payload": {
                                       "uaddr": 1000,  // in dec (16 bit uint)
                                       "sensor_type": "strata",  // magnetic_rotation, magnetic_detection, strata (string)
                                       "sensor_setting": 16  // in dec (8 bit uint)
                                  },

                                  update: function (address,type,setting) {
                                      this.set(address,type,setting)
                                      this.send(this)
                                  },
                                  set: function (inAddress,inType,inSetting) {
                                      this.payload.uaddr = inAddress;
                                      this.payload.sensor_type = inType;
                                      this.payload.sensor_setting = inSetting;
                                  },
                                  send: function () { CorePlatformInterface.send(this) },
                                  show: function () { CorePlatformInterface.show(this) }
                              })

    property var get_sensor_data : ({
                                   "cmd" : "sensor_get",
                                   "payload": {
                                       "uaddr": 1000,  // in dec (16 bit uint)
                                       "sensor_type": "temperature"  // ambient_light, magnetic_rotation, magnetic_detection, strata, default (string)
                                   },

                                   update: function (address,sensor_type) {
                                       this.set(address,sensor_type)
                                       this.send(this)
                                   },
                                   set: function (inAddress,inSensorType) {
                                       this.payload.uaddr = inAddress;
                                       this.payload.sensor_type = inSensorType;
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }
                               })

    property var get_all_sensor_data : ({
                                   "cmd" : "sensors_get_all",
                                   "payload": {
                                       "sensor_type": "temperature"  // ambient_light, magnetic_rotation, magnetic_detection, strata, default (string)
                                   },

                                   update: function (sensor_type) {
                                       this.set(sensor_type)
                                       this.send(this)
                                   },
                                   set: function (inSensorType) {
                                       this.payload.sensor_type = inSensorType;
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }
                               })


    property var bind_elements : ({
                                      "cmd" : "bind_elements",
                                      "payload": {
                                          "grp_id": 9864,               // in dec (16 bit),
                                          "ele_addr":[                 // More than one element addresses can be bound at a time
                                              0002,        // in dec (16 bit),
                                              0004,        // in dec (16 bit),
                                              0006         // in dec (16 bit),
                                          ]
                                      },

                                      update: function (groupID, addresses) {
                                          this.set(groupID, addresses)
                                          this.send(this)
                                      },
                                      set: function (inGroupID, inAddresses) {
                                          this.payload.grp_id = groupID;
                                          this.payload.ele_addr = inAddresses;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var unbind_elements : ({
                                        "cmd" : "unbind_elements",
                                        "payload": {
                                            "grp_id": 9864,               // in dec (16 bit),
                                            "ele_addr":[                 // More than one element addresses can be unbound at a time
                                                0002,        // in dec (16 bit),
                                                0004,        // in dec (16 bit),
                                                0006         // in dec (16 bit),
                                            ]
                                        },

                                        update: function (groupID, addresses) {
                                            this.set(groupID, addresses)
                                            this.send(this)
                                        },
                                        set: function (inGroupID, inAddresses) {
                                            this.payload.grp_id = groupID;
                                            this.payload.ele_addr = inAddresses;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var location_clicked : ({
                                          "cmd" : "location_clicked",
                                          "payload": {
                                              "location": "alarm",  //string, with possible values: "doorbell", "alarm", "switch", "temperature", "light", "voltage", "security"
                                          },

                                          update: function (location) {
                                              this.set(location)
                                              this.send(this)
                                          },
                                          set: function (inLocation) {
                                              this.payload.location = inLocation;
                                          },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }
                                      })

    property var get_battery_level : ({
                                          "cmd" : "battery_level_get",
                                          "payload": {
                                              "uaddr": 8000,  // in dec (16 bit uint),
                                          },

                                          update: function (address) {
                                              this.set(address)
                                              this.send(this)
                                              console.log("sending battery level get for",address);
                                          },
                                          set: function (inAddress) {
                                              this.payload.uaddr = inAddress;
                                          },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }
                                      })

    property var get_signal_strength : ({
                                            "cmd" : "get_signal_strength",
                                            "payload": {
                                                "node_id": 8000,  // in dec (16 bit uint),
                                            },

                                            update: function (address) {
                                                this.set(address)
                                                this.send(this)
                                            },
                                            set: function (inAddress) {
                                                this.payload.node_id = inAddress;
                                            },
                                            send: function () { CorePlatformInterface.send(this) },
                                            show: function () { CorePlatformInterface.show(this) }
                                        })

    property var get_ambient_light : ({
                                          "cmd" : "get_ambient_light",
                                          "payload": {
                                              "node_id": 8000,  // in dec (16 bit uint),
                                          },

                                          update: function (address) {
                                              this.set(address)
                                              this.send(this)
                                          },
                                          set: function (inAddress) {
                                              this.payload.node_id = inAddress;
                                          },
                                          send: function () { CorePlatformInterface.send(this) },
                                          show: function () { CorePlatformInterface.show(this) }
                                      })

    property var get_temperature : ({
                                        "cmd" : "get_temperature",
                                        "payload": {
                                            "node_id": 8000,  // in dec (16 bit uint),
                                        },

                                        update: function (address) {
                                            this.set(address)
                                            this.send(this)
                                        },
                                        set: function (inAddress) {
                                            this.payload.node_id = inAddress;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var get_network : ({
                                        "cmd" : "get_network_map",
                                        "payload": {
                                        },

                                        update: function () {
                                            this.send()
                                        },
                                        set: function () {
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


//    // DEBUG Window for testing motor vortex UI without a platform
//    Window {
//        id: debug
//        visible: true
//        width: 400
//        height: 400

//        Rectangle {
//            id: test1
//            width: parent.width
//            height: parent.height/4
//            color: "transparent"


//            SGSubmitInfoBox{
//                anchors.fill:parent
//                buttonText: "Send"
//                onAccepted: {
//                    console.log("text",text.toString())
//                    platformInterface.node.update(text.toString())
//                }
//            }
//        }
//        Button {
//            id:test2
//            anchors.top: test1.bottom
//            text: "get network notification"
//            onClicked: {
//                CorePlatformInterface.data_source_handler('{
//                                                "value":"network_notification",
//                                                "payload":{
//                                                         "nodes":  [
//                                                                    {"index":0,"available":1,"color":"#00ff00"},
//                                                                    {"index":1,"available":1,"color":"#ff00ff"} ,
//                                                                    {"index":2,"available":1,"color":"#ff4500"} ,
//                                                                    {"index":3,"available":1,"color":"#ffff00"} ,
//                                                                    {"index":4,"available":1,"color":"#7cfc00"},
//                                                                    {"index":5,"available":1,"color":"#00ff7f"},
//                                                                    {"index":6,"available":1,"color":"#ffc0cb"},
//                                                                    {"index":8,"available":1,"color":"#9370db"}

//                                                            ]
//                                                }

//                               } ')
//            }

//        }

//        Button {
//            id:test3
//            anchors.top: test2.bottom
//            checkable: true
//            checked:false
//            text: checked ? "alarm off" : "alarm!"

//            property bool alarmIsOn: checked;

//            onClicked: {
//                CorePlatformInterface.data_source_handler('{
//                   "value":"alarm_triggered",
//                    "payload":{
//                        "triggered": "'+alarmIsOn+'"
//                     }

//                     } ')
//            }

//        }



//    } //end of windows
}