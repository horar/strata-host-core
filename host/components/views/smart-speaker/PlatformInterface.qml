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


    property var volume:{
        "master":0,           // where value is mute =-42, -41, …, 0, 1, 2, …, 41, 42 // dB
        "sub": 4             // where value is 0 (mute), 16, 21, 23, 26 // dB
    }


    property var equalizer_levels:{
        "band1":0,            // All controls are floats from -18 to 18 dB
        "band2":0,
        "band3":0,
        "band4":0,
        "band5":0,
        "band6":0,
        "band7":0,
        "band8":0,
        "band9":0,
        "band10":0
    }


   property var bluetooth_devices:{
        "count":2,
        "devices":["one","two","three"]            //array of strings "device1", "device2", etc.
    }


    property var bluetooth_pairing:{
         "value":"not paired",    //or "paired"
         "id":"device1"            // device identifier, if paired.
     }


    property var wifi_connections:{
         "count":2,
         "devices":["one","two","three"]            //array of strings "device1", "device2", etc.
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

    property var play_pause:{
        "state":"play"          //or "pause" or "status"
    }

    //until this can be set from elsewhere, we'll ignore this so there's not a name collision with the command
//    property var change_track:{
//        "action":"next_track"       //or "restart_track" or "previous_track"
//    }

    property var audio_power:{
        "input_voltage":"16.01",
        "analog_audio_current":"0.5",
        "digital_audio_current":"0.5",
         "audio_voltage":"11.95"
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


    property var set_volume:({
                 "cmd":"set_volume",
                 "payload":{
                     "master": 0,     // where value is mute =-42, -41, …, 0, 1, 2, …, 41, 42 // dB
                     "sub": 4       // where value is 0 (mute), 16, 21, 23, 26 // dB
                      },
                  update: function(inMaster, inSub){
                      this.set(inMaster, inSub);
                      CorePlatformInterface.send(this)
                  },
                  set:function(inMaster, inSub){
                      this.payload.master = inMaster;
                      this.payload.sub = inSub;
                  },
                  send: function(){
                      CorePlatformInterface.send(this);
                  }
               })



    property var set_equalizer_levels:({
                   "cmd":"set_equalizer_levels",
                   "payload":{
                       "band1":0.5,     // All controls are floats from -18 to 18dB
                       "band2":0.5,
                       "band3":0.5,
                       "band4":0.5,
                       "band5":0.5,
                       "band6":0.5,
                       "band7":0.5,
                       "band8":0.5,
                       "band9":0.5,
                       "band10":0.5
                       },
                   update: function(ch1,ch2,ch3,ch4,ch5,ch6,ch7,ch8,ch9,ch10){
                       this.set(ch1,ch2,ch3,ch4,ch5,ch6,ch7,ch8,ch9,ch10)
                       CorePlatformInterface.send(this)
                       },
                   set: function(inCh1,inCh2,inCh3,inCh4,inCh5,inCh6,inCh7,inCh8,inCh9,inCh10){
                       this.payload.band1 = inCh1;
                       this.payload.band2 = inCh2;
                       this.payload.band3 = inCh3;
                       this.payload.band4 = inCh4;
                       this.payload.band5 = inCh5;
                       this.payload.band6 = inCh6;
                       this.payload.band7 = inCh7;
                       this.payload.band8 = inCh8;
                       this.payload.band9 = inCh9;
                       this.payload.band10 = inCh10;
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
                     update:function(inDeviceName){
                         this.set(inDeviceName);
                         CorePlatformInterface.send(this);
                         },
                     set:function(inDeviceName){
                         this.payload.ID = inDeviceName;
                        },
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
                     set:function(){
                     },
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
                     update:function(inSSID,inPassword){
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

    property var set_play:({
                    "cmd":"play_pause",
                    "payload":{
                        "state":"play"             // or “pause” or “status” (no state change for ‘status’)
                    },
                    update:function(inPlayCommand){
                          this.set(inPlayCommand)
                          CorePlatformInterface.send(this);
                          },
                    set:function(inPlayCommand){
                          this.payload.state = inPlayCommand;
                          },
                    send:function(){
                          CorePlatformInterface.send(this);
                          }
                })

    property var change_track:({
                    "cmd":"change_track",
                    "payload":{
                        "state":"next_track"             // or "restart_track, "previous_track
                    },
                    update:function(inTrackCommand){
                          this.set(inTrackCommand)
                          CorePlatformInterface.send(this);
                          },
                    set:function(inTrackCommand){
                          this.payload.state = inTrackCommand;
                          },
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




        // DEBUG - TODO: Faller - Remove before merging back to Dev
    Window {
        id: debug
        visible: true
        width: 225
        height: 200


        function makeRandomDeviceName(length) {
           var result           = '';
           var characters       = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
           var charactersLength = characters.length;
           for ( var i = 0; i < length; i++ ) {
              result += characters.charAt(Math.floor(Math.random() * charactersLength));
           }
           return result;
        }

        Button {
            id: leftButton1
            text: "mixer"
            onClicked: {

                CorePlatformInterface.data_source_handler('{
                                   "value":"volume",
                                   "payload": {
                                            "value": "'+ (Math.random()*84 - 42) +'"
                                        }
                                    }')
                CorePlatformInterface.data_source_handler('{
                                   "value":"mixer_levels",
                                   "payload": {
                                            "ch1":"'+ (Math.random()*-95).toFixed(0) +'",
                                            "ch2":"'+ (Math.random()*-95).toFixed(0) +'",
                                            "ch3":"'+ (Math.random()*-95).toFixed(0) +'",
                                            "ch4":"'+ (Math.random()*-95).toFixed(0) +'",
                                            "ch5":"'+ (Math.random()*-95).toFixed(0) +'"
                                        }
                                    }')
            }
        }

        Button {
            id: button1
            text: "EQ"
            anchors.left: leftButton1.right
            onClicked: {

                CorePlatformInterface.data_source_handler('{
                                   "value":"equalizer_levels",
                                   "payload": {
                                            "band1":"'+ (Math.random()*36-18) +'",
                                            "band2":"'+ (Math.random()*36-18) +'",
                                            "band3":"'+ (Math.random()*36-18) +'",
                                            "band4":"'+ (Math.random()*36-18) +'",
                                            "band5":"'+ (Math.random()*36-18) +'",
                                            "band6":"'+ (Math.random()*36-18) +'"
                                        }
                                    }')
            }
        }

        Button {
            id: leftButton2
            anchors { top: button1.bottom }
            text: "USB Telemetry"
            onClicked: {

                CorePlatformInterface.data_source_handler('{
                    "value":"request_usb_power_notification",
                    "payload":{
                        "port":1,
                        "device":"none",
                        "advertised_maximum_current": "'+ (Math.random() *10).toFixed(1) +'",
                        "negotiated_current": "'+ (Math.random() *10).toFixed(1) +'",
                        "negotiated_voltage":"'+ (Math.random() *10).toFixed(1) +'",
                        "input_voltage":"'+ (Math.random() *10).toFixed(1) +'",
                        "output_voltage":"'+ (Math.random() *10).toFixed(1) +'",
                        "input_current":"'+ (Math.random() *10).toFixed(1) +'",
                        "output_current":"'+ (Math.random() *10).toFixed(1) +'",
                        "temperature":"'+ (Math.random() *10).toFixed(1) +'",
                        "maximum_power":"'+ (Math.random() *10).toFixed(1) +'"
                               }
                             }')
            }
        }


         property var bluetooth_pairing:{
              "value":"not paired",    //or "paired"
              "id":"device1"            // device identifier, if paired.
          }

        Button {
            id: button2
            anchors.top: button1.bottom
            anchors.left: leftButton2.right
            text: "bluetooth"
            onClicked: {
                var device1 = debug.makeRandomDeviceName(5);
                var device2 = debug.makeRandomDeviceName(5);
                var device3 = debug.makeRandomDeviceName(5);
                var device4 = debug.makeRandomDeviceName(5);
                var device5 = debug.makeRandomDeviceName(5);
                CorePlatformInterface.data_source_handler('{
                    "value":"bluetooth_devices",
                    "payload":{
                                "count":5,
                                "devices":["'+device1+'",
                                            "'+device2+'",
                                            "'+device3+'",
                                            "'+device4+'",
                                            "'+device5+'"]
                               }
                             }')
                CorePlatformInterface.data_source_handler('{
                    "value":"bluetooth_pairing",
                    "payload":{
                                "value":"paired",
                                "id":"'+device3+'"
                               }
                             }')
            }
        }



        Button {
            id:leftButton3
            anchors { top: button2.bottom }
            text: "wireless"
            onClicked: {
                var device1 = debug.makeRandomDeviceName(5);
                var device2 = debug.makeRandomDeviceName(5);
                var device3 = debug.makeRandomDeviceName(5);
                var device4 = debug.makeRandomDeviceName(5);
                var device5 = debug.makeRandomDeviceName(5);
                CorePlatformInterface.data_source_handler('{
                            "value":"wifi_connections",
                            "payload":{
                                    "count":5,
                                     "devices":["'+device1+'",
                                            "'+device2+'",
                                            "'+device3+'",
                                            "'+device4+'",
                                            "'+device5+'"]
                            }
                    }')

                CorePlatformInterface.data_source_handler('{
                    "value":"wifi_status",
                    "payload":{
                                "value":"connected",
                                "ssid":"'+device3+'",
                                "dbm": 0
                               }
                             }')
            }
        }

        Button {
            id:button3
            anchors { top: button2.bottom
                     left: leftButton3.right}
            text: "sourceCap"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                    "value":"usb_pd_advertised_voltages_notification",
                    "payload":{
                                "port":1,
                                "maximum_power":60,
                                "number_of_settings": 7,
                                "settings":[{"voltage":5,
                                            "maximum_current":'+ (Math.random() *10).toFixed(0) +'
                                            },
                                            {"voltage":7,
                                            "maximum_current":'+ (Math.random() *10).toFixed(0) +'
                                            },
                                            {"voltage":8,
                                            "maximum_current":'+ (Math.random() *10).toFixed(0) +'
                                            },
                                            {"voltage":9,
                                            "maximum_current":'+ (Math.random() *10).toFixed(0) +'
                                            },
                                            {"voltage":12,
                                            "maximum_current":'+ (Math.random() *10).toFixed(0) +'
                                            },
                                            {"voltage":15,
                                            "maximum_current":'+ (Math.random() *10).toFixed(0) +'
                                            },
                                            {"voltage":20,
                                            "maximum_current":'+ (Math.random() *10).toFixed(0) +'}]
                               }
                             }')
            }
        }

    }

}
