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


    property var platform_info_notification:{
          "firmware_ver":"0.0.0",           // firmware version string
          "frequency":915.2                 // frequency in MHz
           }


    property var toggle_receive_notification:{
               "enabled":true,                 // or 'false'
    }

    property var receive_notification : {
        "sensor_id":0,                       //1-4
        "sensor_type": "multi_soil",
        "rssi":0,                   		// -dBm
        "packet_error_rate":0,              // PER %
        "data_packet":"",                    // string representing received data
        "bme680":{                        //actually a subgroup within payload
            "temperature":0,                    //in °C
            "pressure": 0,                      //in hpa
            "humidity": 0,                      //in %
            "gas":0,                        //??
            },
        "stemma":{
            "soil":0,                       //200-2000
            "temperature":0                 //°C
        }
    }

    onReceive_notificationChanged: {
        //console.log("new data received");
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

    property var toggle_receive:({
                 "cmd":"toggle_receive",
                 "payload":{
                    "enabled":true               // or 'false' if disabling
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
            //if (!payload.includes("power_notification")){
                console.log("**** Notification",payload);
            //}
            CorePlatformInterface.data_source_handler(payload)
        }
    }

        // DEBUG - TODO: Remove before merging back to Dev
    Window {
        id: debug
        visible: true
        width: 225
        height: 200

        Button {
            id: leftButton1
            text: "telemetry"
            onClicked: {
                var sensorID = ((Math.random() *3) +1).toFixed(0) ;
                var rssiValue = ((Math.random() *-70) -60).toFixed(0) ;
                var packetErrorRate = (Math.random()*10).toFixed(0) ;
                var temperature = (Math.random()*100).toFixed(0) ;
                var pressure = (Math.random()*100).toFixed(0) ;
                var humidity = (Math.random()*100).toFixed(0) ;
                var soil = (Math.random()*100).toFixed(0) ;
//                console.log("receiving: sensorID=",sensorID,
//                                          " rssi=",rssiValue,
//                                          " packetErrorRate=",packetErrorRate,
//                                          "temperature=",temperature,
//                                          "pressure=",pressure,
//                                          "humidity=",humidity,
//                                          "soil=",soil);
                CorePlatformInterface.data_source_handler('{
                                   "value":"receive_notification",
                                   "payload": {
                                         "sensor_id":'+sensorID+',
                                         "sensor_type": "multi_soil",
                                         "rssi":'+rssiValue+',
                                         "packet_error_rate":'+packetErrorRate+',
                                         "data_packet":"DEADBEEFFACEFEED",
                                        "bme680":{
                                            "temperature":'+temperature+',
                                            "pressure": '+pressure+',
                                            "humidity": '+humidity+',
                                            "gas":0
                                            },

                                        "stemma":{
                                            "soil":'+soil+',
                                            "temperature":'+temperature+'
                                            }
                                        }
                                    }')
            } //on clicked
        } //button

    } //window


}
