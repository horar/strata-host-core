import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id:provisionerObject
    width: 1.5*objectWidth; height: 2*objectHeight
    color:"transparent"
    //border.color:"black"

    property alias objectColor: provisionerCircle.color
    property alias nodeNumber: nodeNumber.text
    property var uaddr: 0

    Text{
        id:nodeName
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:provisionerCircle.top
        anchors.bottomMargin: 15
        text:"strata"
        font.pixelSize: 18
        color:"black"
    }

    Text{
        id:nodeSubName
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:provisionerCircle.top
        anchors.bottomMargin: 0
        text:"provisioner"
        font.pixelSize: 12
        color:"grey"
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



        property var ambientLight
        property var battery
        property var temperature
        property var signalStrength

        property var ambientLightValue: platformInterface.status_sensor
        onAmbientLightValueChanged: {
            if (platformInterface.status_sensor.uaddr == provisionerObject.uaddr){
                if (platformInterface.status_sensor.sensor_type === "ambient_light"){
                    ambientLight = platformInterface.status_sensor.data
                    sensorValueText.text = Math.round(ambientLight) + " lux";
                }
            }
        }

        property var batteryValue: platformInterface.status_battery
        onBatteryValueChanged: {
            console.log("provisioner received battery value change",platformInterface.status_battery.uaddr,platformInterface.status_battery.battery_voltage)
            if (platformInterface.status_battery.uaddr == provisionerObject.uaddr){
                console.log("changing batteryText for provisioner node")
                battery = parseFloat(platformInterface.status_battery.battery_voltage)
                sensorValueText.text = battery.toFixed(1) + " V";
            }
        }

        property var temperatureValue: platformInterface.status_sensor
        onTemperatureValueChanged: {
            if (platformInterface.status_sensor.uaddr == provisionerObject.uaddr){
                if (platformInterface.status_sensor.sensor_type === "temperature"){
                    temperature = platformInterface.status_sensor.data
                    sensorValueText.text = temperature + " °C";
                }
            }
        }

        property var signalStrengthValue: platformInterface.status_sensor
        onSignalStrengthValueChanged: {
            if (platformInterface.status_sensor.uaddr == provisionerObject.uaddr){
                if (platformInterface.status_sensor.sensor_type === "strata"){
                    signalStrength = platformInterface.status_sensor.data
                    sensorValueText.text = signalStrength + " dBm";
                }
            }
        }

        Connections{
            target: sensorRow
            onShowAmbientLightValue:{
                if (sensorValueText.ambientLightText != ""){
                    console.log("light sensor value is",sensorValueText.ambientLightText)
                    sensorValueText.visible = true
                    sensorValueText.text = Math.round(sensorValueText.ambientLightText) + " lux";
                    }
                  else{
                    sensorValueText.visible = true
                    sensorValueText.text = ""
                }
            }
            onHideAmbientLightValue:{
                sensorValueText.visible = false
            }
            onShowBatteryCharge:{
                console.log("showing battery level of",sensorValueText.batteryText)
                if (sensorValueText.batteryText != ""){
                    sensorValueText.visible = true
                    sensorValueText.text = Math.round(sensorValueText.batteryText) + " V";
                    }
                else{
                  sensorValueText.visible = true
                  sensorValueText.text = ""
              }
            }

            onHideBatteryCharge:{
                sensorValueText.visible = false
            }

            onShowTemperature:{
                if (sensorValueText.temperatureText != ""){
                    sensorValueText.visible = true
                    sensorValueText.text = sensorValueText.temperatureText + " °C";
                    }
                //if we don't have a value for this node, don't show any text
                else{
                  sensorValueText.visible = true
                  sensorValueText.text = ""
              }
            }

            onHideTemperature:{
                sensorValueText.visible = false
            }


            onShowSignalStrength:{
                 if (sensorValueText.signalStrengthText != ""){
                    sensorValueText.visible = true
                    sensorValueText.text = sensorValueText.signalStrengthText + " dBm";
                 }
                else{
                  sensorValueText.visible = true
                  sensorValueText.text = ""
              }
            }

            onHideSignalStrength:{
                //wifiImage.visible = false
            }

        }
    }



}
