import QtQuick 2.0
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Rectangle {
    id:root
    x: 10; y: 10
    width: nodeWidth; height: nodeHeight
    radius:height/2
    color: "transparent"
    border.color: "white"
    border.width: 5

    property string scene:""
    property string nodeType: "light"
    property string nodeNumber: ""

    Text{
        id:nodeNumberText
        anchors.centerIn: parent
        text: root.nodeNumber
        font.pixelSize: 12
        color:"white"
        visible:root.color == "transparent" ? false : true
    }

    //the mouse area handles clicks in the object.
    //these clicks send messages to perform actions on the physical nodes
    MouseArea{
        id:dropAreaMouseArea
        anchors.fill:parent

        property bool relayEnabled: true
        property bool dimmerEnabled: true
        property int counter : 0
        property bool highPowerMode: true
        property bool windowOpen:true
        property bool doorOpen:true
        property var roomColors:["blue","green","purple","orange","black","white"]
        property int currentRoomColor:0

        onClicked:{

            var theHue = Math.round(color.hslHue*100)
            var theSaturation = Math.round(color.hslSaturation*100)
            var theLightness = Math.round(color.hslLightness*100)

            console.log("sending click with value",nodeType)
            if (nodeType == "relay"){
                //enable/disable relay mode
                console.log("sending solar_panel")
                if (root.nodeNumber != "")
                    platformInterface.set_node_mode.update(nodeType,root.nodeNumber,relayEnabled)
                relayEnabled = !relayEnabled;
            }

            else if (nodeType == "high_power"){
                console.log("sending lowPower comamnd with value",highPowerMode)
                platformInterface.sensor_set.update(nodeType,root.nodeNumber,highPowerMode)
                highPowerMode = !highPowerMode
            }


            else if (nodeType === "door"){
                //platformInterface.sensor_set.update(65535,"strata",4)
                platformInterface.set_node_mode.update(nodeType,65535,true)
                //the firmware should send a notification to let other parts of the UI know that the alarm is on
                //but it is not. In the meantime, I'll inject the JSON here
                CorePlatformInterface.data_source_handler('{
                   "value":"alarm_triggered",
                    "payload":{
                        "triggered": "true"
                     }

                     } ')
            }
            else if (nodeType === "hvac"){
                platformInterface.light_hsl_set.update(65535,theHue, theSaturation, theLightness)

            }
            else if (nodeType == "security"){
                if (root.nodeNumber == "")
                    platformInterface.light_hsl_set.update(65535,0, 0, 0)
                   else
                    platformInterface.light_hsl_set.update(65535,theHue, theSaturation, theLightness)
            }
            else if (nodeType == "doorbell"){
                if (root.nodeNumber != "")
                    platformInterface.set_node_mode.update("buzzer",root.nodeNumber,true)
            }
            else if (nodeType == "unknown"){
                if (root.nodeNumber == "")
                    platformInterface.light_hsl_set.update(65535,0, 0, 0)
                   else
                    platformInterface.light_hsl_set.update(65535,theHue, theSaturation, theLightness)
            }
            else if (nodeType == "dimmer"){
                //enable/disable dimmer mode
                console.log("sending dimmer mode",nodeType,root.nodeNumber,dimmerEnabled);
                platformInterface.set_node_mode.update(nodeType,root.nodeNumber,dimmerEnabled)
                dimmerEnabled = ! dimmerEnabled;
            }

            //smarthome nodes
            else if (nodeType == "window_shade"){
                var theWindow = "closed";
                if (windowOpen)
                    theWindow = "open"
                  else
                    theWindow = "closed"
                //platformInterface.toggle_window_shade.update(theWindow)
                windowOpen = !windowOpen;
                //this notification should come from the firmware, but doesn't
                CorePlatformInterface.data_source_handler('{
                   "value":"window_shade",
                    "payload":{
                        "value": "'+theWindow+'"
                     }

                     } ')

            }
            else if (nodeType == "smarthome_lights"){
                platformInterface.set_room_color.update(roomColors[currentRoomColor])
                var theHomeHue = Math.round(roomColors[currentRoomColor].hslHue*100);
                var theHomeSaturdation = Math.round(roomColors[currentRoomColor].hslSaturation*100);
                var theHomeLightness = Math.round(roomColors[currentRoomColor].hslLightness*100);
                platformInterface.light_hsl_set.update(65535,theHomeHue,theHomeSaturdation,theHomeLightness);
                //this should be handled by the firmware, but isn't
                CorePlatformInterface.data_source_handler('{
                   "value":"room_color_notification",
                    "payload":{
                        "color": "'+roomColors[currentRoomColor]+'"
                     }

                     } ')
                currentRoomColor++;
                if (currentRoomColor == roomColors.length)
                    currentRoomColor = 0;
            }
            else if (nodeType == "smarthome_door"){
                var theDoor;
                if (doorOpen)
                    theDoor = "open"
                  else
                    theDoor = "closed"
                //platformInterface.toggle_door.update(theDoor)
                doorOpen = !doorOpen;
                //this should be handled by the firmware, but isn't
                CorePlatformInterface.data_source_handler('{
                   "value":"smarthome_door",
                    "payload":{
                        "value": "'+theDoor+'"
                     }

                     } ')
            }

        }//on clicked
    } //MouseArea

}

