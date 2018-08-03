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
        "temperature": 0.0,
        "maximum_power":0.0
    }



    // @notification usb_pd_port_connect
    // @description: sent when a device is connected or disconnected
    //
    property var usb_pd_port_connect : {
        "port_id": "unknown",
        "connection_state":"unknown"
    }
//    onUsb_pd_port_connectChanged: {
//        console.log("usb_pd_port_connect changed. port_id=",usb_pd_port_connect.port_id," connection_state=",usb_pd_port_connect.connection_state);
//    }

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
    onFoldback_input_voltage_limiting_eventChanged: {
        console.log("input voltage event notification. values are ",foldback_input_voltage_limiting_refresh.foldback_minimum_voltage,
                                                                    foldback_input_voltage_limiting_refresh.foldback_minimum_voltage_power,
                                                                    foldback_input_voltage_limiting_refresh.input_voltage_foldback_enabled,
                                                                    foldback_input_voltage_limiting_refresh.input_voltage_foldback_active);
        }

    property var foldback_input_voltage_limiting_refresh:{
            "input_voltage":0,
            "foldback_minimum_voltage":0,
            "foldback_minimum_voltage_power":0,
            "input_voltage_foldback_enabled":false,
            "input_voltage_foldback_active":true
    }

    //keep the refresh and event notification properties in synch
    onFoldback_input_voltage_limiting_refreshChanged: {
        console.log("input voltage refresh notification. minimum voltage = ",foldback_input_voltage_limiting_refresh.foldback_minimum_voltage);

            //update the variables for foldback limiting
        foldback_input_voltage_limiting_event.input_voltage = foldback_input_voltage_limiting_refresh.input_voltage;
        foldback_input_voltage_limiting_event.foldback_minimum_voltage = foldback_input_voltage_limiting_refresh.foldback_minimum_voltage;
        foldback_input_voltage_limiting_event.foldback_minimum_voltage_power = foldback_input_voltage_limiting_refresh.foldback_minimum_voltage_power;
        foldback_input_voltage_limiting_event.input_voltage_foldback_enabled = foldback_input_voltage_limiting_refresh.input_voltage_foldback_enabled;
        foldback_input_voltage_limiting_event.input_voltage_foldback_active = foldback_input_voltage_limiting_refresh.input_voltage_foldback_active;
    }

    //consider the values held by this property to be the master ones, which will be current when needed for calling
    //the API to set the input temperature foldback
    property var foldback_temperature_limiting_event:{
            "port":1,
            "current_temperature":0,
            "foldback_maximum_temperature":0,
            "foldback_maximum_temperature_power":0,
            "temperature_foldback_enabled":true,
            "temperature_foldback_active":true,
            "maximum_power":0
    }

    property var foldback_temperature_limiting_refresh:{
            "port":1,
            "current_temperature":0,
            "foldback_maximum_temperature":0,
            "foldback_maximum_temperature_power":0,
            "temperature_foldback_enabled":true,
            "temperature_foldback_active":true,
            "maximum_power":0
    }
    //keep the refresh and event notification properties in synch
    onFoldback_temperature_limiting_refreshChanged: {
        //update the corresponding variables
        foldback_temperature_limiting_event.port = foldback_input_voltage_limiting_refresh.port;
        foldback_temperature_limiting_event.current_temperature = foldback_temperature_limiting_refresh.current_temperature;
        foldback_temperature_limiting_event.foldback_maximum_temperature = foldback_temperature_limiting_refresh.foldback_maximum_temperature;
        foldback_temperature_limiting_event.foldback_maximum_temperature_power = foldback_temperature_limiting_refresh.foldback_maximum_temperature_power;
        foldback_temperature_limiting_event.temperature_foldback_enabled = foldback_temperature_limiting_refresh.temperature_foldback_enabled;
        foldback_temperature_limiting_event.temperature_foldback_active = foldback_temperature_limiting_refresh.temperature_foldback_active;
        foldback_temperature_limiting_event.maximum_power = foldback_temperature_limiting_refresh.maximum_power;
    }

    // --------------------------------------------------------------------------------------------
    //          Commands
    //--------------------------------------------------------------------------------------------

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
                  "cmd":"request_temperature_foldback",
                  "payload":{
                        "enabled":false,  // or true
                        "temperature":0,    // in °C
                        "power":45      // in Watts
                       },
                   update: function(enabled,temperature,watts){
                       //update the variables for this action
                       foldback_temperature_limiting_event.foldback_maximum_temperature = temperature;
                       foldback_temperature_limiting_event.foldback_maximum_temperature_power = watts;
                       foldback_temperature_limiting_event.temperature_foldback_enabled = enabled;
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

    property var motor_speed : ({
                                    "cmd" : "speed_input",
                                    "payload": {
                                        "speed_target": 1500 // default value
                                    },

                                    // Update will set and send in one shot
                                    update: function (speed) {
                                        this.set(speed)
                                        CorePlatformInterface.send(this)
                                    },
                                    // Set can set single or multiple properties before sending to platform
                                    set: function (speed) {
                                        this.payload.speed_target = speed;
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
                                          "system_mode":" " // "automation" or "manual"
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
      set_drive_mode
    */
    property var set_drive_mode: ({
                                      "cmd" : "set_drive_mode",
                                      "payload": {
                                          "drive_mode" : " ",
                                      },

                                      // Update will set and send in one shot
                                      update: function (drive_mode) {
                                          this.set(drive_mode)
                                          CorePlatformInterface.send(this)
                                      },
                                      // Set can set single or multiple properties before sending to platform
                                      set: function (drive_mode) {
                                          this.payload.drive_mode = drive_mode;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }



                                  })
    /*
      Set Phase Angle
    */
    property var set_phase_angle: ({
                                       "cmd" : "set_phase_angle",
                                       "payload": {
                                           "phase_angle" : 0,
                                       },

                                       // Update will set and send in one shot
                                       update: function (phase_angle) {
                                           this.set(phase_angle)
                                           CorePlatformInterface.send(this)
                                       },
                                       // Set can set single or multiple properties before sending to platform
                                       set: function (phase_angle) {
                                           this.payload.phase_angle = phase_angle;
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }

                                   })


    /*
      Set Motor State
    */
    property var set_motor_on_off: ({
                                        "cmd" : "set_motor_on_off",
                                        "payload": {
                                            "enable": 0,
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

    /*
      Set Ramp Rate
    */
    property var set_ramp_rate: ({
                                     "cmd": "set_ramp_rate",
                                     "payload" : {
                                         "ramp_rate": ""
                                     },

                                     // Update will set and send in one shot
                                     update: function (ramp_rate) {
                                         this.set(ramp_rate)
                                         CorePlatformInterface.send(this)
                                     },
                                     // Set can set single or multiple properties before sending to platform
                                     set: function (ramp_rate) {
                                         this.payload.ramp_rate = ramp_rate;
                                         
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })

    /*
      Set Reset mcu
    */
    property var set_reset_mcu: ({
                                     "cmd": "reset_mcu",
                                     // Update will send in one shot
                                     update: function () {
                                         CorePlatformInterface.send(this)
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })

    /*
      Set LED Color Mixing
    */
    property var set_color_mixing : ({
                                         "cmd":"set_color_mixing",
                                             "payload":{
                                                         "color1": "red", // color can be "red"/"green"/"blue"
                                                         "color_value1": 128,// color_value varies from 0 to 255
                                                         "color2": "green", // color can be "red"/"green"/"blue"
                                                         "color_value2": 127, // color_value varies from 0 to 255
                                             },
                                         // Update will set and send in one shot
                                         update: function (color_1,color_value_1,color_2,color_value_2) {
                                             this.set(color_1,color_value_1,color_2,color_value_2)
                                             CorePlatformInterface.send(this)
                                         },
                                         // Set can set single or multiple properties before sending to platform
                                         set: function (color_1,color_value_1,color_2,color_value_2) {
                                             this.payload.color1 = color_1;
                                             this.payload.color_value1 = color_value_1;
                                             this.payload.color2 = color_2;
                                             this.payload.color_value2 = color_value_2;
                                         },
                                         send: function () { CorePlatformInterface.send(this) },
                                         show: function () { CorePlatformInterface.show(this) }
                                         
                                     })
                                    
    /*
      Set Single Color LED
    */
    
    property var set_single_color: ({
                                        "cmd":"set_single_color",
                                            "payload":{
                                                        "color": "red" ,// color can be "red"/"green"/"blue"
                                                        "color_value": 120, // color_value varies from 0 to 255 
                                            },
                                        // Update will set and send in one shot
                                        update: function (color,color_value) {
                                            this.set(color,color_value)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (color,color_value) {
                                            this.payload.color = color;
                                            this.payload.color_value = color_value;
                                            
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })
    /*
      set Blink0 Frequency
     */
    property var set_blink0_frequency: ({
                                        "cmd":"set_blink0_frequency",
                                            "payload":{
                                                        "blink0_frequency": 2
                                            },
                                        // Update will set and send in one shot
                                        update: function (blink_0_frequency) {
                                            this.set(blink_0_frequency)
                                            CorePlatformInterface.send(this)
                                        },
                                        set: function (blink_0_frequency) {
                                            this.payload.blink0_frequency = blink_0_frequency

                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    /*
      set_led_output_on_off
     */
    property var set_led_outputs_on_off:({
                                            "cmd":"set_led_outputs_on_off",
                                                "payload":{
                                                            "led_output": "white"       // "white" for turning all LEDs ON
                                                                                        // "off" to turn off all the LEDs.
                                                },
                                            update: function (led_output) {
                                                this.set(led_output)
                                                CorePlatformInterface.send(this)
                                            },
                                            set: function (led_output) {
                                                this.payload.led_output = led_output

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




    /*    // DEBUG - TODO: Faller - Remove before merging back to Dev
    Window {
        id: debug
        visible: true
        width: 200
        height: 200

        // This button sends 2 notifications in 1 JSON, future possible implementation
        Button {
            id: button1
            text: "send pi_stats and voltage"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                                        "input_voltage_notification": {
                                            "vin": '+ (Math.random()*5+10).toFixed(2) +'
                                        },
                                        "pi_stats": {
                                            "speed_target": 3216,
                                            "current_speed": '+ (Math.random()*2000+3000).toFixed(0) +',
                                            "error": -1104,
                                            "sum": -0.01,
                                            "duty_now": 0.67,
                                            "mode": "manual"
                                        }
                                    }')
            }
        }

        Button {
            id: button2
            anchors { top: button1.bottom }
            text: "send vin"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                    "value":"pi_stats",
                    "payload":{
                                "speed_target":3216,
                                "current_speed": '+ (Math.random()*2000+3000).toFixed(0) +',
                                "error":-1104,
                                "sum":-0.01,
                                "duty_now":0.67,
                                "mode":"manual"
                               }
                             }')
            }
        }
        Button {
            anchors { top: button2.bottom }
            text: "send"
            onClicked: {
                CorePlatformInterface.data_source_handler('{
                            "value":"input_voltage_notification",
                            "payload":{
                                     "vin":'+ (Math.random()*5+10).toFixed(2) +'
                            }
                    }
            ')
            }
        }
    }*/
}
