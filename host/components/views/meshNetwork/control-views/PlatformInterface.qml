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
//    property var status_onoff : {
//        "ele_addr": "8000",     // in dec (16 bit)
//        "state":  "on"         // or "off"
//    }

    property var status_light_hsl : {
        "ele_addr": 8000,  // in dec (16 bit)
        "h": 120,         // 0 to 360 degrees (string)
        "s": 50,          // 0 to 100% (string)
        "l": 50           // 0 to 100% (string)
    }

    //a generic status level
//    property var status_level : {
//        "ele_addr": "8000",  // in dec (16 bit)
//        "level": "8000" // in dec (16 bit), (string)
//    }

    //notification back from a sensor on a node
    property var sensor_status : {
        "uaddr": 0,  // in dec (16 bit)
        "sensor_type": "",  // temperature ambient_light, magnetic_rotation, magnetic_detection, rssi, default (string)
        "data":""
    }

    property var battery_status : {
        "uaddr": "8000",  // in dec (16 bit)
        "battery_level": "50",      // 0 to 100% (string)
        "battery_voltage": "4.0",   // voltage (string)
        "battery_state": "charging", //or "not charging" or "charged"
    }

//    property var signal_strength : {
//        "node_id": "8000",  // in dec (16 bit)
//        "value": "100",  // in dB? %?
//    }

//    property var ambient_light : {
//        "node_id": "8000",  // in dec (16 bit)
//        "value": "100",  // in lumens?
//    }

//    property var dimmer_mode : {
//        "node_id": "8000",  // in dec (16 bit)
//        "value": "true",
//    }
//    property var relay_mode : {
//        "node_id": "8000",  // in dec (16 bit)
//        "value": "true",
//    }
//    property var alarm_mode : {
//        "node_id": "8000",  // in dec (16 bit)
//        "value": "true",
//    }
//    property var high_power_mode : {
//        "node_id": "8000",  // in dec (16 bit)
//        "value": "true",
//    }

    property var room_color_notification : {
        "color": ""     //"blue", "green","purple","red","off" or "on"
    }

    //no longer used for communication to platform, but for communication within the UI
    property var smarthome_door : {
        "value": "closed"     //or "open"
    }

    //no longer used for communication to platform, but for communication within the UI
    property var window_shade : {
        "value": "closed"     //or "open"
    }

    property var hsl_color : {
        "node_id": 8000,  // in dec (16 bit)
        "h": 120,         // 0 to 360 degrees (string)
        "s": 50,          // 0 to 100% (string)
        "l": 50           // 0 to 100% (string)
    }

//    property var temperature : {
//        "node_id": "8000",  // in dec (16 bit)
//        "value": "100",  // in in °C?
//    }

    property var network_notification : {
        "nodes": [{
                      "index": 1,         //the node_id
                      "ready": 0,           //or false
                      "color": "#ffffff"    //RGB hex value of the node color
                  }]
    }

//    onNetwork_notificationChanged: {
//        console.log("new network notification")
//         for (var alpha = 0;  alpha < platformInterface.network_notification.nodes.length  ; alpha++){
//            console.log("index=",platformInterface.network_notification.nodes[alpha].index,
//                        "ready=",platformInterface.network_notification.nodes[alpha].ready,
//                        "color=",platformInterface.network_notification.nodes[alpha].color);
//         }
//    }

    property var node_added : {
        "index": 1,  // in dec (16 bit)
        "color": "green",  //RGB hex value of the node color
    }

    property var node_removed : {
        "index": 0,  // in dec (16 bit)
    }

    property var alarm_triggered:{
                "triggered": "false"  //or false when the alarm is reset
    }

//    property var location_clicked_notification:{
//                "location": "alarm" //string, with possible values: "doorbell", "alarm", "switch", "temperature", "light", "voltage", "security"
//    }

//    property var demo_click_notification : {
//        "demo": "",             //"one_to_one"or "one_to_many", "relay", "multiple_models","sensor","cloud"
//        "button": "",           //"switch" or "switch1","switch2","relay_switch", "bulb1","bulb2","bulb3" "get_sensor_data"
//        "value":"on"
//    }

    property var one_to_one_demo:{
                "light": "on"  //or off
    }

    property var one_to_many_demo:{
                "lights": "on"  //or off
    }

    property var msg_cli:{      //console message strings
            "msg":""
    }

    // set provisioner client to address (node or  GROUP_ID)
//    property var node : ({
//                             "cmd" : "node",
//                             "payload": {
//                                 "send":"abc"// default value
//                             },

