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
    //
    property var power_notification : {
        "buck_input_voltage": 0.0,
        "buck_output_voltage":0.0,
        "buck_input_current": 0.0,
        "buck_output_current":0.0,
        "buck_temperature": 0.0,
        "boost_input_voltage": 0.0,
        "boost_output_voltage":0.0
    }

    property var enable_power_telemetry_notification:{
          "enabled":true                             // or 'false' if disabling periodic notifications
           }


   property var set_pulse_colors_notification:{
        "enabled":true,                              // or 'false' if disabling the pulse LED
        "channel1_color":"46B900",                   //a six digit hex value (R,G,B)
        "channel2_color":"3A00C5"
    }

   property var set_linear_color_notification:{
        "enabled":true,                                // or 'false' if disabling the linear LED
        "color":"008888"                              //a six digit hex value (R,G,B)
    }

   property var set_buck_intensity_notification:{
         "enabled":true,                             // or 'false' if disabling the buck LED
         "intensity":1                               //0-100%
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
                set: function(inEnabled,inColor1,inColor2){
                    this.payload.enabled = inEnabled;
                    this.payload.channel1_color = inColor1;
                    this.payload.channel2_color = inColor2;
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
