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
            else{   //color is going back to light grey
                nodeNumber.visible = false
                sensorValueText.text = ""        //clear the sensor text if we no longer have an active node
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

            property alias number: nodeNumber.text
            property alias sensorText: sensorValueText.text

//            onNumberChanged: {
//                nodeNumber.text = number
//            }

            onColorChanged: {x
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

            function resetBindings(){
                //the color is reset to grey by the drop area,which breaks the binding of the drag
                //color to the parent color. This manifests as a drag item that's grey if that node is
                //added later with a different color. Resetting the binding here to fix that.
                //console.log("resetting drag area bindings")
                color  = Qt.binding(function(){return parent.color})
                number = Qt.binding(function(){return nodeNumber.text})
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
                    console.log("drag area release called")
                    var theDropAction = dragObject.Drag.drop()
                    dragObject.resetLocation()              //reset the location of the drag object after it's dropped, regardless of where.
                    dragObject.resetBindings()
                }


   }    //mouse area
}       //drag object

        DropArea{
            id:targetDropArea
            width: 1.5*objectWidth;
            height: 2*objectHeight

            property bool acceptsDrops: {
                //only accept drops if the circle being dropped on is light grey
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
                    //send a signal from this object to communicate that a node has been moved
                    console.log("Node Activated with",meshObject.scene, meshObject.pairingModel, drag.source.number, drag.source.color)
                    meshObject.nodeActivated(meshObject.scene, meshObject.pairingModel, drag.source.number, drag.source.color)

                    //update the properties of the object that was dropped on
                    objectCircle.color = drag.source.color;
                    nodeNumber.text  = drag.source.number

                    //if this node is still showing sensor data
                    console.log("clearing sensor text")
                    drag.source.sensorText.text = ""
                    drag.source.number = ""
                    drag.source.color = "lightgrey"         //reset the dropped object's color to grey
                    text: qsTr("text")

                    //tell the firmware of the change
                    platformInterface.set_node_mode.update(pairingModel,parseInt(meshObject.nodeNumber),true)
                }
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

        Text{
            id:sensorValueText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: objectCircle.bottom
            anchors.topMargin: 5
            text:""
            font.pixelSize: 16
            visible:false

            property string ambientLight:""
            property string battery_vtg:""
            property string battery_lvl:""
            property string temperature:""
            property string signalStrength:""

            property var ambientLightValue: platformInterface.sensor_status
            onAmbientLightValueChanged: {

                if (platformInterface.sensor_status.uaddr == meshObject.nodeNumber){
                    if (platformInterface.sensor_status.sensor_type === "ambient_light"){
                        ambientLight = platformInterface.sensor_status.data
                        if (ambientLight !== "undefined")
                            sensorValueText.text = Math.round(ambientLight) + " lux";
                        else
                            sensorValueText.text = "";

                    }
                }
            }


            property var batteryValue: platformInterface.battery_status
            onBatteryValueChanged: {
                //console.log("node",nodeNumber, " received battery value change",platformInterface.battery_status.battery_voltage)
                //console.log("comparing ",platformInterface.battery_status.uaddr, "and",meshObject.nodeNumber);
                if (platformInterface.battery_status.uaddr == meshObject.nodeNumber){
                    //console.log("updating battery value for node", meshObject.nodeNumber);
                    battery_vtg = parseFloat(platformInterface.battery_status.battery_voltage)
                    battery_lvl = parseInt(platformInterface.battery_status.battery_level)
                    if (battery_vtg !== NaN || battery_lvl !== NaN)
                        sensorValueText.text = battery_lvl + " %\n" + battery_vtg + " V"
                    else
                        sensorValueText.text = "";

                }
            }

            property var temperatureValue: platformInterface.sensor_status
            onTemperatureValueChanged: {
                //console.log("node",meshObject.nodeNumber, " received temp value",platformInterface.sensor_status.data)
                if (platformInterface.sensor_status.uaddr == meshObject.nodeNumber){
                    if (platformInterface.sensor_status.sensor_type === "temperature"){
                        temperature = platformInterface.sensor_status.data
                        if (temperature !== "undefined")
                            sensorValueText.text = temperature + " °C";
                        else
                            sensorValueText.text = "";
                    }
                }
            }

            property var signalStrengthValue: platformInterface.sensor_status
            onSignalStrengthValueChanged: {
                if (platformInterface.sensor_status.uaddr == meshObject.nodeNumber){
                    if (platformInterface.sensor_status.sensor_type === "rssi"){
                        signalStrength = platformInterface.sensor_status.data
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
