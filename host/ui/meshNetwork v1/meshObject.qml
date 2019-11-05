import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id:meshObject
    x: 10; y: 10
    width: 100; height: 100
    radius:50
    color: "red"
    border.color:{
        if (objectName === "provisioner")
            return "blue"
          else if (dropArea.containsDrag)
            return "black"
          else
            return color
    }
    border.width: 4

    property string objectNumber: ""
    property bool provisionerNode: false

    Text{
        id:objectNumber
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: - parent.height/3
        text:meshObject.objectNumber
        font.pixelSize: 24
    }

    InfoPopover{
        id:infoBox
        height:325
        width:300
        anchors.verticalCenter: meshObject.verticalCenter
        anchors.left: meshObject.right
        anchors.leftMargin: 10
        //title:"node" + objectNumber
        visible:false
    }

    Text{
        id:sensorValueText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text:meshObject.objectNumber
        font.pixelSize: 32
        visible:false
        opacity:provisionerNode ? 0 : 1

        Connections{
            target: sensorRow
            onShowAmbientLightValue:{
                sensorValueText.visible = true
                sensorValueText.text = ((Math.random() * 100) ).toFixed(0) + " lux";
            }
            onHideAmbientLightValue:{
                sensorValueText.visible = false
            }
            onShowBatteryCharge:{
                sensorValueText.visible = true
                sensorValueText.text = ((Math.random() * 100) ).toFixed(0) + " V";
            }

            onHideBatteryCharge:{
                sensorValueText.visible = false
            }

            onShowTemperature:{
                sensorValueText.visible = true
                sensorValueText.text = ((Math.random() * 100) ).toFixed(0) + " °C";
            }

            onHideTemperature:{
                sensorValueText.visible = false
            }



        }
    }

    Image{
        id:wifiImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source:"../images/wifiIcon.svg"
        fillMode: Image.PreserveAspectFit
        height:parent.height/4
        mipmap:true
        visible:false
        opacity:provisionerNode ? 0 : 1

        Connections{
            target: sensorRow
            onShowSignalStrength:{
                wifiImage.visible = true
                var signalStrength = Math.round(Math.random() * 3 );
                if (signalStrength === 0){
                    wifiImage.source = "../images/wifiIcon_noBars.svg"
                    wifiImage.height = meshObject.height/16
                    }
                  else if (signalStrength === 1){
                    wifiImage.source = "../images/wifiIcon_oneBar.svg"
                    wifiImage.height = meshObject.height/8
                    }
                  else if (signalStrength === 2){
                    wifiImage.source = "../images/wifiIcon_twoBars.svg"
                    wifiImage.height = 1.5 * meshObject.height/8
                    }
                  else if (signalStrength === 3){
                    wifiImage.source = "../images/wifiIcon.svg"
                    wifiImage.height = meshObject.height/4
                    }
            }

            onHideSignalStrength:{
                wifiImage.visible = false
            }
        }
    }



    Drag.active: dragArea.drag.active
    Drag.hotSpot.x: width/2
    Drag.hotSpot.y: height/2

    MouseArea {
        id: dragArea
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        anchors.fill: parent
        enabled: !provisionerNode

        drag.target: parent

        onEntered: {
            meshObject.z = window.highestZLevel;     //bring object to the fore
            //console.log("elevating z level to ",window.highestZLevel)
            window.highestZLevel++;
        }
        onReleased: {
            meshObject.Drag.drop()
        }
//        onHoveredChanged: {
//            infoBox.visible = true
//        }

        property int mouseButtonClicked: Qt.NoButton
        onPressed: {
                    if (pressedButtons & Qt.LeftButton) {
                        mouseButtonClicked = Qt.LeftButton
                    } else if (pressedButtons & Qt.RightButton) {
                        mouseButtonClicked = Qt.RightButton
                    }
                }

        onClicked: {
            if(mouseButtonClicked & Qt.RightButton) {
                console.log("Right button used");
                contextMenu.open()
            }
            else{
                console.log("left button used")
                infoBox.visible = true
            }
        }

        Menu {
            id: contextMenu
//            x:dragArea.horizontalCenter
//            y:dragArea.verticalCenter
            MenuItem {
                text: "LED"
                checkable:true
                checked:infoBox.hasLEDModel
                onTriggered: {infoBox.hasLEDModel = !infoBox.hasLEDModel}
            }
            MenuItem {
                text: "Buzz"
                checkable:true
                checked:infoBox.hasBuzzerModel
                onTriggered: {infoBox.hasBuzzerModel = !infoBox.hasBuzzerModel}
            }
            MenuItem {
                text: "Vibrate"
                checkable:true
                checked:infoBox.hasVibrationModel
                onTriggered: {infoBox.hasVibrationModel = !infoBox.hasVibrationModel}
            }
        }
    }

    DropArea {
        id:dropArea
        anchors.fill:parent
        enabled: !dragArea.pressed

        onDropped: {
            console.log("object dropped on a Mesh Object");
        }

        onEntered:{
            console.log("mesh object drop area entered");
        }

        onExited: {
            console.log("mesh object drop area exited");
        }
    }


    Component.onCompleted: {
        window.changeObjectSize.connect(changeSize);
    }

    function changeSize( newSize){
        width = newSize;
        height = newSize;
        radius = newSize/2
    }
}
