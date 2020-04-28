import QtQuick 2.12
import QtQuick.Controls 2.5

Item {
    id: sensorRowRoot
    width: sensorRow.width


    signal showAmbientLightValue()
    signal hideAmbientLightValue()
    signal showBatteryCharge()
    signal hideBatteryCharge()
    signal showTemperature()
    signal hideTemperature()
    signal showSignalStrength()
    signal hideSignalStrength()
    signal showMesh()
    signal hideMesh()
    signal showPairing()
    signal hidePairing()



    ButtonGroup{
        id:sensorButtonGroup
        exclusive: true
    }

    Row{
        id:sensorRow
        height:parent.height
        spacing: 20.0


        Button{
            id:signalStrengthButton
            height:parent.height
            width:height
            checkable:true
            ButtonGroup.group: sensorButtonGroup
            hoverEnabled: true

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onCheckedChanged: {
                if (checked){
                    //ask the platform for the signal strength of each node
                    platformInterface.get_all_sensor_data.update("rssi");
                    sensorRowRoot.showSignalStrength();
                }
                  else
                    sensorRowRoot.hideSignalStrength();
            }

            Image{
                id:signalStrengthImage
                source:"qrc:/views/meshNetwork/images/wifiIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:signalStrengthButton.checked ? .75 : .2
            }

            Text{
                id:signalStrengthLabel
                anchors.top: signalStrengthButton.bottom
                anchors.horizontalCenter: signalStrengthButton.horizontalCenter
                anchors.topMargin: 10
                text: "signal strength"
                font.pixelSize: 18
                visible: signalStrengthButton.hovered
            }
        }

        Button{
            id:ambientLightButton
            height:parent.height
            width:height
            checkable:true
            ButtonGroup.group: sensorButtonGroup

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onCheckedChanged: {
                if (checked){
                    platformInterface.get_all_sensor_data.update("ambient_light");
                    sensorRowRoot.showAmbientLightValue();
                }
                  else
                    sensorRowRoot.hideAmbientLightValue();
            }

            Image{
                id:ambientLightImage
                source:"qrc:/views/meshNetwork/images/ambientLightIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:ambientLightButton.checked ? .75 : .2
            }

            Text{
                id:ambientLightLabel
                anchors.top: ambientLightButton.bottom
                anchors.horizontalCenter: ambientLightButton.horizontalCenter
                anchors.topMargin: 10
                text: "ambient light"
                font.pixelSize: 18
                visible: ambientLightButton.hovered
            }
        }

        Button{
            id:batteryChargeButton
            height:parent.height
            width:height
            checkable:true
            ButtonGroup.group: sensorButtonGroup

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onCheckedChanged: {
                if (checked){
                    platformInterface.get_all_sensor_data.update("battery");
                    sensorRowRoot.showBatteryCharge();
                }
                  else{
                    sensorRowRoot.hideBatteryCharge();
                    console.log("hiding battery level ")
                }
            }

            Image{
                id:batteryChargeImage
                source:"qrc:/views/meshNetwork/images/batteryChargeIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:batteryChargeButton.checked ? .75 : .2
            }

            Text{
                id:batteryChargeLabel
                anchors.top: batteryChargeButton.bottom
                anchors.horizontalCenter: batteryChargeButton.horizontalCenter
                anchors.topMargin: 10
                text: "battery charge"
                font.pixelSize: 18
                visible: batteryChargeButton.hovered
            }
        }

        Button{
            id:temperatureButton
            height:parent.height
            width:height
            checkable:true
            ButtonGroup.group: sensorButtonGroup

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onCheckedChanged: {
                if (checked){
                    platformInterface.get_all_sensor_data.update("temperature");
                    sensorRowRoot.showTemperature();
                }
                  else
                    sensorRowRoot.hideTemperature();
            }

            Image{
                id:temperatureImage
                source:"qrc:/views/meshNetwork/images/temperatureIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:temperatureButton.checked ? .75 : .2
            }

            Text{
                id:temperatureButtonLabel
                anchors.top: temperatureButton.bottom
                anchors.horizontalCenter: temperatureButton.horizontalCenter
                anchors.topMargin: 10
                text: "temperature"
                font.pixelSize: 18
                visible: temperatureButton.hovered
            }
        }

        Button{
            id:meshButton
            height:parent.height
            width:height
            checkable:true
            ButtonGroup.group: sensorButtonGroup
            visible:true

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onCheckedChanged: {
                if (checked){
                    sensorRowRoot.showMesh();
                    console.log("asking for network configuration");
                    platformInterface.get_network.update();
                    }
                  else
                    sensorRowRoot.hideMesh();
            }

            Image{
                id:meshImage
                source:"qrc:/views/meshNetwork/images/meshIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:meshButton.checked ? .75 : .2
            }

            Text{
                id:meshButtonLabel
                anchors.top: meshButton.bottom
                anchors.horizontalCenter: meshButton.horizontalCenter
                anchors.topMargin: 10
                text: "node connections"
                font.pixelSize: 18
                visible: meshButton.hovered
            }
        }

        Button{
            id:clearButton
            height:parent.height
            width:height
            checkable:true
            checked:true
            ButtonGroup.group: sensorButtonGroup

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onCheckedChanged: {
                if (checked){
                    sensorRowRoot.hideSignalStrength();
                    sensorRowRoot.hideAmbientLightValue();
                    sensorRowRoot.hideBatteryCharge();
                    sensorRowRoot.hideTemperature();
                    sensorRowRoot.showPairing();
                    }
                  else{
                    sensorRowRoot.hidePairing();
                    }


            }

            Image{
                id:clearImage
                source: "qrc:/views/meshNetwork/images/clearIcon.svg"
                //source:"qrc:images/clearIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:clearButton.checked ? .75 : .2
            }

            Text{
                id:clearButtonLabel
                anchors.top: clearButton.bottom
                anchors.horizontalCenter: clearButton.horizontalCenter
                anchors.topMargin: 10
                text: "clear"
                font.pixelSize: 18
                visible: clearButton.hovered
            }
        }


    }

}
