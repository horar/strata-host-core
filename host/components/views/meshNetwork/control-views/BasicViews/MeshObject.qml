import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id:meshObject
    width: 1.5*objectWidth; height: 2*objectHeight
    color:"transparent"
    //border.color:"black"

    property string scene:""                        //which view is this object part of (e.g. "office")

    property string pairingModel:""                 //what is the role of this object (e.g. "door")
    property alias nodeNumber: nodeNumber.text      //what number node corresponds to this object
    property alias objectColor: objectCircle.color  //what is the color of the corresponding physical node?
    property string displayName:""                  //the name of this node that's shown in the UI
    property string subName:""                      //appears below the paring model name (e.g. "relay")


    signal nodeActivated(string scene, string pairingModel, string nodeNumber, color nodeColor)

    Behavior on opacity{
        NumberAnimation {duration: 1000}
    }


    InfoPopover{
        id:infoBox
        height:325
        width:300
        x: objectWidth + 10
        y: parent.y
        title:"node " + meshObject.nodeNumber + " configuration"
        nodeNumber: meshObject.nodeNumber
        hasLEDModel:true
        hasBuzzerModel:true
        hasVibrationModel:true
        visible:false
    }

    Rectangle{
        id:objectCircle
        x: objectWidth/4; y: parent.height/4
        width: objectWidth; height: objectHeight
        radius:height/2
        color: "lightgrey"
        opacity: 0.5

        onColorChanged: {
            //console.log("changing objectCircle node",nodeName.text, "to",color,"drag object color is",dragObject.color)
            if (color != "#d3d3d3"){    //light grey
                nodeNumber.visible = true;
            }
            else{
                nodeNumber.visible = false
            }
        }

        Text{
            id:nodeNumber
            anchors.centerIn: parent
            text:""
            font.pixelSize: 14
            visible:false
        }

        Rectangle{
            id:dragObject
            //anchors.fill:parent
            height:parent.height
            width:parent.width
            color:parent.color
            opacity: Drag.active ? 1: 0
            radius: height/2

            property string number: nodeNumber.text

            onNumberChanged: {
                nodeNumber.text = number
            }

            onColorChanged: {
                //console.log("changing dragObject",nodeName.text,"color to",color)
                parent.color = color    //allows the drop area to change the color of the source
            }

            Drag.active: dragArea.drag.active
            Drag.hotSpot.x: width/2
            Drag.hotSpot.y: height/2

            property alias model:meshObject.pairingModel

            function resetLocation(){
                x = 0;
                y = 0;
            }

            MouseArea {
                id: dragArea
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                anchors.fill: parent


                drag.target: parent

                onPressed:{
                    //console.log("drag object pressed")
                    console.log("drag area for node",nodeName.text,"and color",dragObject.color,"pressed")
                }

                onEntered: {
                    //console.log("drag area entered")
                }
                onReleased: {
                    //console.log("drag area release called")
                    var theDropAction = dragObject.Drag.drop()
                }


   }    //mouse area
}       //drag object

        DropArea{
            id:targetDropArea
            width: 1.5*objectWidth;
            height: 2*objectHeight

            property bool acceptsDrops: {
                if (objectCircle.color == "#d3d3d3")    //light grey color
                    return true;
                  else
                    return false;
            }

            signal clearTargetsOfColor(color inColor, string name)

            onEntered:{
                //onsole.log("entered drop area")
                if (acceptsDrops){
                    objectCircle.border.color = "darkGrey"
                    objectCircle.border.width = 5
                }
            }

            onExited: {
                //console.log("exited drop area")
                objectCircle.border.color = "transparent"
                objectCircle.border.width = 1
            }

            onDropped: {
                console.log("item dropped with color",drag.source.color,"and number",drag.source.number)
                if (acceptsDrops){
                    dragObject.color = drag.source.color;   //set this object's color to the dropped one
                    drag.source.color = "lightgrey"         //reset the dropped object's color to grey
                    dragObject.number = drag.source.number
                    //send a signal from this object to communicate that a node has been moved
                    meshObject.nodeActivated(meshObject.scene, meshObject.pairingModel, dragObject.number, dragObject.color)
                    //tell the firmware of the change
                    platformInterface.set_node_mode(pairingModel,nodeNumber,false)
                }

                drag.source.resetLocation()             ///send the drag object back to where it was before being dragged
                objectCircle.border.color = "transparent"
                objectCircle.border.width = 1

            }
        }
    }





        Text{
            id:nodeName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:objectCircle.top
            anchors.bottomMargin: 15
            text:meshObject.displayName
            font.pixelSize: 15
        }

        Text{
            id:nodeSubName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:objectCircle.top
            anchors.bottomMargin: 0
            text:meshObject.subName
            font.pixelSize: 13
            color:"grey"
        }


        Rectangle{
            id:sensorValueTextOutline
            anchors.top: objectCircle.bottom
            anchors.topMargin: 5
            anchors.left: objectCircle.left
            width:objectCircle.width
            height:20
            color:"transparent"
            border.color:"grey"
            visible:false
        }

        Text{
            id:sensorValueText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: objectCircle.bottom
            anchors.topMargin: 5
            text:meshObject.nodeNumber
            font.pixelSize: 16
            visible:false



            property string ambientLight:""
            property string battery_vtg:""
            property string battery_lvl:""
            property string temperature:""
            property string signalStrength:""

            property var ambientLightValue: platformInterface.status_sensor
            onAmbientLightValueChanged: {

                if (platformInterface.status_sensor.uaddr == meshObject.nodeNumber){
                    if (platformInterface.status_sensor.sensor_type === "ambient_light"){
                        ambientLight = platformInterface.status_sensor.data
                        if (ambientLight !== "undefined")
                            sensorValueText.text = Math.round(ambientLight) + " lux";
                        else
                            sensorValueText.text = "";

                    }
                }
            }


            property var batteryValue: platformInterface.status_battery
            onBatteryValueChanged: {
                //console.log("node",nodeNumber, " received battery value change",platformInterface.status_battery.battery_voltage)
                //console.log("comparing ",platformInterface.status_battery.uaddr, "and",meshObject.nodeNumber);
                if (platformInterface.status_battery.uaddr == meshObject.nodeNumber){
                    console.log("updating battery value for node", meshObject.nodeNumber);
                    battery_vtg = parseFloat(platformInterface.status_battery.battery_voltage)
                    battery_lvl = parseInt(platformInterface.status_battery.battery_level)
                    if (battery_vtg !== NaN || battery_lvl !== NaN)
                        sensorValueText.text = battery_lvl + " %\n" + battery_vtg + " V"
                    else
                        sensorValueText.text = "";

                }
            }

            property var temperatureValue: platformInterface.status_sensor
            onTemperatureValueChanged: {
                if (platformInterface.status_sensor.uaddr == meshObject.nodeNumber){
                    if (platformInterface.status_sensor.sensor_type === "temperature"){
                        temperature = platformInterface.status_sensor.data
                        if (temperature !== "undefined")
                            sensorValueText.text = temperature + " °C";
                        else
                            sensorValueText.text = "";
                    }
                }
            }

            property var signalStrengthValue: platformInterface.status_sensor
            onSignalStrengthValueChanged: {
                if (platformInterface.status_sensor.uaddr == meshObject.nodeNumber){
                    if (platformInterface.status_sensor.sensor_type === "strata"){
                        //signal strength comes in as a value between 0 and 255, but the real values
                        //should be between -120 and 0, so subtract here to get displayed values
                        signalStrength = platformInterface.status_sensor.data -255
                        console.log("mesh object signal strength=",signalStrength)
                        if (signalStrength !== "undefined")
                            sensorValueText.text = signalStrength + " dBm";
                        else
                            sensorValueText.text = "";
                    }
                }
            }

            Connections{
                target: sensorRow
                onShowAmbientLightValue:{
                    sensorValueText.visible = true
                }

                onHideAmbientLightValue:{
                    sensorValueText.visible = false
                    sensorValueText.text = ""
                }

                onShowBatteryCharge:{
                    sensorValueText.visible = true
                }

                onHideBatteryCharge:{
                    sensorValueText.visible = false
                    sensorValueText.text = ""
                }

                onShowTemperature:{
                    sensorValueText.visible = true
                }

                onHideTemperature:{
                    sensorValueText.visible = false
                    sensorValueText.text = ""
                }

                onShowSignalStrength:{
                    sensorValueText.visible = true
                }

                onHideSignalStrength:{
                    sensorValueText.visible = false
                    sensorValueText.text = ""
                }

            }
        }













}
