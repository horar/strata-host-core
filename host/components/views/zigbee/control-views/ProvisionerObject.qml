import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id:provisionerObject
    width: 1.5*objectWidth; height: 2*objectHeight
    color:"transparent"
    //border.color:"black"

    property alias objectColor: provisionerCircle.color
    property alias nodeNumber: nodeNumber.text
    property var uaddr: 1

    Text{
        id:nodeName
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:provisionerCircle.top
        anchors.bottomMargin: 15
        text:"Strata"
        font.pixelSize: 15
        color:"black"
    }

    Text{
        id:nodeSubName
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:provisionerCircle.top
        anchors.bottomMargin: 0
        text:"(Provisioner)"
        font.pixelSize: 12
        color:"grey"
    }

    InfoPopover{
        id:infoBox
        height:325
        width:300
        x: objectWidth + 10
        y: parent.y
        title:"provisioner configuration"
        nodeNumber: "1"
        hasLEDModel:true
        hasBuzzerModel:true
        hasVibrationModel:true
        visible:false
    }

    Rectangle{
        id:provisionerCircle
        x: objectWidth/4;
        y: parent.height/4
        width: objectHeight; height: objectHeight
        radius:height/2
        color: "green"

        Behavior on opacity{
            NumberAnimation {duration: 1000}
        }

        Text{
            id:nodeNumber
            anchors.centerIn: parent
            text: "0"
            font.pixelSize: 12
            //color:"black"
        }

        Rectangle{
            id:dragObject
            //anchors.fill:parent
            height:parent.height
            width:parent.width
            color:parent.color
            opacity: Drag.active ? 1: 0
            radius: height/2

        }

        MouseArea {
            id: clickArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property int mouseButtonClicked: Qt.NoButton
            onPressed: {
                console.log("Button pressed",mouseButtonClicked);
                if (pressedButtons & Qt.LeftButton) {
                    mouseButtonClicked = Qt.LeftButton
                    console.log("Left button");
                } else if (pressedButtons & Qt.RightButton) {
                    mouseButtonClicked = Qt.RightButton
                    console.log("Right button");
                }
            }
            onClicked: {
                if(mouseButtonClicked & Qt.RightButton) {
                    console.log("Right button used");
                    infoBox.visible = true
                }
                else{
                    console.log("sending color command from node",1)
                    platformInterface.light_hsl_set.update(1,0,0,100)
                    //contextMenu.open()
                }
            }
        }
    }



    Rectangle{
        id:sensorValueTextOutline
        anchors.top: provisionerCircle.bottom
        anchors.topMargin: 5
        anchors.left: provisionerCircle.left
        width:provisionerCircle.width
        height:20
        color:"transparent"
        border.color:"grey"
        visible:false
    }

    Text{
        id:sensorValueText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: provisionerCircle.bottom
        anchors.topMargin: 5
        text:provisionerObject.nodeNumber
        font.pixelSize: 18
        visible:false



        property var ambientLight:""
        property var battery_vtg:""
        property var battery_lvl:""
        property var temperature:""
        property var signalStrength:""

        property var ambientLightValue: platformInterface.status_sensor
        onAmbientLightValueChanged: {
            if (platformInterface.status_sensor.uaddr == provisionerObject.uaddr){
                if (platformInterface.status_sensor.sensor_type === "ambient_light"){
                    ambientLight = platformInterface.status_sensor.data
                    if (ambientLight !== NaN)
                        sensorValueText.text = Math.round(ambientLight) + " lux";
                    else
                      sensorValueText.text = "";
                }
            }
        }

        property var batteryValue: platformInterface.status_battery
        onBatteryValueChanged: {
            console.log("provisioner received battery value change",platformInterface.status_battery.uaddr,platformInterface.status_battery.battery_voltage)
            if (platformInterface.status_battery.uaddr == provisionerObject.uaddr){
                console.log("changing batteryText for provisioner node")
                battery_vtg = parseFloat(platformInterface.status_battery.battery_voltage)
                battery_lvl = parseInt(platformInterface.status_battery.battery_level)
                if (battery_vtg !== NaN || battery_lvl !== NaN)
                    sensorValueText.text = battery_lvl + " %\n" + battery_vtg + " V";
                else
                  sensorValueText.text = "";
            }
        }

        property var temperatureValue: platformInterface.status_sensor
        onTemperatureValueChanged: {
            if (platformInterface.status_sensor.uaddr == provisionerObject.uaddr){
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
            if (platformInterface.status_sensor.uaddr == provisionerObject.uaddr){
                if (platformInterface.status_sensor.sensor_type === "strata"){
                    signalStrength = platformInterface.status_sensor.data - 255
                    console.log("signal strength=",signalStrength)
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
