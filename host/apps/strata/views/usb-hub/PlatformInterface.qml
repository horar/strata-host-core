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

    // @notification request_usb_power_notification
    // @description: shows relevant data for a single port.
    //
    property var request_usb_power_notification : {
        "port": 1,
        "device": "PD",
        "advertised_maximum_current": 0.0,
        "negotiated_current": 0.0,
        "negotiated_voltage": 0.0,
        "input_voltage": 0.0,
        "output_voltage":0.0,
        "input_current": 0.0,
        "output_current":0.0,
        "temperature": 0.0,
        "maximum_power":0.0
    }

    onRequest_usb_power_notificationChanged: {
//        console.log("output voltage=",request_usb_power_notification.output_voltage,
//                    "output current=",request_usb_power_notification.output_current,
//                    "power=",request_usb_power_notification.output_voltage * request_usb_power_notification.output_current);
    }


    // @notification usb_pd_port_connect
    // @description: sent when a device is connected or disconnected
    //
    property var usb_pd_port_connect : {
        "port_id": "",
        "connection_state":"unknown"
    }
    onUsb_pd_port_connectChanged: {
        console.log("usb_pd_port_connect changed. port_id=",usb_pd_port_connect.port_id," connection_state=",usb_pd_port_connect.connection_state);
    }

    property var usb_pd_port_disconnect:{
        "port_id": "unknown",
        "connection_state": "unknown"
    }

    property var usb_pd_protection_action:{
         "action":"shutdown"     // or "nothing" or "retry"
    }


   property var input_under_voltage_notification:{
          "state":"below",                                        // if the input voltage decreases to below the voltage limit, "above" otherwise.
          "minimum_voltage":0                                     // Voltage limit in volts
    }

//    onInput_under_voltage_notificationChanged: {
//        console.log("input voltage is",input_under_voltage_notification.state,
//                    " minimum voltage = ",input_under_voltage_notification.minimum_voltage);

//    }

    property var set_maximum_temperature_notification:{
            "maximum_temperature":0                         // degrees C
            }

   property var over_temperature_notification:{
           "port":"USB_C_port_1",                                // or any USB C port
           "state":"above",                                      // if the temperature crossed from under temperature to over temperature, "below" otherwise.
           "maximum_temperature":191                             // Temperature limit in degrees C
    }

        //consider the values held by this property to be the master ones, which will be current when needed for calling
        //the API to set the input voltage foldback
    property var foldback_input_voltage_limiting_event:{
            "input_voltage":0,
            "foldback_minimum_voltage":0,
            "foldback_minimum_voltage_power":0,
            "input_voltage_foldback_enabled":false,
            "input_voltage_foldback_active":true
    }

//  onFoldback_input_voltage_limiting_eventChanged: {
//        console.log("input voltage foldback values updated");
//        console.log("input voltage event notification. values are ",foldback_input_voltage_limiting_refresh.foldback_minimum_voltage,
//                                                                    foldback_input_voltage_limiting_refresh.foldback_minimum_voltage_power,
//                                                                    foldback_input_voltage_limiting_refresh.input_voltage_foldback_enabled,
//                                                                    foldback_input_voltage_limiting_refresh.input_voltage_foldback_active);
//        }

    property var foldback_input_voltage_limiting_refresh:{
            "input_voltage":0,
            "foldback_minimum_voltage":0,
            "foldback_minimum_voltage_power":0,
            "input_voltage_foldback_enabled":false,
            "input_voltage_foldback_active":true
    }

    //keep the refresh and event notification properties in synch
//    onFoldback_input_voltage_limiting_refreshChanged: {
//        //console.log("input voltage refresh notification. minimum voltage = ",foldback_input_voltage_limiting_refresh.foldback_minimum_voltage);

//            //update the variables for foldback limiting
//        platformInterface.foldback_input_voltage_limiting_event.input_voltage = foldback_input_voltage_limiting_refresh.input_voltage;

