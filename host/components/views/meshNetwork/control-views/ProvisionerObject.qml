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



        property var ambientLight:""
        property var battery:""
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
                battery = parseFloat(platformInterface.status_battery.battery_voltage)
                if (battery !== "NaN")
                    sensorValueText.text = battery.toFixed(1) + " V";
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
                    signalStrength = platformInterface.status_sensor.data
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
