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


    // @notification usb_pd_port_connect
    // @description: sent when a device is connected or disconnected
    //
    property var usb_pd_port_connect : {
        "port": "",
        "connection_state":"unknown"        //or "connected" or "disconnected"
    }
    //    onUsb_pd_port_connectChanged: {
    //        console.log("usb_pd_port_connect changed. port=",usb_pd_port_connect.port," connection_state=",usb_pd_port_connect.connection_state);
    //    }


    property var set_minimum_voltage_notification : {
        "minimum_voltage":10
    }



    property var usb_pd_protection_action:{
        "action":"retry"     // or "nothing" or "retry"
    }


    property var input_under_voltage_notification:{
        "state":"above",                                        // if the input voltage decreases to below the voltage limit, "above" otherwise.
        "minimum_voltage":10                                     // Voltage limit in volts
    }

    //    onInput_under_voltage_notificationChanged: {
    //        console.log("input voltage is",input_under_voltage_notification.state,
    //                    " minimum voltage = ",input_under_voltage_notification.minimum_voltage);

    //    }

    property var set_maximum_temperature_notification:{
        "maximum_temperature":100                         // degrees C
    }

    property var temperature_hysteresis:{
        "value":5                                       // degrees C
    }

    onTemperature_hysteresisChanged: {
        console.log("in PI. Temp hysteresis changed to",temperature_hysteresis.value)
    }


    property var over_temperature_notification:{
        "port":"USB_C_port_1",                                // or any USB C port
        "enabled":"true",
        "state":"below",                                      // if the temperature crossed from under temperature to over temperature, "below" otherwise.
        "maximum_temperature":200                             // Temperature limit in degrees C
    }


    property var input_voltage_foldback:{
        "voltage":14.99487305,
        "min_voltage":15,
        "power":60,
        "enabled":true,
        "active":false
    }



    property var temperature_foldback:{
        "port":1,
        "temperature":33,
        "max_temperature":150,
        "power":60,      // 2-port = absolute power in watts, others = percentage of full port power
        "enabled":true,
        "active":false
    }


    property var usb_pd_maximum_power:{
        "port":1,                            // always 1
        "watts":60                           // 15, 30, 45, or 60
    }

    property var request_over_current_protection_notification:{
        "port":0,                           // 1, 2, ... maximum port number
        "current_limit":0,                  // amps - output current  exceeds this level
        "exceeds_limit":false,              // or false
        "action":"nothing",                 // "retry" or "shutdown" or "nothing"
        "enabled":false                     // or false
    }


    property var reset_notification :{
        "reset_status":true                   // only one value : true since only sent at the start
    }

    //when the platform sends a reset notification, the host must make a platformId call to initialize communication
    //and a Refresh() command to synchronize settings with the platform
    onReset_notificationChanged: {
        console.log("Requesting Refresh")
        platformInterface.refresh.send() //ask the platform for all the current values
    }



    property var maximum_board_power :{
        "watts":30          // 30-300
    }

    property var ac_power_supply_connection:{
        "state":"connected",  // or "disconnected"
        "power":200          // maximum supply power in watts
    }

    property var usb_power_notification:{
        "port":1,                               // 1,2,...maximum port id
        "device":"PD",                          // or "non-PD", or "none" if disconnected
        "advertised_maximum_current":3.00,      // amps - maximum available current for the negotiated voltage
        "negotiated_current":0.90,              // amps - current specified by the device, will be lower than "target_maximum_current"
        "negotiated_voltage":15.00,             // volts - advertised and negotiated voltage
        "input_voltage":13.51,                  // volts
        "output_voltage":5.01,                  // volts - actual measured output voltage
        "input_current":0.22,                   // amps
        "output_current":0.50,                  // amps
        "temperature":50,                       // degrees C
        "maximum_power":60                      // in watts
    }

    property var system_fault:{
        "state":"on",  // or "off"
        "reason":"<reason string>"           // over-temperature, input voltage
    }

    property var get_firmware_info: {
        "boatload": { },
        "application" : {
            "version" : "0.0.0",
            "data" : ""
        }
    }

    // --------------------------------------------------------------------------------------------
    //          Commands
    //--------------------------------------------------------------------------------------------

    property var requestfirmwareVersion:({
                                             "cmd":"get_firmware_info",
                                             "payload":{},
                                             send: function(){
                                                 CorePlatformInterface.send(this)
                                             }
                                         })

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

    property var platform_reset:({
                                     "cmd":"platform_reset",
                                     "payload":{
                                     },
                                     send: function(){
                                         CorePlatformInterface.send(this)
                                     }
                                 })

    property var set_protection_action:({
                                            "cmd":"set_protection_action",
                                            "payload":{
                                                "action":"retry"         // "retry" or "nothing"
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
                                                "cmd":"set_minimum_input_voltage",
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
                                               "cmd":"set_maximum_temperature",
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
                                                  "cmd":"set_input_voltage_foldback",
                                                  "payload":{
                                                      "enabled":false,  // or true
                                                      "voltage":0,    // in Volts
                                                      "power":45      // in Watts
                                                  },
                                                  update: function(enabled,voltage,watts){
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
                                                    "power":45      // percentage of full power
                                                },
                                                update: function(enabled,temperature,watts){
                                                    //update the variables for this action
                                                    this.set(enabled,temperature,watts)
                                                    CorePlatformInterface.send(this)
                                                },
                                                set: function(enabled,temperature,watts){
                                                    this.payload.enabled = enabled;
                                                    this.payload.temperature = temperature;
                                                    this.payload.power = watts;
                                                },
                                                send: function(){
                                                    CorePlatformInterface.send(this)
                                                },
                                                show: function(){
                                                    CorePlatformInterface.show(this)
                                                }
                                            })

    property var  set_temperature_hysteresis:({
                                                  "cmd":"set_temperature_hysteresis",
                                                  "payload":{
                                                      "value":0,    // in °C
                                                  },
                                                  update: function(degrees){
                                                      //update the variables for this action
                                                      this.set(degrees)
                                                      CorePlatformInterface.send(this)
                                                  },
                                                  set: function(inDegrees){
                                                      this.payload.value = inDegrees;
                                                  },
                                                  send: function(){
                                                      CorePlatformInterface.send(this)
                                                  },
                                                  show: function(){
                                                      CorePlatformInterface.show(this)
                                                  }
                                              })



    property var set_usb_pd_maximum_power : ({
                                                 "cmd":"set_usb_pd_maximum_power",
                                                 "payload":{
                                                     "port":0,       // always 1
                                                     "watts":0       // any value 0-60 will give 15w, 30w, 45w, or 60w
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

}
