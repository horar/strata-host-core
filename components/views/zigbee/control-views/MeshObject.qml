import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id:meshObject
    width: 1.5*objectWidth; height: 2*objectHeight
    color:"transparent"
    //border.color:"black"

    property string objectNumber: ""
    property string pairingModel:""
    property string nodeNumber:""
    property alias objectColor: objectCircle.color
    property string subName:""

    onPairingModelChanged:{

        pairingImage.height = meshObject.height * .8

        if (pairingModel === "doorbell"){
            pairingImage.source = "../images/doorbellIcon.svg"
        }
        else if (pairingModel === "alarm"){
            pairingImage.source = "../images/alarmIcon.svg"
        }
        else if (pairingModel === "switch"){
            pairingImage.source = "../images/dimmerIcon.svg"
        }
        else if (pairingModel === "temperature"){
            pairingImage.source = "../images/temperatureIcon.svg"
        }
        else if (pairingModel === "light"){
            pairingImage.source = "../images/ambientLightIcon2.svg"
        }
        else if (pairingModel === "voltage"){
            pairingImage.source = "../images/voltageIcon.svg"
        }
        else if (pairingModel === "security"){
            pairingImage.source = "../images/safetyIcon.svg"
        }
        else  if (pairingModel === ""){
            pairingImage.source = ""
        }
    }

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

        Text{
            id:nodeNumber
            anchors.centerIn: parent
            text:meshObject.nodeNumber
            font.pixelSize: 14
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
                    console.log("left button used")
                    console.log("sending color command from node",meshObject.nodeNumber)
                    platformInterface.light_hsl_set.update(parseInt(meshObject.nodeNumber),0,0,100)
                    //contextMenu.open()
                }
            }
        }





        Text{
            id:nodeName
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom:objectCircle.top
            anchors.bottomMargin: 15
            text:meshObject.pairingModel
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
            text:meshObject.objectNumber
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
                    if (platformInterface.status_sensor.sensor_type === "rssi"){
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

        Image{
            id:chargingImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -18
            source:"../images/chargingIcon.svg"
            fillMode: Image.PreserveAspectFit
            height:parent.height*.3
            mipmap:true
            visible:false

            property var chargeStatus: ""
            property var chargingStatus: platformInterface.status_battery
            onChargingStatusChanged: {
                if (platformInterface.status_battery.uaddr === nodeNumber){
                    chargeStatus = platformInterface.status_battery.battery_state
                }
            }

            Connections{
                target: sensorRow
                onShowBatteryCharge:{
                    if (chargingImage.chargingStatus === "charging"){
                        chargingImage.visible = true
                        chargingImage.source = "../images/chargingIcon.svg"
                    }
                    else if (chargingImage.chargeStatus === "charged"){
                        chargingImage.visible = true
                        chargingImage.source = "../images/chargedIcon.svg"
                    }
                }

                onHideBatteryCharge:{
                    chargingImage.visible = false
                }
            }
        }

        Image{
            id:wifiImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            source:"../images/wifiIcon.svg"
            fillMode: Image.PreserveAspectFit
            height:parent.height/2
            mipmap:true
            visible:false

            property string signalStrength:""

            property var signalStrengthValue: platformInterface.status_sensor
            onSignalStrengthValueChanged: {
                if (platformInterface.status_sensor.uaddr === nodeNumber){
                    if (platformInterface.sensor_data.sensor_type === "strata")
                        signalStrength = platformInterface.signal_strength.data
                    //need to do something here to convert the value into something between 0 and 3?
                }
            }

            Connections{
                target: sensorRow
                onShowSignalStrength:{
                    if (wifiImage.signalStrength != ""){
                        wifiImage.visible = true

                        if (wifiImage.signalStrength === 0){
                            wifiImage.source = "../images/wifiIcon_noBars.svg"
                            wifiImage.height = meshObject.height * .2
                        }
                        else if (wifiImage.signalStrength === 1){
                            wifiImage.source = "../images/wifiIcon_oneBar.svg"
                            wifiImage.height = meshObject.height* .4
                        }
                        else if (wifiImage.signalStrength === 2){
                            wifiImage.source = "../images/wifiIcon_twoBars.svg"
                            wifiImage.height = 1.5 * meshObject.height*.4
                        }
                        else if (wifiImage.signalStrength === 3){
                            wifiImage.source = "../images/wifiIcon.svg"
                            wifiImage.height = meshObject.height * .8
                        }
                    }
                }

                onHideSignalStrength:{
                    wifiImage.visible = false
                }
            }
        }

        Image{
            id:pairingImage
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            mipmap:true
            visible:false//showParingSelected

            property bool showParingSelected: true

            Connections{
                target: sensorRow
                onShowPairing:{
                    pairingImage.showParingSelected = true
                    if (pairingModel === "doorbell"){
                        pairingImage.source = "../images/doorbellIcon.svg"
                        pairingImage.height = meshObject.height * .2
                    }
                    else if (pairingModel === "alarm"){
                        pairingImage.source = "../images/alarmIcon.svg"
                        pairingImage.height = meshObject.height* .4
                    }
                    else if (pairingModel === "switch"){
                        pairingImage.source = "../images/dimmerIcon.svg"
                        pairingImage.height = 1.5 * meshObject.height*.2
                    }
                    else if (pairingModel === "temperature"){
                        pairingImage.source = "../images/temperatureIcon.svg"
                        pairingImage.height = meshObject.height * .8
                    }
                    else if (pairingModel === "light"){
                        pairingImage.source = "../images/ambientLightIcon2.svg"
                        pairingImage.height = meshObject.height * .8
                    }
                    else if (pairingModel === "voltage"){
                        pairingImage.source = "../images/voltageIcon.svg"
                        pairingImage.height = meshObject.height * 2
                    }
                    else if (pairingModel === "security"){
                        pairingImage.source = "../images/safetyIcon.svg"
                        pairingImage.height = meshObject.height * 1
                    }
                    else  if (pairingModel === ""){
                        pairingImage.source = ""
                    }
                }

                onHidePairing:{
                    pairingImage.showParingSelected = false
                }
            }
        }


        //    Rectangle{
        //        id:dragObject
        //        //anchors.fill:parent
        //        height:parent.height
        //        width:parent.width
        //        color:parent.color
        //        opacity: Drag.active ? 1: 0
        //        radius: height/2

        //        Drag.active: dragArea.drag.active
        //        Drag.hotSpot.x: width/2
        //        Drag.hotSpot.y: height/2

        //        property alias model:meshObject.pairingModel

        //        MouseArea {
        //            id: dragArea
        //            acceptedButtons: Qt.LeftButton | Qt.RightButton
        //            anchors.fill: parent


        //drag.target: parent

        //            onPressed:{
        //                console.log("drag object pressed")
        //            }

        //            onReleased:{
        //                console.log("mouse area release called")
        //                dragObject.Drag.drop()
        //                //reset the dragged object's position
        //                parent.x = 0;
        //                parent.y = 0;
        //            }

        //            onEntered: {
        //                meshObject.z = window.highestZLevel;     //bring object to the fore
        //                //console.log("elevating z level to ",window.highestZLevel)
        //                window.highestZLevel++;
        //            }
        //            onReleased: {
        //                meshObject.Drag.drop()
        //            }
        //        onHoveredChanged: {
        //            infoBox.visible = true
        //        }

        //            property int mouseButtonClicked: Qt.NoButton
        //            onPressed: {
        //                        if (pressedButtons & Qt.LeftButton) {
        //                            mouseButtonClicked = Qt.LeftButton
        //                        } else if (pressedButtons & Qt.RightButton) {
        //                            mouseButtonClicked = Qt.RightButton
        //                        }
        //                    }

        //                        onClicked: {
        //                            if(mouseButtonClicked & Qt.RightButton) {
        //                                console.log("Right button used");
        //                                //contextMenu.open()
        //                            }
        //                            else{
        //                                console.log("left button used")
        //                                infoBox.visible = true
        //                            }
        //                        }

        //            Menu {
        //                id: contextMenu
        //                MenuItem {
        //                    text: "LED"
        //                    checkable:true
        //                    checked:infoBox.hasLEDModel
        //                    onTriggered: {infoBox.hasLEDModel = !infoBox.hasLEDModel}
        //                }
        //                MenuItem {
        //                    text: "Buzz"
        //                    checkable:true
        //                    checked:infoBox.hasBuzzerModel
        //                    onTriggered: {infoBox.hasBuzzerModel = !infoBox.hasBuzzerModel}
        //                }
        //                MenuItem {
        //                    text: "Vibrate"
        //                    checkable:true
        //                    checked:infoBox.hasVibrationModel
        //                    onTriggered: {infoBox.hasVibrationModel = !infoBox.hasVibrationModel}
        //                }
        //            }
        //}
    }




}