//                             update: function (send) {
//                                 this.set(send)
//                                 this.send(this)
//                             },
//                             set: function (send) {
//                                 this.payload.send = send
//                             },
//                             send: function () { CorePlatformInterface.send(this) },
//                             show: function () { CorePlatformInterface.show(this) }
//                         })
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

    property var set_node_mode : ({
                                      "cmd" : "set_node_mode",
                                      "payload": {
                                          "mode":0,
                                          "uaddr": 8000,  // in dec (16 bit uint),
                                          "enable":true
                                      },

                                      update: function (mode,address,enabled) {
                                          this.set(mode,address,enabled)
                                          this.send(this)
                                      },
                                      set: function (inMode,inAddress,inEnabled) {
                                          this.payload.mode = inMode;
                                          this.payload.uaddr = parseInt(inAddress);
                                          this.payload.enable = inEnabled;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

//    property var set_dimmer_mode : ({
//                                      "cmd" : "set_dimmer_mode",
//                                      "payload": {
//                                          "node_id": 8000,  // in dec (16 bit uint),
//                                          "value":true
//                                      },

//                                      update: function (address,value) {
//                                          this.set(address,value)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress,inValue) {
//                                          this.payload.node_id = inAddress;
//                                          this.payload.value = inValue;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var get_dimmer_mode : ({
//                                      "cmd" : "get_dimmer_mode",
//                                      "payload": {
//                                          "node_id": 8000,  // in dec (16 bit uint),
//                                      },

//                                      update: function (address) {
//                                          this.set(address)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress) {
//                                          this.payload.node_id = inAddress;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var set_relay_mode : ({
//                                      "cmd" : "set_relay_mode",
//                                      "payload": {
//                                          "node_id": 8000,  // in dec (16 bit uint),
//                                          "value":true
//                                      },

//                                      update: function (address,value) {
//                                          this.set(address,value)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress,inValue) {
//                                          this.payload.node_id = inAddress;
//                                          this.payload.value = inValue;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var get_relay_mode : ({
//                                      "cmd" : "get_relay_mode",
//                                      "payload": {
//                                          "node_id": 8000,  // in dec (16 bit uint),
//                                      },

//                                      update: function (address) {
//                                          this.set(address)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress) {
//                                          this.payload.node_id = inAddress;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var set_alarm_mode : ({
//                                      "cmd" : "set_alarm_mode",
//                                      "payload": {
//                                          "node_id": 8000,  // in dec (16 bit uint),
//                                          "value":true
//                                      },

//                                      update: function (address,value) {
//                                          this.set(address,value)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress,inValue) {
//                                          this.payload.node_id = inAddress;
//                                          this.payload.value = inValue;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var get_alarm_mode : ({
//                                      "cmd" : "get_alarm_mode",
//                                      "payload": {
//                                          "node_id": 8000,  // in dec (16 bit uint),
//                                      },

//                                      update: function (address) {
//                                          this.set(address)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress) {
//                                          this.payload.node_id = inAddress;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var set_high_power_mode : ({
//                                      "cmd" : "set_high_power_mode",
//                                      "payload": {
//                                          "node_id": 8000,  // in dec (16 bit uint),
//                                          "value":true
//                                      },

//                                      update: function (address,value) {
//                                          this.set(address,value)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress,inValue) {
//                                          this.payload.node_id = inAddress;
//                                          this.payload.value = inValue;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var get_high_power_mode : ({
//                                      "cmd" : "get_high_power_mode",
//                                      "payload": {
//                                          "node_id": 8000,  // in dec (16 bit uint),
//                                      },

//                                      update: function (address) {
//                                          this.set(address)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress) {
//                                          this.payload.node_id = inAddress;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

    property var set_room_color : ({
                                      "cmd" : "set_room_color",
                                      "payload": {
                                          "color": "on",  // or "green","purple","red", "off", "blue"
                                      },

                                      update: function (color) {
                                          this.set(color)
                                          this.send(this)
                                      },
                                      set: function (inColor) {
                                          this.payload.color = inColor;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

//    property var toggle_door : ({
//                                      "cmd" : "toggle_door",
//                                      "payload": {
//                                          "value": "open",  // or "closed"
//                                      },

//                                      update: function (value) {
//                                          this.set(value)
//                                          this.send(this)
//                                      },
//                                      set: function (inValue) {
//                                          this.payload.value = inValue;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

    //this is used internally by the UI, but not recognized by the firmware
    property var toggle_window_shade : ({
                                      "cmd" : "toggle_window_shade",
                                      "payload": {
                                          "value": "open",  // or "closed"
                                      },

                                      update: function (value) {
                                          this.set(value)
                                          this.send(this)
                                      },
                                      set: function (inValue) {
                                          this.payload.value = inValue;
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

//    property var get_hsl_color : ({
//                                      "cmd" : "get_hsl_color",
//                                      "payload": {
//                                          "node_id": 8000,  // in dec (16 bit uint),
//                                      },

//                                      update: function (address) {
//                                          this.set(address)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress) {
//                                          this.payload.node_id = inAddress;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var set_hsl_color : ({
//                                      "cmd" : "set_hsl_color",
//                                      "payload": {
//                                          "uaddr": 8000,  // in dec (16 bit uint),
//                                          "h": 120,         // 0 to 360 degrees
//                                          "s": 50,          // 0 to 100%
//                                          "l": 50           // 0 to 100%
//                                      },

//                                      update: function (address, hue, saturation, lightness) {
//                                          this.set(address,hue, saturation, lightness)
//                                          this.send(this)
//                                      },
//                                      set: function (inAddress,inHue,inSaturation,inLightness) {
//                                          this.payload.uaddr = inAddress;
//                                          this.payload.h = inHue;
//                                          this.payload.s = inSaturation;
//                                          this.payload.l = inLightness;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var level_get : ({
//                                  "cmd" : "level_get",
//                                  "payload": {
//                                      "ele_addr": 8000,  // in dec (16 bit uint),
//                                  },

//                                  update: function (address) {
//                                      this.set(address)
//                                      this.send(this)
//                                  },
//                                  set: function (inAddress) {
//                                      this.payload.ele_addr = inAddress;
//                                  },
//                                  send: function () { CorePlatformInterface.send(this) },
//                                  show: function () { CorePlatformInterface.show(this) }
//                              })

//    property var sensor_set : ({
//                                  "cmd" : "sensor_set",
//                                  "payload": {
//                                       "uaddr": 1000,  // in dec (16 bit uint)
//                                       "sensor_type": "strata",  // magnetic_rotation, magnetic_detection, strata (string)
//                                       "sensor_setting": 16  // in dec (8 bit uint)
//                                  },

//                                  update: function (address,type,setting) {
//                                      this.set(address,type,setting)
//                                      this.send(this)
//                                  },
//                                  set: function (inAddress,inType,inSetting) {
//                                      this.payload.uaddr = inAddress;
//                                      this.payload.sensor_type = inType;
//                                      this.payload.sensor_setting = inSetting;
//                                  },
//                                  send: function () { CorePlatformInterface.send(this) },
//                                  show: function () { CorePlatformInterface.show(this) }
//                              })

    property var get_sensor : ({
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

    property var set_groupid : ({
                                   "cmd" : "set_groupid",
                                   "payload": {
                                        "group_id": 49633,            // in dec (16 bit),
                                        "uaddr": 1,
                                        "model": "battery_server",    // battery_server, light_hsl_server, sensor_server, onoff_server, nothing, default
                                        "subscribe":true              // or false to desubscribe
                                   },

                                   update: function (group_id,address, model, subscribe) {
                                       this.set(group_id,address, model, subscribe)
                                       this.send(this)
                                   },
                                   set: function (inGroup, inAddress, inModel, inSubscribe) {
                                       this.payload.group_id = inGroup;
                                       this.payload.uaddr = inAddress;
                                       this.payload.model = inModel;
                                       this.payload.subscribe = inSubscribe;
                                   },
                                   send: function () { CorePlatformInterface.send(this) },
                                   show: function () { CorePlatformInterface.show(this) }
                               })

//    property var bind_elements : ({
//                                      "cmd" : "bind_elements",
//                                      "payload": {
//                                          "grp_id": 9864,               // in dec (16 bit),
//                                          "ele_addr":[                 // More than one element addresses can be bound at a time
//                                              0002,        // in dec (16 bit),
//                                              0004,        // in dec (16 bit),
//                                              0006         // in dec (16 bit),
//                                          ]
//                                      },

//                                      update: function (groupID, addresses) {
//                                          this.set(groupID, addresses)
//                                          this.send(this)
//                                      },
//                                      set: function (inGroupID, inAddresses) {
//                                          this.payload.grp_id = groupID;
//                                          this.payload.ele_addr = inAddresses;
//                                      },
//                                      send: function () { CorePlatformInterface.send(this) },
//                                      show: function () { CorePlatformInterface.show(this) }
//                                  })

//    property var unbind_elements : ({
//                                        "cmd" : "unbind_elements",
//                                        "payload": {
//                                            "grp_id": 9864,               // in dec (16 bit),
//                                            "ele_addr":[                 // More than one element addresses can be unbound at a time
//                                                0002,        // in dec (16 bit),
//                                                0004,        // in dec (16 bit),
//                                                0006         // in dec (16 bit),
//                                            ]
//                                        },

//                                        update: function (groupID, addresses) {
//                                            this.set(groupID, addresses)
//                                            this.send(this)
//                                        },
//                                        set: function (inGroupID, inAddresses) {
//                                            this.payload.grp_id = groupID;
//                                            this.payload.ele_addr = inAddresses;
//                                        },
//                                        send: function () { CorePlatformInterface.send(this) },
//                                        show: function () { CorePlatformInterface.show(this) }
//                                    })

//    property var location_clicked : ({
//                                          "cmd" : "location_clicked",
//                                          "payload": {
//                                              "location": "alarm",  //string, with possible values: "doorbell", "alarm", "switch", "temperature", "light", "voltage", "security"
//                                          },

//                                          update: function (location) {
//                                              this.set(location)
//                                              this.send(this)
//                                          },
//                                          set: function (inLocation) {
//                                              this.payload.location = inLocation;
//                                          },
//                                          send: function () { CorePlatformInterface.send(this) },
//                                          show: function () { CorePlatformInterface.show(this) }
//                                      })

//    property var get_battery_level : ({
//                                          "cmd" : "battery_level_get",
//                                          "payload": {
//                                              "uaddr": 8000,  // in dec (16 bit uint),
//                                          },

//                                          update: function (address) {
//                                              this.set(address)
//                                              this.send(this)
//                                              console.log("sending battery level get for",address);
//                                          },
//                                          set: function (inAddress) {
//                                              this.payload.uaddr = inAddress;
//                                          },
//                                          send: function () { CorePlatformInterface.send(this) },
//                                          show: function () { CorePlatformInterface.show(this) }
//                                      })

//    property var get_signal_strength : ({
//                                            "cmd" : "get_signal_strength",
//                                            "payload": {
//                                                "node_id": 8000,  // in dec (16 bit uint),
//                                            },

//                                            update: function (address) {
//                                                this.set(address)
//                                                this.send(this)
//                                            },
//                                            set: function (inAddress) {
//                                                this.payload.node_id = inAddress;
//                                            },
//                                            send: function () { CorePlatformInterface.send(this) },
//                                            show: function () { CorePlatformInterface.show(this) }
//                                        })

//    property var get_ambient_light : ({
//                                          "cmd" : "get_ambient_light",
//                                          "payload": {
//                                              "node_id": 8000,  // in dec (16 bit uint),
//                                          },

//                                          update: function (address) {
//                                              this.set(address)
//                                              this.send(this)
//                                          },
//                                          set: function (inAddress) {
//                                              this.payload.node_id = inAddress;
//                                          },
//                                          send: function () { CorePlatformInterface.send(this) },
//                                          show: function () { CorePlatformInterface.show(this) }
//                                      })

//    property var get_temperature : ({
//                                        "cmd" : "get_temperature",
//                                        "payload": {
//                                            "node_id": 8000,  // in dec (16 bit uint),
//                                        },

//                                        update: function (address) {
//                                            this.set(address)
//                                            this.send(this)
//                                        },
//                                        set: function (inAddress) {
//                                            this.payload.node_id = inAddress;
//                                        },
//                                        send: function () { CorePlatformInterface.send(this) },
//                                        show: function () { CorePlatformInterface.show(this) }
//                                    })

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

//    property var set_demo : ({
//                                        "cmd" : "set_demo",
//                                        "payload": {
//                                            "demo":"demo"
//                                        },

//                                        update: function (demoName) {
//                                            this.set(demoName)
//                                            this.send(this)
//                                        },
//                                        set: function (inDemoName) {
//                                            this.payload.demo = inDemoName;
//                                        },
//                                        send: function () { CorePlatformInterface.send(this) },
//                                        show: function () { CorePlatformInterface.show(this) }
//                                    })

    property var set_onetoone_demo : ({
                                        "cmd" : "set_onetoone_demo",
                                        "payload": {
                                              "uaddr":65535,
                                              "daddr":2
                                        },

                                        update: function (bulbAddress) {
                                            this.set(bulbAddress)
                                            this.send(this)
                                        },
                                        set: function (inAddress) {
                                            this.payload.daddr = inAddress
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })


    property var demo_click : ({
                                        "cmd" : "demo_click",
                                        "payload": {
                                              "demo":"demo",
                                              "button":"button",
                                              "value":"off"
                                        },

                                        update: function (demoName,buttonName,value) {
                                            this.set(demoName,buttonName,value)
                                            this.send(this)
                                        },
                                        set: function (inDemoName,inButtonName,inValue) {
                                            this.payload.demo = inDemoName;
                                            this.payload.button = inButtonName;
                                            this.payload.value = inValue;
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var switch_views : ({
                                        "cmd" : "switch_views",
                                        "payload": {
                                              "uaddr":[],                           // array of node addresses
                                              "mode":[]                             // relay, high_power, charging, door, alarm, security_camera, hvac, doorbell,
                                                                                    // buzzer, robotic_arm, window_shade, smarthome_door, smarthome_lights, default
                                        },

                                        update: function (address,mode) {
                                            this.set(address,mode)
                                            this.send(this)
                                        },
                                        set: function (inAddress,inMode) {
                                            this.payload.uaddr = inAddress;
                                            this.payload.mode = inMode;
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