//        platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage = foldback_input_voltage_limiting_refresh.foldback_minimum_voltage;
//        console.log(" foldback minimum voltage = ",platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage);
//        platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power = foldback_input_voltage_limiting_refresh.foldback_minimum_voltage_power;
//        platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled = foldback_input_voltage_limiting_refresh.input_voltage_foldback_enabled;
//        platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_active = foldback_input_voltage_limiting_refresh.input_voltage_foldback_active;
//    }

    //consider the values held by this property to be the master ones, which will be current when needed for calling
    //the API to set the input temperature foldback
    property var temperature_foldback_notification:{
            "current_temperature":0,
            "foldback_maximum_temperature":200,
            "foldback_power_reduction_percentage":15,
            "temperature_foldback_enabled":true,
            "temperature_foldback_active":true,
            "temperature_hysteresis":0              //in °C
    }

    property var usb_pd_maximum_power:{
        "port":0,                            // up to maximum number of ports
        "current_max_power":0,               // 15 | 27 | 36 | 45 | 60 | 100
        "default_max_power":0,               // 15 | 27 | 36 | 45 | 60 | 100
        "commanded_max_power":0
    }

    property var request_over_current_protection_notification:{
        "port":0,                           // 1, 2, ... maximum port number
        "current_limit":0,                  // amps - output current  exceeds this level
        "exceeds_limit":false,              // or false
        "action":"nothing",                 // "retry" or "shutdown" or "nothing"
        "enabled":false                     // or false
    }

    property var get_cable_loss_compensation:{
        "port":0,                           // Same port as in the command above.
        "output_current":0,                 // Amps
        "bias_voltage":0,                   // Volts
    }

    property var usb_pd_advertised_voltages_notification:{
        "port":0,                            // The port number that this applies to
        "maximum_power":45,                  // watts
        "number_of_settings":7,              // 1-7
        "settings":[]                        // each setting object includes
                                             // "voltage":5,                // Volts
                                             // "maximum_current":3.0,      // Amps
    }

    property var request_reset_notification :{
         "reset_status":true                   // only one value : true since only sent at the start
    }

    //when the platform sends a reset notification, the host must make a platformId call to initialize communication
    //and a Refresh() command to synchronize settings with the platform
    onRequest_reset_notificationChanged: {
        console.log("Requesting Refresh")
        platformInterface.refresh.send() //ask the platform for all the current values
    }

    //this call doesn't exist yet in the API. This is a placeholder
    property var power_negotiation :{
         "negotiation_type":"dynamic"           // or "first_come_first_served" or "priority"
    }

    property var sleep_mode :{
         "mode":"manual"           // or "automatic"
    }

    property var manual_sleep_mode :{
         "mode":"on"           // or "off"
    }

    property var maximum_board_power :{
         "watts":30          // 30-300
    }

    property var usb_a_port_is_charging_notification:{
        "port":0,
        "charging": false       //or true
    }

    property var device_characteristics_notification:{
        "port":0,
        "source":false,
        "sink":false,
        "fast_role_swap":false,
        "superspeed":false,
        "extended_sink":false
    }

    onDevice_characteristics_notificationChanged: {
        console.log("device characteristics changed ",device_characteristics_notification.port,
                                                       device_characteristics_notification.source,
                                                    device_characteristics_notification.fast_role_swap,
                                                    device_characteristics_notification.superspeed,
                                                    device_characteristics_notification.extended_sink);
    }

    property var displayport_video_active_notification:{
        "video_active": false       //or true
    }

    property var audio_active_notification:{
        "audio_active": false       //or true
    }

    property var audio_volume_notification:{
        "volume":1       //value between 0 and 1
    }

    property var port_is_displayport_sink_notification:{
        "port":0,
        "is_displayport_sink":false
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

    property var set_protection_action:({
                "cmd":"request_protection_action",
                "payload":{
                        "action":"shutdown"         // "shutdown" or "retry" or "nothing"
                     },
                update: function(protectionAction){
                    this.set(protectionAction)
                    CorePlatformInterface.send(this)
                },
                set: function(protectionAction){
                    this.payload.action = protectionAction;
                },
                send: function(){
                    CorePlatformInterface.send(this)
                },
                show: function(){
                    CorePlatformInterface.show(this)
                }
    })
    
    property var set_minimum_input_voltage:({
               "cmd":"request_set_minimum_voltage",
               "payload":{
                    "value":0    // 0 - 20v
               },
                update: function(minimumVoltage){
                    this.set(minimumVoltage)
                    CorePlatformInterface.send(this)
                },
                set: function(minimumVoltage){
                    this.payload.value = minimumVoltage;
                },
                send: function(){
                    CorePlatformInterface.send(this)
                },
                show: function(){
                    CorePlatformInterface.show(this)
                }
    })

    property var set_maximum_temperature :({
                "cmd":"request_set_maximum_temperature",
                "payload":{
                       "value":200    // 0 - 127 degrees C
                 },
                 update: function(maximumTemperature){
                      this.set(maximumTemperature)
                      CorePlatformInterface.send(this)
                      },
                 set: function(maximumTemperature){
                      this.payload.value = maximumTemperature;
                      },
                 send: function(){
                       CorePlatformInterface.send(this)
                      },
                show: function(){
                      CorePlatformInterface.show(this)
                      }
    })

    property var  set_input_voltage_foldback:({
                  "cmd":"request_voltage_foldback",
                  "payload":{
                        "enabled":false,  // or true
                        "voltage":0,    // in Volts
                         "power":45      // in Watts
                       },
                   update: function(enabled,voltage,watts){
                       console.log("input voltage foldback update: enabled=",enabled,"voltage=",voltage,"watts=",watts);
                       //set the notification property values, as the platform won't send a notification in response to this
                       //command, and those properties are used by controls to see what the value of other controls should be.
                       foldback_input_voltage_limiting_event.input_voltage_foldback_enabled = enabled;
                       foldback_input_voltage_limiting_event.foldback_minimum_voltage = voltage;
                       foldback_input_voltage_limiting_event.foldback_minimum_voltage_power = watts;
                        this.set(enabled,voltage,watts)
                        CorePlatformInterface.send(this)
                        },
                   set: function(enabled,voltage,watts){
                        this.payload.enabled = enabled;
                        this.payload.voltage = voltage;
                        this.payload.power = watts;
                        },
                   send: function(){
                        CorePlatformInterface.send(this)
                        },
                   show: function(){
                        CorePlatformInterface.show(this)
                        }
    })

    property var  set_temperature_foldback:({
                  "cmd":"set_temperature_foldback",
                  "payload":{
                        "enabled":false,  // or true
                        "temperature":0,    // in °C
                        "power_reduction":45,      // in percent
                        "temperature_hysteresis":0              //in °C
                       },
                   update: function(enabled,temperature,percentage,hysterisis){
                       //update the variables for this action
                       set_temperature_foldback.temperature = temperature;
                       set_temperature_foldback.power_reduction = percentage;
                       set_temperature_foldback.enabled = enabled;
                       set_temperature_foldback.temperature_hysteresis = hysterisis;
                        this.set(enabled,temperature,percentage,hysterisis)
                        CorePlatformInterface.send(this)
                        },
                   set: function(enabled,temperature,percentage,hysteresis){
                        this.payload.enabled = enabled;
                        this.payload.temperature = temperature;
                        this.payload.power_reduction = percentage;
                        this.payload.temperature_hysterisis = hysterisis
                        },
                   send: function(){
                        CorePlatformInterface.send(this)
                        },
                   show: function(){
                        CorePlatformInterface.show(this)
                        }
    })

    property var set_usb_pd_maximum_power : ({
                    "cmd":"request_usb_pd_maximum_power",
                    "payload":{
                         "port":0,      // up to maximum number of ports
                         "watts":0      // 15 | 27 | 36 | 45 | 60 | 100
                         },
                    update: function (port, watts){
                        this.set(port,watts);
                        CorePlatformInterface.send(this);
                    },
                    set: function(port,watts){
                        this.payload.port = port;
                        this.payload.watts = watts;
                    },
                    send: function () { CorePlatformInterface.send(this) },
                    show: function () { CorePlatformInterface.show(this) }
    })

    property var set_over_current_protection:({
                    "cmd":"request_over_current_protection",
                    "payload":{
                        "port":0,                    // 1, 2, 3, ... up to maximum number of ports
                        "enabled":true,           // or false
                        "maximum_current":12,    // amps
                      },
                      update: function (port, maxCurrent){
                          this.set(port,maxCurrent);
                          CorePlatformInterface.send(this);
                          },
                      set: function(port,maxCurrent){
                           this.payload.port = port;
                           this.payload.enabled = true;    //the UI currently has no way to disable over current protection
                           this.payload.maximum_current = maxCurrent;
                                                  },
                      send: function () { CorePlatformInterface.send(this) },
                      show: function () { CorePlatformInterface.show(this) }
    })

    property var set_cable_loss_compensation:({
                    "cmd":"set_cable_loss_compensation",
                    "payload":{
                        "port":1,                   // 1, 2, 3, ... up to maximum number of ports
                        "output_current":0,         // amps
                        "bias_voltage":0            // Volts
                      },
                      update: function (portNumber, outputCurrent, biasVoltage){
                          console.log("set_cable_loss_compensation.port=",portNumber);
                          console.log("set_cable_loss_compensation.output_current=",outputCurrent);
                          console.log("set_cable_loss_compensation.bias_voltage=",biasVoltage);

                          this.set(portNumber,outputCurrent,biasVoltage);
                          //console.log("sending set_cable_loss_compensation cmd ", JSON.stringify(this));
                          CorePlatformInterface.send(this);
                          },
                      set: function(portNumber,outputCurrent,biasVoltage){
                           this.payload.port = portNumber;

                           this.payload.output_current = outputCurrent;
                           this.payload.bias_voltage = biasVoltage;
                                                  },
                      send: function () { CorePlatformInterface.send(this) },
                      show: function () { CorePlatformInterface.show(this) }
    })

    property var set_power_negotiation:({
                    "cmd":"set_power_negotiation",
                    "payload":{
                    "negotiation_type":"dynamic",    // or firstComeFirstServed or priority
                      },
                      update: function (type){
                          this.set(type);
                          CorePlatformInterface.send(this);
                          },
                      set: function(type){
                           this.payload.negotiation_type = type;
                           },
                      send: function () { CorePlatformInterface.send(this) },
                      show: function () { CorePlatformInterface.show(this) }
    })

    property var set_sleep_mode:({
                    "cmd":"set_sleep_mode",
                    "payload":{
                        "mode":"manual",    // or automatic
                      },
                      update: function (mode){
                          this.set(mode);
                          CorePlatformInterface.send(this);
                          },
                      set: function(mode){
                           this.payload.mode = mode;
                           },
                      send: function () { CorePlatformInterface.send(this) },
                      show: function () { CorePlatformInterface.show(this) }
    })

    property var set_manual_sleep_mode:({
                    "cmd":"set_manual_sleep_mode",
                    "payload":{
                        "mode":"on",    // or off
                      },
                      update: function (mode){
                          this.set(mode);
                          CorePlatformInterface.send(this);
                          },
                      set: function(mode){
                           this.payload.mode = mode;
                           },
                      send: function () { CorePlatformInterface.send(this) },
                      show: function () { CorePlatformInterface.show(this) }
    })

    property var set_maximum_board_power:({
                    "cmd":"set_maximum_board_power",
                    "payload":{
                        "watts":0      // value between 30 and 200
                      },
                      update: function (inPower){
                          this.set(inPower);
                          CorePlatformInterface.send(this);
                          },
                      set: function(power){
                           this.payload.watts = power;
                           },
                      send: function () { CorePlatformInterface.send(this) },
                      show: function () { CorePlatformInterface.show(this) }
    })

    property var set_audio_volume:({
                    "cmd":"set_audio_volume",
                    "payload":{
                        "volume":0      // value between 0 and 1
                      },
                      update: function (inVolume){
                          this.set(inVolume);
                          CorePlatformInterface.send(this);
                          },
                      set: function(volume){
                           this.payload.volume = volume;
                           },
                      send: function () { CorePlatformInterface.send(this) },
                      show: function () { CorePlatformInterface.show(this) }
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
            if (!payload.includes("request_usb_power_notification")){
                console.log("**** Notification",payload);
            }
            CorePlatformInterface.data_source_handler(payload)
        }
    }



/*
        // DEBUG - TODO: Faller - Remove before merging back to Dev
    Window {
        id: debug
        visible: true
        width: 200
        height: 240

        Button{
            id: button0
            text:"blank button"
        }

        Button {
            id: button1
            anchors { top: button0.bottom }
            text: "basic port stats"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                    "value":"request_usb_power_notification",
                    "payload": {
                        "port": '+ (Math.random()*3 + 1).toFixed(0) +',
                        "device": "PD",
                        "advertised_maximum_current": '+ (Math.random()*20).toFixed(0) +',
                        "negotiated_current": '+ (Math.random()*20).toFixed(0) +',
                        "negotiated_voltage": '+ (Math.random()*20).toFixed(0) +',
                        "input_voltage": '+ (Math.random()*20).toFixed(2) +',
                        "output_voltage":'+ (Math.random()*20).toFixed(2) +',
                        "input_current": '+ (Math.random()*20).toFixed(2) +',
                        "output_current":'+ (Math.random()*20).toFixed(2) +',
                        "temperature": '+ (Math.random()*212).toFixed(1) +',
                        "maximum_power":'+ (Math.random()*20).toFixed(0) +'
                        }
                    }')
            }
        }


        Button {
            id: button2
            anchors { top: button1.bottom }
            text: "device characteristics"

            function randomBool(){
                if (Math.random() >= .5)
                    return true;
                  else
                    return false;
            }

            onClicked: {
                CorePlatformInterface.data_source_handler('{
                    "value":"device_characteristics_notification",
                    "payload":{
                        "port":'+ (Math.random()*4 + 1).toFixed(0) +',
                        "source":'+ randomBool() +',
                        "sink":'+ randomBool() +',
                        "fast_role_swap":'+ randomBool() +',
                        "superspeed":'+ randomBool() +',
                        "extended_sink":'+ randomBool() +'
                        }
                     }')
            }
        }

        Button {
            id:button3
            anchors { top: button2.bottom }
            text: "start audio"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"audio_active_notification",
                            "payload":{
                                     "audio_active":true
                            }
                    }
            ')
            }
        }

        Button {
            id:button4
            anchors { top: button3.bottom }
            text: "end audio"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"audio_active_notification",
                            "payload":{
                                     "audio_active":false
                            }
                    }
            ')
            }
        }

        Button {
            id:button5
            anchors { top: button4.bottom }
            text: "start video"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"displayport_video_active_notification",
                            "payload":{
                                     "video_active":true
                            }
                    }
            ')
            }
        }

        Button {
            id:button6
            anchors { top: button5.bottom }
            text: "end video"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"displayport_video_active_notification",
                            "payload":{
                                     "video_active":false
                            }
                    }
            ')
            }
        }
    */

}
