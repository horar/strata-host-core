import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

// This is an example debug menu that shows how you can test your UI by injecting
// spoofed notifications to simulate a connected platform board.
//
// It is for development and should be removed from finalized UI's.

Rectangle {
    id: root
    height: 200
    width: 200
    border {
        width: 1
        color: "#fff"
    }

    Item {
        anchors {
            fill: root
            margins: 1
        }
        clip: true

        Column {
            id:rightColumn
            width: parent.width/2

            Rectangle {
                id: header
                color: "#eee"
                width: parent.width
                height: 40

                Text {
                    text: "Debug"
                    anchors {
                        verticalCenter: header.verticalCenter
                        left: header.left
                        leftMargin: 15
                    }
                }

            }


            Button {
                id: addNode
                text: "add node"

                property int clickCount: 1  //node 1 is always the provisioner, so we'll start with 2
                onClicked: {
                    var colors = ["#ff00ff", "#ff4500","#ffff00", "#7cfc00", "#00ff7f","#ffc0cb","#9370db"];
                    addNode.clickCount++;

                    CorePlatformInterface.data_source_handler('{
                                "value":"node_added",
                                "payload":{
                                    "index": '+clickCount+',
                                    "color": "'+colors[clickCount-1]+'"
                                }
                        }')

                }
            }

            Button {
                id: consoleMessage
                text: "console"

                onClicked: {

                    CorePlatformInterface.data_source_handler('{
                                "value":"msg_cli",
                                "payload":{
                                    "msg": "12345678901234567890123456789012345678901234567890123456789012345"
                                }
                        }')

                }
            }



            Button {
                id: tempSensor
                text: "temperature"

                onClicked: {

                    CorePlatformInterface.data_source_handler('{
                    "value":"sensor_status",
                    "payload":{
                         "uaddr": 2,
                         "sensor_type": "temperature",
                         "data":  100
                    }
                    }')

                }
            }
            Button {
                id: batterySensor
                text: "battery"

                onClicked: {

                    var sensorID = ((Math.random() *8) +1).toFixed(0) ;
                    var voltage = ((Math.random() *5)).toFixed(1) ;
                    var level = ((Math.random() *100)).toFixed(0) ;

                    CorePlatformInterface.data_source_handler('{
                    "value":"battery_status",
                    "payload":{
                        "uaddr":'+sensorID+',
                        "battery_level":'+level+',
                        "battery_voltage":'+voltage+',
                        "battery_state":"charging"
                    }
                    }')

                }
            }
        }

        Column{
            id:leftColumn
            anchors.left: rightColumn.right
            anchors.top:rightColumn.top
            width: parent.width/2

            Rectangle {
                id: buttonheader
                color: "#eee"
                width: parent.width
                height: 40

                Button {
                    text: "X"
                    height: 30
                    width: height
                    onClicked: root.visible = false
                    anchors {
                        right: buttonheader.right
                    }
                }
            }

//            Button {
//                            id: network
//                            text: "network"

//                            onClicked: {

//                                CorePlatformInterface.data_source_handler('{
//                                "value":"network_notification",
//                                "payload":{
//                                    "nodes":[{
//                                        "index":0,
//                                        "ready":0,
//                                        "color":"#0000FF"
//                                        },
//                                        {
//                                        "index":1,
//                                        "ready":1,
//                                        "color":"#00FF00"
//                                        },
//                                        {
//                                        "index":2,
//                                        "ready":0,
//                                        "color":"#FF00FF"
//                                        },
//                                        {"index":3,
//                                        "ready":0,
//                                        "color":"#00FFFF"
//                                        },{
//                                        "index":4,
//                                        "ready":0,
//                                        "color":"#7BFF00"
//                                        },{
//                                        "index":5,
//                                        "ready":0,
//                                        "color":"#FFFF00"
//                                        },{
//                                        "index":6,
//                                        "ready":0,
//                                        "color":"#7B00FF"
//                                        },{
//                                        "index":7,
//                                        "ready":0,
//                                        "color":"#00FF52"
//                                        },{
//                                        "index":8,
//                                        "ready":0,
//                                        "color":"#FF5200"
//                                        },{
//                                        "index":9,
//                                        "ready":0,
//                                        "color":"#FFFFFF"
//                                        }]
//                                    }
//                                }')

//                            }
//                        }

            Button {
                id: network
                text: "network"

                onClicked: {

                    CorePlatformInterface.data_source_handler('{
                    "value":"network_notification",
                    "payload":{
                        "nodes":[{
                              "index": 0,
                              "ready": 0,
                              "color": "#000000"
                              },{
                              "index": 1,
                              "ready": 1,
                              "color": "#00FF00"
                              },
                              {
                              "index": 2,
                              "ready": '+ ((Math.random() *2)-1).toFixed(0) +',
                              "color": "#000088"
                              },
                              {
                              "index": 3,
                              "ready": '+ ((Math.random() *2)-1).toFixed(0) +',
                              "color": "#0000ff"
                              },
                              {
                              "index": 4,
                              "ready": '+ ((Math.random() *2)-1).toFixed(0) +',
                              "color": "#008800"
                              },
                              {
                              "index": 5,
                              "ready": '+ ((Math.random() *2)-1).toFixed(0) +',
                              "color": "#008888"
                              },
                              {
                              "index": 6,
                              "ready": '+ ((Math.random() *2)-1).toFixed(0) +',
                              "color": "#0088ff"
                              },
                              {
                              "index": 7,
                              "ready": '+ ((Math.random() *2)-1).toFixed(0) +',
                              "color": "#00ffff"
                              },
                              {
                              "index": 8,
                              "ready": '+ ((Math.random() *2)-1).toFixed(0) +',
                              "color": "#880000"
                              }]
                            }
                    }')

                }
            }

            Button {
                id: networkPlusDoor
                text: "network+door"

                onClicked: {

                    CorePlatformInterface.data_source_handler('{
                                            "value":"network_notification",
                                            "payload":{
                                                "nodes":[{
                                                    "index":0,
                                                    "ready":0,
                                                    "color":"#0000FF"
                                                    },
                                                    {
                                                    "index":1,
                                                    "ready":1,
                                                    "color":"#00FF00"
                                                    },
                                                    {
                                                    "index":2,
                                                    "ready":1,
                                                    "color":"#FF00FF"
                                                    },
                                                    {"index":3,
                                                    "ready":0,
                                                    "color":"#00FFFF"
                                                    },{
                                                    "index":4,
                                                    "ready":0,
                                                    "color":"#7BFF00"
                                                    },{
                                                    "index":5,
                                                    "ready":0,
                                                    "color":"#FFFF00"
                                                    },{
                                                    "index":6,
                                                    "ready":0,
                                                    "color":"#7B00FF"
                                                    },{
                                                    "index":7,
                                                    "ready":0,
                                                    "color":"#00FF52"
                                                    },{
                                                    "index":8,
                                                    "ready":0,
                                                    "color":"#FF5200"
                                                    },{
                                                    "index":9,
                                                    "ready":0,
                                                    "color":"#FFFFFF"
                                                    }]
                                                }
                                            }')

                }
            }


            Button {
                id: removeNode2
                text: "remove door"


                onClicked: {

                    CorePlatformInterface.data_source_handler('{
                    "value":"node_removed",
                    "payload":{
                        "index":2
                        }
                    }')


                }
            }

                        Button {
                            id: temperature
                            text: "temperature"

                            onClicked: {

                                CorePlatformInterface.data_source_handler('{
                                "value":"sensor_status",
                                "payload":{
                                    "uaddr":2,
                                    "sensor_type":"temperature",
                                    "data": '+ ((Math.random() * 200).toFixed(0)) +'
                                    }
                                }')
                                }
                        }


//            Button {
//                id: rssi
//                text: "rssi"

//                onClicked: {

//                    var sensorID = ((Math.random() *8) +1).toFixed(0) ;
//                    var rssiValue = ((Math.random() *-70) -30).toFixed(0) ;

//                    CorePlatformInterface.data_source_handler('{
//                    "value":"sensor_status",
//                    "payload":{
//                        "uaddr":'+sensorID+',
//                        "sensor_type":"rssi",
//                        "data": "'+rssiValue+'"
//                    }
//                    }')

//                }
//            }

//            Button {
//                id: windowShade
//                text: "shade"

//                property var state: "open";

//                onClicked: {

//                    CorePlatformInterface.data_source_handler('{
//                    "value":"window_shade",
//                    "payload":{
//                        "value":"'+state+'"
//                        }
//                    }')

//                    if (state === "open"){
//                        console.log("closing window")
//                        state = "closed"
//                    }
//                      else{
//                        console.log("opening window")
//                        state = "open"
//                    }

//                }
//            }

            Button {
                id: smarthomeDoor
                text: "door"

                property var state: "open";

                onClicked: {
                    CorePlatformInterface.data_source_handler('{
                    "value":"smarthome_door",
                    "payload":{
                        "value":"'+state+'"
                        }
                    }')

                    if (state === "open")
                        state = "closed"
                      else
                        state = "open"
                }
            }
        }



        //            Button {
        //                id: motorRunningFalse
        //                text: "Send motor_running_notification, 'running': false"
        //                onClicked: {
        //                    CorePlatformInterface.data_source_handler('{
        //                                "value":"motor_running_notification",
        //                                "payload":{
        //                                         "running": false
        //                                }
        //                        }')
        //                }
        //            }

        //            Button {
        //                id: motorSpeed
        //                text: "Send motor_speed_notification, 'speed': random"
        //                onClicked: {
        //                    CorePlatformInterface.data_source_handler('{
        //                                "value":"motor_speed_notification",
        //                                "payload":{
        //                                         "speed": ' + (Math.random()*100).toFixed(2) + '
        //                                }
        //                        }')
        //                }
        //            }

    }

    Rectangle {
        id: shadow
        anchors.fill: root
        visible: false
    }

    DropShadow {
        anchors.fill: shadow
        radius: 15.0
        samples: 30
        source: shadow
        z: -1
    }
}
