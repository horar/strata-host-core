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
        "ele_addr": "8000",  // in dec (16 bit)
        "sensor": "8000" // in dec (16 bit), (string)
    }

    property var battery_level : {
        "node_id": "8000",  // in dec (16 bit)
        "ele_addr": "8000",  // in dec (16 bit)
        "battery": "50",      // 0 to 100% (string)
        "charging":"true",      //or false
        "t_discharge": "1000", // in dec (32 bit)
        "t_charge": "1000" // in dec (32 bit)

    }

    property var signal_strength : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "100",  // in dB? %?
    }

    property var ambient_light : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "100",  // in lumens?
    }

    property var temperature : {
        "node_id": "8000",  // in dec (16 bit)
        "value": "100",  // in in °C?
    }

    property var network_notification : {
        "nodes": [{
                      "index": "1",
                      "available": 0,       //or false
                      "color": "#ffffff"    //RGB hex value of the node color
                  }]
    }

    property var node_added : {
        "node_id": "8000",  // in dec (16 bit)
        "color": "#ffffff",  //RGB hex value of the node color
    }

    property var node_removed : {
        "node_id": "8000",  // in dec (16 bit)
    }

    //    property var msg_dbg:{      //debug strings
    //            "msg":""
    //    }
    //    onMsg_dbgChanged: {
    //        console.log(platformInterface.msg_dbg);
    //    }


    //Tanya: msg_dbg notification
    property var msg_dbg: {
        "msg": ""
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

    property var light_hsl_set : ({
                                      "cmd" : "light_hsl_set",
                                      "payload": {
                                          "node_id": 8000,  // in dec (16 bit uint),
                                          "h": 120,         // 0 to 360 degrees
                                          "s": 50,          // 0 to 100%
                                          "l": 50           // 0 to 100%
                                      },

                                      update: function (address, hue, saturation, lightness) {
                                          this.set(address,hue, saturation, lightness)
                                          this.send(this)
                                      },
                                      set: function (inAddress,inHue,inSaturation,inLightness) {
                                          this.payload.node_id = inAddress;
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

    property var sensor_get : ({
                                   "cmd" : "sensor_get",
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



    // -------------------------------------------------------------------
    // Listens to message notifications coming from CoreInterface.cpp
    // Forward messages to core_platform_interface.js to process

    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }


    // DEBUG Window for testing motor vortex UI without a platform
    Window {
        id: debug
        visible: true
        width: 400
        height: 400

        Rectangle {
            id: test1
            width: parent.width
            height: parent.height/2
            color: "transparent"


            SGSubmitInfoBox{
                anchors.fill:parent
                buttonText: "Send"
                onAccepted: {
                    console.log("text",text.toString())
                    platformInterface.node.update(text.toString())
                }
            }
        }
        Button {
            id:test2
            anchors.top: test1.bottom
            text: "get network notification"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                                                "value":"network_notification",
                                                "payload":{
                                                         "nodes":  [
                                                                    {"index":0,"available":0,"color":"#00ff00"},
                                                                    {"index":1,"available":1,"color":"#ff00ff"} ,
                                                                    {"index":2,"available":1,"color":"#ff4500"} ,
                                                                    {"index":3,"available":1,"color":"black"} ,
                                                                    {"index":4,"available":0,"color":"#7cfc00"},
                                                                    {"index":5,"available":1,"color":"#00ff7f"},
                                                                    {"index":6,"available":0,"color":"#00ffff"},
                                                                    {"index":7,"available":1,"color":"#00ced1"},
                                                                    {"index":8,"available":0,"color":"#ffffff"}

                                                            ]
                                                }

                               } ')
            }

        }

    } //end of windows
}
