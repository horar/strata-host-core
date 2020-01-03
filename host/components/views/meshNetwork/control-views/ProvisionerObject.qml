import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id:provisionerObject
    width: 1.5*objectWidth; height: 2*objectHeight
    color:"transparent"
    //border.color:"black"

    property alias objectColor: provisionerCircle.color
    property alias nodeNumber: nodeNumber.text

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
        anchors.bottomMargin: 5
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



        property string ambientLightText
        property string batteryText
        property string temperatureText
        property string signalStrengthText

        property var ambientLightValue: platformInterface.status_sensor
        onAmbientLightValueChanged: {
            if (platformInterface.status_sensor.uaddr === provisionerObject.nodeNumber){
                if (platformInterface.status_sensor.sensor_type === "ambient_light"){
                    ambientLightText = platformInterface.status_sensor.data
                }
            }
        }

        property var batteryValue: platformInterface.status_battery
        onBatteryValueChanged: {
            console.log("provisioner received battery value change",platformInterface.status_battery.uaddr,platformInterface.status_battery.battery_voltage)
            if (platformInterface.status_battery.uaddr === provisionerObject.nodeNumber){
                console.log("changing batteryText for provisioner node")
                batteryText = platformInterface.status_battery.battery_voltage
            }
        }

        property var temperatureValue: platformInterface.status_sensor
        onTemperatureValueChanged: {
            if (platformInterface.status_sensor.uaddr === provisionerObject.nodeNumber){
                if (platformInterface.status_sensor.sensor_type === "temperature"){
                    temperatureText = platformInterface.status_sensor.data
                }
            }
        }

        property var signalStrength: platformInterface.status_sensor
        onSignalStrengthChanged: {
            if (platformInterface.status_sensor.uaddr === provisionerObject.nodeNumber){
                if (platformInterface.status_sensor.sensor_type === "strata"){
                    signalStrengthText = platformInterface.status_sensor.data
                }
            }
        }

        Connections{
            target: sensorRow
            onShowAmbientLightValue:{
                //if (sensorValueText.ambientLightText != ""){
                    console.log("light sensor value is",sensorValueText.ambientLightText)
                    sensorValueText.visible = true
                    sensorValueText.text = Math.round(sensorValueText.ambientLightText) + " lux";
                //    }
                //  else
                //    sensorValueText.text = ""
            }
            onHideAmbientLightValue:{
                sensorValueText.visible = false
            }
            onShowBatteryCharge:{
                console.log("showing battery level of",sensorValueText.batteryText)
                //if (sensorValueText.batteryText != ""){
                    sensorValueText.visible = true
                    sensorValueText.text = Math.round(sensorValueText.batteryText) + " V";
                //    }
                //else
                //    sensorValueText.text = ""
            }

            onHideBatteryCharge:{
                sensorValueText.visible = false
            }

            onShowTemperature:{
                //if (sensorValueText.temperatureText != ""){
                    sensorValueText.visible = true
                    sensorValueText.text = sensorValueText.temperatureText + " °C";
                 //   }
                //if we don't have a value for this node, don't show any text
                //else
                //    sensorValueText.text = ""
            }

            onHideTemperature:{
                sensorValueText.visible = false
            }


            onShowSignalStrength:{
               sensorValueText.visible = true
               sensorValueText.text = sensorValueText.signalStrengthText;
            }

            onHideSignalStrength:{
                //wifiImage.visible = false
            }

        }
    }



}
