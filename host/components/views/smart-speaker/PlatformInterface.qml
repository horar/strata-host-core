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


    property var mixer_levels:{
        "ch1":0,             // All values are in dB, (0= MUTE), 1 = -95.25 dB, ..., 254 = -0.375 dB, 255 = 0 dB)
        "ch2":0,
        "ch3":0,
        "ch4":0,
        "ch5":0
    }

    property var volume:{
        "left":0,           // where value is mute =-127, -127, -126, …, 0, 1, 2, …, 41, 42 // dB
        "right":0
    }

    property var equalizer_levels:{
        "band1":0.5,            // All controls are floats from 0.0-01.0
        "band2":0.5,
        "band3":0.5,
        "band4":0.5,
        "band5":0.5,
        "band6":0.5
    }

   property var bluetooth_devices:{
        "count":2,
        "devices":[]            //array of strings "device1", "device2", etc.
    }

    property var bluetooth_pairing:{
         "value":"not paired",    //or "paired"
         "id":"device1"            // device identifier, if paired.
     }

    property var wifi_connections:{
         "count":2,
         "devices":[]            //array of strings "device1", "device2", etc.
     }

    property var wifi_status:{
         "value":"not connected",    //or "connected"
         "ssid":"1234",            // ssid if connected
         "dbm": 0                   //received signal power if connected
     }

    property var usb_pd_port_connect:{
         "port_id":1,
         "connection_state":"connected"  //or "disconnected"
     }

    property var request_usb_power_notification:{
         "port":1,
         "device":"none",                      //or "non-PD" or "none" if disconnected
         "advertised_maximum_current":3.00, // amps - maximum available current for the negotiated voltage
         "negotiated_current":0,              // amps - current specified by the device, will be lower than "target_maximum_current"
         "negotiated_voltage":0,            // volts - advertised and negotiated voltage
         "input_voltage":0,                 // volts
         "output_voltage":0,                 // volts - actual measured output voltage
         "input_current":0,                  // amps
         "output_current":0,                 // amps
         "temperature":0,                      // degrees C
         "maximum_power":0                     // in watts

     }

    property var usb_pd_advertised_voltages_notification:{
        "port":0,                            // The port number that this applies to
        "maximum_power":45,                  // watts
        "number_of_settings":7,              // 1-7
        "settings":[]                        // each setting object includes
                                             // "voltage":5,                // Volts
                                             // "maximum_current":3.0,      // Amps
    }

    // --------------------------------------------------------------------------------------------
    //          Commands
    //--------------------------------------------------------------------------------------------

    property var requestPlatformId:({
                 "cmd":"request_platform_id",
                 "payload":{
                  },
                 send: function(){
                      CorePlatformInterface.send(this)
                 }
     })

   property var refresh:({
                "cmd":"request_platform_refresh",
                "payload":{
                 },
                send: function(){
                     CorePlatformInterface.send(this)
                }
    })

    property var set_mixer_levels:({
                "cmd":"set_mixer_levels",
                "payload":{
                    "ch1":0, // All values are in dB, (0= MUTE, 1 = -95.25 dB, ..., 254 = -0.375 dB, 255 = 0 dB)
                    "ch1":0,
                    "ch1":0,
                    "ch1":0,
                    "ch1":0
                     },
                update: function(ch1,ch2,ch3,ch4,ch5){
                    this.set(ch1,ch2,ch3,ch4,ch5)
                    CorePlatformInterface.send(this)
                    },
                set: function(inCh1,inCh2,inCh3,inCh4,inCh5){
                    this.payload.Ch1 = inCh1;
                    this.payload.Ch2 = inCh2;
                    this.payload.Ch3 = inCh3;
                    this.payload.Ch4 = inCh4;
                    this.payload.Ch5 = inCh5;
                    },
               send: function(){
                    CorePlatformInterface.send(this);
                    }
                })

    property var set_volume:({
                 "cmd":"set_volume",
                 "payload":{
                     "Left": 0,     // where value is mute =-127, -127, -126, …, 0, 1, 2, …, 41, 42 // dB
                     "Right": 0
                      },
                  update: function(inLeft, inRight){
                      this.set(inLeft,inRight);
                      CorePlatformInterface.send(this)
                  },
                  set:function(inLeft,inRight){
                      this.payload.Left = inLeft;
                      this.payload.Right = inRight;
                  },
                  send: function(){
                      CorePlatformInterface.send(this);
                  }
               })

    property var set_equalizer_levels:({
                   "cmd":"set_equalizer_levels",
                   "payload":{
                       "band1":0.5,     // All controls are floats from 0.0-01.0
                       "band2":0.5,
                       "band3":0.5,
                       "band4":0.5,
                       "band5":0.5,
                       "band6":0.5
                       },
                   update: function(ch1,ch2,ch3,ch4,ch5){
                       this.set(ch1,ch2,ch3,ch4,ch5)
                       CorePlatformInterface.send(this)
                       },
                   set: function(inCh1,inCh2,inCh3,inCh4,inCh5,inCh6){
                       this.payload.band1 = inCh1;
                       this.payload.band2 = inCh2;
                       this.payload.band3 = inCh3;
                       this.payload.band4 = inCh4;
                       this.payload.band5 = inCh5;
                       this.payload.band6 = inCh6;
                       },
                   send:function(){
                        CorePlatformInterface.send(this);
                       }
               })

    property var get_bluetooth_devices:({
                    "cmd":"get_bluetooth_devices",
                    "payload":{},
                     update:function(){
                         CorePlatformInterface.send(this);
                     },
                     set:function(){},
                     send:function(){
                         CorePlatformInterface.send(this);
                     }
                })

    property var set_bluetooth_pairing:({
                    "cmd":"set_bluetooth_pairing",
                    "payload":{
                         "ID":"deviceName"
                     },
                     update:function(){
                         CorePlatformInterface.send(this);
                         },
                     set:function(){},
                     send:function(){
                         CorePlatformInterface.send(this);
                         }
                })

    property var get_bluetooth_pairing:({
                    "cmd":"get_bluetooth_pairing",
                    "payload":{},
                     update:function(){
                         CorePlatformInterface.send(this);
                         },
                     set:function(){},
                     send:function(){
                         CorePlatformInterface.send(this);
                         }
                })

    property var get_wifi_connections:({
                    "cmd":"get_wifi_connections",
                    "payload":{},
                     update:function(){
                         CorePlatformInterface.send(this);
                     },
                     set:function(){},
                     send:function(){
                         CorePlatformInterface.send(this);
                     }
                })

    property var connect_wifi:({
                    "cmd":"connect_wifi",
                    "payload":{
                         "ssid":"",
                         "pw":""
                     },
                     update:function(){
                         this.set(inSSID,inPassword)
                         CorePlatformInterface.send(this);
                         },
                     set:function(inSSID, inPassword){
                        this.payload.ssid = inSSID;
                        this.payload.pw = inPassword;
                        },
                     send:function(){
                         CorePlatformInterface.send(this);
                         }
                })
    property var get_wifi_status:({
                    "cmd":"get_wifi_status",
                    "payload":{},
                     update:function(){
                         CorePlatformInterface.send(this);
                     },
                     set:function(){},
                     send:function(){
                         CorePlatformInterface.send(this);
                     }
                })

    property var enable_power_telemetry:({
                 "cmd":"enable_power_telemetry",
                 "payload":{
                    "enabled":true                        // or 'false' if disabling periodic notifications
                    },
                 update: function(enabled){
                   this.set(enabled)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inEnabled){
                   this.payload.enabled = inEnabled;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    // -------------------  end commands

    // NOTE:
    //  All internal property names for PlatformInterface must avoid name collisions with notification/cmd message properties.
    //   naming convention to avoid name collisions;
    // property var _name


    // -------------------------------------------------------------------
    // Connect to CoreInterface notification signals
    //
    Connections {
        target: coreInterface
        onNotification: {
            if (!payload.includes("power_notification")){
                console.log("**** Notification",payload);
            }
            CorePlatformInterface.data_source_handler(payload)
        }
    }




   /*     // DEBUG - TODO: Faller - Remove before merging back to Dev
    Window {
        id: debug
        visible: true
        width: 225
        height: 200

        function randomColor(){
            var red1 = Math.floor((Math.random()*255));
            var red1Hex = red1.toString(16).toUpperCase()
            if (red1Hex.length % 2) {
              red1Hex = '0' + red1Hex;
            }

            var green1 = Math.floor(Math.random()*255);
            green1 = green1.toString(16)
            var green1Hex = green1.toString(16).toUpperCase()
            if (green1Hex.length % 2) {
              green1Hex = '0' + green1Hex;
            }

            var blue1 = Math.floor(Math.random()*255);
            var blue1Hex = blue1.toString(16).toUpperCase()
            if (blue1Hex.length % 2) {
              blue1Hex = '0' + blue1Hex;
            }

            return(red1Hex + green1Hex + blue1Hex);
        }

        Button {
            id: leftButton1
            text: "disable pulse"
            onClicked: {
                var color1 = debug.randomColor();
                var color2 = debug.randomColor();
                //console.log("random color 1 is:",red1Hex, green1Hex, blue1Hex, color1);
                CorePlatformInterface.data_source_handler('{
                                   "value":"set_pulse_colors_notification",
                                   "payload": {
                                            "enabled": false,
                                            "channel1_color":"'+ color1 +'",
                                            "channel2_color":"'+color2+'"
                                        }
                                    }')
            }
        }

        Button {
            id: button1
            text: "enable/set pulse"
            anchors.left: leftButton1.right
            onClicked: {
                var color1 = debug.randomColor();
                var color2 = debug.randomColor();
                //console.log("random color 1 is:",red1Hex, green1Hex, blue1Hex, color1);
                CorePlatformInterface.data_source_handler('{
                                   "value":"set_pulse_colors_notification",
                                   "payload": {
                                            "enabled": true,
                                            "channel1_color":"'+ color1 +'",
                                            "channel2_color":"'+color2+'"
                                        }
                                    }')
            }
        }

        Button {
            id: leftButton2
            anchors { top: button1.bottom }
            text: "disable linear"
            onClicked: {
                var theRandomColor = debug.randomColor();
                CorePlatformInterface.data_source_handler('{
                    "value":"set_linear_color_notification",
                    "payload":{
                                "enabled":false,
                                "color":"'+theRandomColor+'"
                               }
                             }')
            }
        }

        Button {
            id: button2
            anchors.top: button1.bottom
            anchors.left: leftButton2.right
            text: "enable/set linear"
            onClicked: {
                var theRandomColor = debug.randomColor();
                CorePlatformInterface.data_source_handler('{
                    "value":"set_linear_color_notification",
                    "payload":{
                                "enabled":true,
                                "color":"'+theRandomColor+'"
                               }
                             }')
            }
        }


        Button {
            id:leftButton3
            anchors { top: button2.bottom }
            text: "disable buck"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"set_buck_intensity_notification",
                            "payload":{
                                    "enabled":false,
                                     "intensity":'+ (Math.random()*100).toFixed(0) +'
                            }
                    }')
            }
        }

        Button {
            id:button3
            anchors.top: button2.bottom
            anchors.left:leftButton2.right
            text: "enable/set buck"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"set_buck_intensity_notification",
                            "payload":{
                                    "enabled":true,
                                     "intensity":'+ (Math.random()*100).toFixed(0) +'
                            }
                    }')
            }
        }


        Button {
            id:leftButton4
            anchors { top: button3.bottom }
            text: "disable boost"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"set_boost_intensity_notification",
                            "payload":{
                                    "enabled":false,
                                     "intensity":'+ (Math.random()*100).toFixed(0) +'
                            }
                    }')
            }
        }

        Button {
            id:button4
            anchors.top: button3.bottom
            anchors.left: leftButton4.right
            text: "enable/set boost"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"set_boost_intensity_notification",
                            "payload":{
                                    "enabled":true,
                                     "intensity":'+ (Math.random()*100).toFixed(0) +'
                            }
                    }')
            }
        }


        Button {
            id:button5
            anchors { top: button4.bottom }
            text: "update buck telemetry"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"led_buck_power_notification",
                            "payload":{
                                    "input_voltage":'+ (Math.random() + 12).toFixed(1) +',
                                     "output_voltage":'+ (Math.random() + 9).toFixed(2) +',
                                    "input_current":'+ (Math.random() + 100).toFixed(0) +',
                                    "output_current":'+ (Math.random() + 100).toFixed(0) +',
                                    "temperature":'+ (Math.random()*5 + 40).toFixed(0) +'
                            }
                    }')
            }
        }
    }
    */
}
