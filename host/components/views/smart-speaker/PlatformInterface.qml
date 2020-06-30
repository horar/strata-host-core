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
    }


    property var equalizer_level:{
        "band":0,            // All controls are floats from -18 to 18 dB
        "level":15
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
         "negotiated_current":0.0,              // amps - current specified by the device, will be lower than "target_maximum_current"
         "negotiated_voltage":0.0,            // volts - advertised and negotiated voltage
         "input_voltage":0.0,                 // volts
         "output_voltage":0.0,                 // volts - actual measured output voltage
         "input_current":0.0,                  // amps
         "output_current":0.0,                 // amps
         "temperature":0.0,                      // degrees C
         "maximum_power":0.0                     // in watts

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
        "state":"pause"          //or "pause" or "status"
    }

    //until this can be set from elsewhere, we'll ignore this so there's not a name collision with the command
//    property var change_track:{
//        "action":"next_track"       //or "restart_track" or "previous_track"
//    }

    property var audio_power:{
        "audio_current":0.5,
         "audio_voltage":11.95,
         "audio_power":5,
    }



    property var battery_status:{
        "ambient_temp":25,       /* degrees C */
        "battery_temp":35,         /* degrees C */
        "state_of_health":100,     /* 0-100 */
        "time_to_empty":150,     /* minutes, does not show a real value until 10% change has occurred */
        "time_to_full":20,            /* minutes */
        "rsoc":75,                       /* percent */
        "total_run_time":350,     /* minutes */
        "no_battery_indicator":true,      /* or false*/
        "battery_voltage":4.2,
        "battery_current":1.2,      /* can be positive or negative; negative means charging */
        "battery_power": 3.8
    }

    property var charger_status:{
        "float_voltage":4.2,           /* has a range of voltages, but this is only one used*/
        "charge_mode":"fast",           /* ‘pre’ or ‘top off' or 'sleep’ or 'discharge'*/
        "precharge_current":100,        /* (mA) 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800 /
        "termination_current":100,      /* (mA) 100 - 200 in 25mA increments, 200 - 600 in 50mA increments */
        "ibus_limit":50,                 /* (mA) 100-3000 in 25mA increments */
        "fast_chg_current":200,         /* (mA) 200-3200 in 50 mA increments */
        "vbus_ovp":6.5,                 /*  (V) or 10.5 or 13.7*/
        "audio_power_mode":"vbus"       /*or battery*/
    }

    property var led_state:{
        "lower_on":true,
        "upper_on":true,
        "H":128,                                  /* Hue values are 0 to 359 */
        "V":128,                                 /* value betwen 0 and 100 */
    }

    property var audio_amp_id:{
        "dev_id":32,
        "ver_id":6,
    }

    property var audio_amp_voltage:{
        "usb_volts":12,                             //depending on amp type
        "battery_volts":14,                         //can be 5.5 to 14V depending on the ONA10
        "type":"usb"                            //or battery
    }

    property var touch_button_state:{
        "state":true
    }

    property var thermal_protection_temp:{
        "value":70               //or 85, 100, 120
    }

    property var vbus_ovp_level:{
        "value":6.5
    }

    property var fet_bypass:{
        "state":true,
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
                      },
                  update: function(inMaster){
                      this.set(inMaster);
                      CorePlatformInterface.send(this)
                  },
                  set:function(inMaster){
                      this.payload.master = inMaster;
                  },
                  send: function(){
                      CorePlatformInterface.send(this);
                  }
               })



    property var set_equalizer_level:({
                   "cmd":"set_equalizer_level",
                   "payload":{
                       "band":1,     // All controls are floats from -18 to 18dB
                       "level":0.0
                       },
                   update: function(band,level){
                       console.log("update eq for band",band,"to",level);
                       this.set(band,level)
                       CorePlatformInterface.send(this)
                       },
                   set: function(inBand,inLevel){
                       console.log("setting eq for band",inBand,"to",inLevel);

                       this.payload.band = inBand;
                       this.payload.level = inLevel;
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

    property var changeTrack:({
                    "cmd":"change_track",
                    "payload":{
                        "action":"next_track"             // or "restart_track, "previous_track
                    },
                    update:function(inTrackCommand){
                          this.set(inTrackCommand)
                          CorePlatformInterface.send(this);
                          },
                    set:function(inTrackCommand){
                          this.payload.action = inTrackCommand;
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

    property var set_charger_current:({
                 "cmd":"set_charger_current",
                 "payload":{
                    "type":"set_vbus_current_limit",       // or set_fast_current_limit, set_precharge_current_limit set_termination_current_limit
                    "current":50
                    },
                 update: function(type,current){
                   this.set(type,current)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inType, inCurrent){
                   this.payload.type = inType;
                   this.payload.current = inCurrent;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_led_state:({
                 "cmd":"set_led_state",
                 "payload":{
                    "set":"lower",                        // or false
                    "state":true,
                    "H":128,
                    "V":0
                    },
                 update: function(set,state,h,v){
                   this.set(set,state,h,v)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inSet, inState, inH, inV){
                   this.payload.set = inSet;
                     this.payload.state = inState;
                     this.payload.H = inH;
                     this.payload.V = inV;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var get_audio_amp_id:({
                 "cmd":"get_audio_amp_id",
                 "payload":{},
                 update: function(){
                   this.set()
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_audio_amp_voltage:({
                 "cmd":"set_audio_amp_voltage",
                 "payload":{
                  "usb_volts":12,
                  "battery_volts":5.5,
                  "type":"usb"
                  },
                 update: function(usb,battery,type){
                   this.set(usb,battery,type)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inUSB,inBattery,inType){
                     this.payload.usb_volts = inUSB;
                      this.payload.battery_volts = inBattery;
                      this.payload.type = inType;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_touch_button_state:({
                 "cmd":"set_touch_button_state",
                 "payload":{
                  "state":"on"
                  },
                 update: function(state){
                   this.set(state)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inState){
                     this.payload.state = inState;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_thermal_protection_temp:({
                 "cmd":"set_touch_button_state",
                 "payload":{
                  "value":70            //or ‘85, 100, 120
                  },
                 update: function(value){
                   this.set(value)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inValue){
                     this.payload.value = inValue;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_vbus_ovp_level:({
                 "cmd":"set_vbus_ovp_level",
                 "payload":{
                    "value":6.5
                  },
                 update: function(value){
                   this.set(value)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inValue){
                     this.payload.value = inValue;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_fet_bypass:({
                 "cmd":"set_fet_bypass",
                 "payload":{
                    "state":true
                  },
                 update: function(state){
                   this.set(state)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inState){
                     this.payload.state = inState;
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



}
