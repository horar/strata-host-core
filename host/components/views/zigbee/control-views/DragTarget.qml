import QtQuick 2.0
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

DropArea{
    id:targetDropArea
    x: 10; y: 10
    width: nodeWidth; height: nodeHeight

    property string nodeType: "light"
    property string nodeNumber: "0"
    property color savedColor: "transparent"
    property alias radius: dropAreaRectangle.radius
    property alias color: dropAreaRectangle.color
    property bool acceptsDrops: true

    signal clearTargetsOfColor(color inColor, string name)

    onEntered:{
        console.log("entered drop area")
        savedColor = dropAreaRectangle.color
        if (acceptsDrops){
            dropAreaRectangle.color = drag.source.color;
        }
        infoTextRect.visible = true;
    }

    onExited: {
        console.log("exited drop area")
        dropAreaRectangle.color = savedColor
        infoTextRect.visible = false;
    }

    onDropped: {
        console.log("item dropped with color",drag.source.color)
        if (acceptsDrops){
            dropAreaRectangle.color = drag.source.color;
            drag.source.model = nodeType;
            savedColor = dropAreaRectangle.color
        }
        infoTextRect.visible = false;

        //signal to tell other drop targets using the same color to clearConnectionsButton
        clearTargetsOfColor(dropAreaRectangle.color, objectName);
    }

    Rectangle {
        id:dropAreaRectangle
        anchors.fill:parent
        radius:height/2
        color: "transparent"
        border.color:{
            return "white"
        }
        border.width: 5

        Text{
            id:nodeNumber
            anchors.centerIn: parent
            text: targetDropArea.nodeNumber
            font.pixelSize: 12
            color:"white"
        }

    }

    MouseArea{
        id:dropAreaMouseArea
        anchors.fill:parent

        property bool relayEnabled: true
        property bool dimmerEnabled: true
        property int counter : 0
        property int lowPowerMode: 32    //0 is high power 32 is low power

        onClicked:{
            console.log("sending click with value",nodeType)
            if (nodeType == "voltage"){
                //enable/disable relay mode
               platformInterface.sensor_set.update(7,"strata",relayEnabled)
               relayEnabled = !relayEnabled;
            }

            else if (nodeType == "provisioner"){
                console.log("sending lowPower comamnd with value",lowPowerMode)
                platformInterface.sensor_set.update(1,"strata",lowPowerMode)
                if (lowPowerMode === 0)
                    lowPowerMode = 32;
                else
                    lowPowerMode = 0;
            }


            else if (nodeType === "alarm"){
               platformInterface.sensor_set.update(65535,"strata",4)
                //the firmware should send a notification to let other parts of the UI know that the alarm is on
                //but it is not. In the meantime, I'll inject the JSON here
                CorePlatformInterface.data_source_handler('{
                   "value":"alarm_triggered",
                    "payload":{
                        "triggered": "true"
                     }

                     } ')
            }
            else if (nodeType === "remote"){
               counter = counter + 1;
               platformInterface.light_hsl_set.update(8,(counter * 100),100,50)
               if(counter === 3) {
                   counter = 0
               }

//                 platformInterface.light_hsl_set.update(8,300,100,50)
            }
            else if (nodeType == "security"){
               platformInterface.light_hsl_set.update(65535,81,100,50)
            }
            else if (nodeType == "doorbell"){
               platformInterface.light_hsl_set.update(65535,19,100,50)
            }
            else if (nodeType == "unknown"){
               platformInterface.light_hsl_set.update(65535,91,100,50)
            }
            else if (nodeType == "switch"){
                //enable/disable dimmer mode
               if (dimmerEnabled){
                    platformInterface.sensor_set.update(2,"magnetic_detection",16)
                    dimmerEnabled = ! dimmerEnabled;
                    }
                 else{
                   platformInterface.sensor_set.update(2,"magnetic_detection",0)
                   dimmerEnabled = ! dimmerEnabled;
               }
            }
        }
    }




    Rectangle{
        id: infoTextRect
//        height: 50
//        width:175
//        anchors.top: dropAreaRectangle.top
//        anchors.left: dropAreaRectangle.right
//        anchors.leftMargin: 10
        anchors.left: infoText.left
        anchors.leftMargin: -10
        anchors.right:infoText.right
        anchors.rightMargin:-10
        anchors.top: infoText.top
        anchors.topMargin: -5
        anchors.bottom:infoText.bottom
        anchors.bottomMargin: -10
        color:"white"
        opacity:.4
        radius:7
        visible: false
    }

    Text{
        id:infoText
        height:50
        //width:100
        text: targetDropArea.nodeType
        font.pixelSize: 48
        //fontSizeMode: Text.Fit
        //anchors.centerIn: infoTextRect
        anchors.top: dropAreaRectangle.top
        anchors.left: dropAreaRectangle.right
        anchors.leftMargin: 10
        visible: infoTextRect.visible
    }


}

