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

    signal alarmTriggered()
    signal toggleWindow()
    signal toggleDoor()
    signal setRoomColor(string inColor)

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

        property bool relayEnabled: false   //relay is turned on when user drags to solar panel
        property bool dimmerEnabled: true
        property int counter : 0
        property bool highPowerMode: true
        property bool doorOpen:true
        property var roomColors:["blue","green","purple","orange","black","white"]
        property int currentRoomColor:0
        property color theColor: roomColors[currentRoomColor];

        onClicked:{

            var theHue = Math.round(color.hslHue*360)
            var theSaturation = Math.round(color.hslSaturation*100)
            var theLightness = Math.round(color.hslLightness*100)
            console.log("current color is",theHue,theSaturation,theLightness)

            console.log("sending click with value",nodeType)
            if (nodeType == "relay"){
                //enable/disable relay mode
                console.log("sending solar_panel")
                if (root.nodeNumber != "")
                    platformInterface.set_node_mode.update(nodeType,root.nodeNumber,relayEnabled)
                relayEnabled = !relayEnabled;
            }

            else if (nodeType == "high_power"){
                console.log("sending lowPower comamnd with value",highPowerMode,nodeType.root)
                platformInterface.set_node_mode.update(nodeType,root.nodeNumber,highPowerMode)
                highPowerMode = !highPowerMode
            }


            else if (nodeType === "door"){
                platformInterface.set_node_mode.update("alarm",65535,true)

                 //broadcast the alarm triggered event
                 root.alarmTriggered();
            }
            else if (nodeType === "hvac"){
                platformInterface.light_hsl_set.update(65535,theHue, theSaturation, theLightness)

            }
            else if (nodeType == "security_camera"){
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
            else if (nodeType == "robotic_arm"){
                if (root.nodeNumber == "")
                    platformInterface.light_hsl_set.update(65535,0, 0, 0)
                   else
                    platformInterface.light_hsl_set.update(65535,theHue, theSaturation, theLightness)
            }

            //smarthome nodes
            else if (nodeType == "window_shade"){
                //tell the main image to switch
                root.toggleWindow()

            }
            else if (nodeType == "smarthome_lights"){
                var theHomeHue = Math.round(theColor.hslHue*360);
                var theHomeSaturation = Math.round(theColor.hslSaturation*100);
                var theHomeLightness = Math.round(theColor.hslLightness*100);
                //special case for black, as Qt thinks the hue should be -1
                if (theHomeLightness === 0){
                    theHomeHue = 0;
                    theHomeSaturation = 0;
                    }
                //special case for white
                if (theHomeLightness === 100){
                    theHomeHue = 0;
                    theHomeSaturation = 0;
                    }
                //special case for orange, because the straight HSL conversion of orange can't be
                //shown well on the node LEDs.
                if (theColor == "orange"){
                    theHomeHue = 5;
                    theHomeSaturation = 100;
                    theHomeLightness = 50;
                }
                console.log("current smarthome color is",theHomeHue,theHomeSaturation,theHomeLightness)
                platformInterface.light_hsl_set.update(65535,theHomeHue,theHomeSaturation,theHomeLightness);

                //tell the room image that the color has changed
                root.setRoomColor(roomColors[currentRoomColor])

                currentRoomColor++;
                if (currentRoomColor == roomColors.length)
                    currentRoomColor = 0;
            }
            else if (nodeType == "smarthome_door"){
                //tell the main image to change the state of the door
                root.toggleDoor()
            }

        }//on clicked
    } //MouseArea

}

