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

    Row{
        id:sensorRow
        height:parent.height
        spacing: 20.0

        function clearAllText(){
            sensorRowRoot.hideSignalStrength();
            sensorRowRoot.hideAmbientLightValue();
            sensorRowRoot.hideBatteryCharge();
            sensorRowRoot.hideTemperature();
            sensorRowRoot.showPairing();
            sensorRowRoot.hideMesh();
        }

        Button{
            id:signalStrengthButton
            height:parent.height
            width:height
            hoverEnabled: true

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onPressedChanged: {
                if (pressed){
                    //ask the platform for the signal strength of each node
                    platformInterface.get_all_sensor_data.update("rssi");
                    sensorRow.clearAllText();
                    sensorRowRoot.showSignalStrength();
                }
            }

            Image{
                id:signalStrengthImage
                source:"qrc:/views/meshNetwork/images/wifiIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:signalStrengthButton.pressed ? .75 : .2
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

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onPressedChanged: {
                if (pressed){
                    platformInterface.get_all_sensor_data.update("ambient_light");
                    sensorRow.clearAllText();
                    sensorRowRoot.showAmbientLightValue();
                }
            }

            Image{
                id:ambientLightImage
                source:"qrc:/views/meshNetwork/images/ambientLightIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:ambientLightButton.pressed ? .75 : .2
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

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onPressedChanged: {
                if (pressed){
                    platformInterface.get_all_sensor_data.update("battery");
                    sensorRow.clearAllText();
                    sensorRowRoot.showBatteryCharge();
                }
            }

            Image{
                id:batteryChargeImage
                source:"qrc:/views/meshNetwork/images/batteryChargeIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:batteryChargeButton.pressed ? .75 : .2
            }

            Text{
                id:batteryChargeLabel
                anchors.top: batteryChargeButton.bottom
                anchors.horizontalCenter: batteryChargeButton.horizontalCenter
                anchors.topMargin: 10
                text: "battery"
                font.pixelSize: 18
                visible: batteryChargeButton.hovered
            }
        }

        Button{
            id:temperatureButton
            height:parent.height
            width:height
            checkable:true

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onPressedChanged: {
                if (pressed){
                    platformInterface.get_all_sensor_data.update("temperature");
                    sensorRow.clearAllText();
                    sensorRowRoot.showTemperature();
                }
            }

            Image{
                id:temperatureImage
                source:"qrc:/views/meshNetwork/images/temperatureIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:temperatureButton.pressed ? .75 : .2
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
            visible:true

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onPressedChanged: {
                if (pressed){

                    console.log("asking for network configuration");
                    sensorRow.clearAllText();
                    sensorRowRoot.showMesh();
                    platformInterface.get_network.update();
                    }
            }

            Image{
                id:meshImage
                source:"qrc:/views/meshNetwork/images/meshIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:meshButton.pressed ? .75 : .2
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

            background: Rectangle {
                    color:"transparent"
                    radius: height/10
                }

            onPressedChanged: {
                if (pressed){
                    sensorRow.clearAllText();
                    }
            }

            Image{
                id:clearImage
                source: "qrc:/views/meshNetwork/images/clearIcon.svg"
                fillMode: Image.PreserveAspectFit
                height:parent.height
                anchors.horizontalCenter: parent.horizontalCenter
                mipmap:true
                opacity:clearButton.pressed ? .75 : .2
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
