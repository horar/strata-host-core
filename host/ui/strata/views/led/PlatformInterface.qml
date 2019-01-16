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
    property var led_buck_power_notification : {
        "input_voltage": 0.0,
        "output_voltage":0.0,
        "input_current": 0.0,
        "output_current":0.0,
        "temperature": 0.0
    }


   property var set_pulse_colors_notification:{
        "enabled":true,                              // or 'false' if disabling the pulse LED
        "channel1_color":"FFFFFF",                   //a six digit hex value (R,G,B)
        "channel2_color":"FFFFFF"
    }

   property var set_linear_color_notification:{
        "enabled":true,                                // or 'false' if disabling the linear LED
        "color":"FFFFFF"                              //a six digit hex value (R,G,B)
    }

   property var set_buck_intensity_notification:{
         "enabled":true,                             // or 'false' if disabling the buck LED
         "intensity":50                               //0-100%
    }


    property var set_boost_intensity_notification:{
               "enabled":true,                 // or 'false' if disabling the boost LED
                "intensity":50                  //0-100%
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

    property var set_pulse_colors:({
                "cmd":"set_pulse_colors",
                "payload":{
                    "enabled":true ,              // or 'false' if disabling the pulse LED
                    "channel1_color":"FFFFFF",      //a six digit hex value (R,G,B)
                    "channel2_color":"FFFFFF"
                     },
                update: function(enabled,color1,color2){
                    this.set(enabled,color1,color2)
                    CorePlatformInterface.send(this)
                },
                set: function(enabled,color1,color2){
                    this.payload.enabled = enabled;
                    this.payload.channel1_color = color1;
                    this.payload.channel2_color = color2;
                },
                send: function(){
                    CorePlatformInterface.send(this)
                },
                show: function(){
                    CorePlatformInterface.show(this)
                }
    })
    
    property var set_linear_color:({
               "cmd":"set_linear_color",
               "payload":{
                  "enabled":true,            // or 'false' if disabling the pulse LED
                  "color":"FFFFFF"          //a six digit hex value (R,G,B)
               },
                update: function(enabled,color){
                    this.set(enabled,color)
                    CorePlatformInterface.send(this)
                },
                set: function(enabled,color){
                    this.payload.enabled = enabled;
                    this.payload.color = color;
                },
                send: function(){
                    CorePlatformInterface.send(this)
                },
                show: function(){
                    CorePlatformInterface.show(this)
                }
    })

    property var set_buck_intensity :({
                "cmd":"set_buck_intensity",
                "payload":{
                    "enabled":true,            // or 'false' if disabling the pulse LED
                    "intensity":50            //between 0 and 100%
                 },
                 update: function(enabled,intensity){
                      this.set(enabled,intensity)
                      CorePlatformInterface.send(this)
                      },
                 set: function(enabled,intensity){
                      this.payload.enabled = enabled;
                     this.payload.intensity = intensity;
                      },
                 send: function(){
                       CorePlatformInterface.send(this)
                      },
                show: function(){
                      CorePlatformInterface.show(this)
                      }
    })

    property var  set_boost_intensity:({
                  "cmd":"set_boost_intensity",
                  "payload":{
                        "enabled":false,  // or true
                        "intensity":0,    //between 0 and 100%
                       },
                   update: function(enabled,intensity){
                        this.set(enabled,intensity)
                        CorePlatformInterface.send(this)
                        },
                   set: function(enabled,intensity){
                        this.payload.enabled = enabled;
                        this.payload.intensity = intensity;
                        },
                   send: function(){
                        CorePlatformInterface.send(this)
                        },
                   show: function(){
                        CorePlatformInterface.show(this)
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
