import QtQuick 2.12
import QtQuick.Window 2.3

import tech.strata.sgwidgets 1.0
import QtQuick.Controls 2.2
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface



    // -------------------------------------------------------------------
    // Incoming Notification Messages
    //
    // Define and document incoming notification messages here.
    //
    // The property name *must* match the associated notification value.
    // Sets UI Control State when changed.


    //
    property var toggle_light_notification : {
        "value": "on",     // or "off"
    }

    property var toggle_door_notification : {
         "value": "open",     // or "closed"
    }


    //----------------------------------------------------------------------
    //
    //
    //      Commands
    //
    //----------------------------------------------------------------------


    property var toggle_light : ({
                                      "cmd" : "toggle_light",
                                      "payload": {
                                          "value":"on"
                                      },

                                      update: function (value) {
                                          this.set(avalue)
                                          this.send(this)
                                      },
                                      set: function (inValue) {
                                          this.payload.value = inValue;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })

    property var toggle_door : ({
                                      "cmd" : "toggle_door",
                                      "payload": {
                                          "value": "open",  // or "closed"
                                      },

                                      update: function (value) {
                                          this.set(value)
                                          this.send(this)
                                      },
                                      set: function (inValue) {
                                          this.payload.value = inValue;
                                      },
                                      send: function () { CorePlatformInterface.send(this) },
                                      show: function () { CorePlatformInterface.show(this) }
                                  })



    // -------------------------------------------------------------------
    // Listens to message notifications coming from CoreInterface.cpp
    // Forward messages to core_platform_interface.js to process

    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }


//    // DEBUG Window for testing motor vortex UI without a platform
//    Window {
//        id: debug
//        visible: true
//        width: 400
//        height: 400

//        Rectangle {
//            id: test1
//            width: parent.width
//            height: parent.height/4
//            color: "transparent"


//            SGSubmitInfoBox{
//                anchors.fill:parent
//                buttonText: "Send"
//                onAccepted: {
//                    console.log("text",text.toString())
//                    platformInterface.node.update(text.toString())
//                }
//            }
//        }
//        Button {
//            id:test2
//            anchors.top: test1.bottom
//            text: "get network notification"
//            onClicked: {
//                CorePlatformInterface.data_source_handler('{
//                                                "value":"network_notification",
//                                                "payload":{
//                                                         "nodes":  [
//                                                                    {"index":0,"available":1,"color":"#00ff00"},
//                                                                    {"index":1,"available":1,"color":"#ff00ff"} ,
//                                                                    {"index":2,"available":1,"color":"#ff4500"} ,
//                                                                    {"index":3,"available":1,"color":"#ffff00"} ,
//                                                                    {"index":4,"available":1,"color":"#7cfc00"},
//                                                                    {"index":5,"available":1,"color":"#00ff7f"},
//                                                                    {"index":6,"available":1,"color":"#ffc0cb"},
//                                                                    {"index":8,"available":1,"color":"#9370db"}

//                                                            ]
//                                                }

//                               } ')
//            }

//        }

//        Button {
//            id:test3
//            anchors.top: test2.bottom
//            checkable: true
//            checked:false
//            text: checked ? "alarm off" : "alarm!"

//            property bool alarmIsOn: checked;

//            onClicked: {
//                CorePlatformInterface.data_source_handler('{
//                   "value":"alarm_triggered",
//                    "payload":{
//                        "triggered": "'+alarmIsOn+'"
//                     }

//                     } ')
//            }

//        }



//    } //end of windows
}
