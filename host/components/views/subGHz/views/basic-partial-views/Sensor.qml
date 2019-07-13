import QtQuick 2.1
import QtQuick.Controls 2.5

Button{
    id:transmitter

    height:300
    width:250
    checkable:true

    property int sensorNumber:0

    //have the sensor cache the values for the main display, so we can update the main display when the
    //sensor is changed
    property int soilMoisture:{
        if (platformInterface.receive_notification.sensor_id === sensorNumber){
            if (platformInterface.receive_notification.sensor_type === "multi_soil"){
                return platformInterface.receive_notification.stemma.soil
            }
            else{
                return "N/A"
            }
        }
        else return soilMoisture;
    }

    property int pressure:{
        if (platformInterface.receive_notification.sensor_id === sensorNumber){
            return platformInterface.receive_notification.bme680.pressure
        }
        else{
            return pressure;       //keep the same number
        }
    }

    property int temperature:{
        if (platformInterface.receive_notification.sensor_id === sensorNumber){
            return  platformInterface.receive_notification.bme680.temperature
        }
        else{
            return temperature;       //keep the same number
        }
    }

    property int humidity:{
        if (platformInterface.receive_notification.sensor_id === sensorNumber){
            return platformInterface.receive_notification.bme680.humidity
        }
        else{
            return humidity;       //keep the same number
        }
    }

    property alias title: transmitterName.text

    property alias color: backgroundRect.color
    signal transmitterNameChanged
    signal selected

    background: Rectangle {
        id:backgroundRect
            implicitHeight: 300
            implicitWidth: 250
            color:"slateGrey"
            //border.color:"dimgrey"
            border.color:"goldenrod"
            border.width:3
            radius: 30
        }

    onCheckedChanged: {
        if (checked){
            backgroundRect.color = "green"
            transmitter.selected();
        }
         else{
            backgroundRect.color = "slateGrey"
        }
    }
    onDoubleClicked: {
        editor.visible = true;
    }

    Text{
        id:transmitterName
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -30
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 15
        text:"sensor 1"
        font.pixelSize:42
        color:"lightgrey"
    }

    Rectangle {
        id: editor
        anchors.fill: transmitterName
        visible: false
        color: "#0cf"


        TextInput {
            anchors.centerIn: editor
            text: transmitterName.text
            font.pixelSize:transmitterName.font.pixelSize
            onAccepted: {
                transmitterName.text = text;
                editor.visible = false;
                //send a signal with the new text
                transmitter.transmitterNameChanged();
            }
            onVisibleChanged: {
                if (visible) {
                    forceActiveFocus();
                    selectAll();
                }
            }
        }
    }

    SignalStrengthIndicator{
        id:bars
        height:50
        width: 50
        anchors.right: transmitter.right
        anchors.rightMargin:15
        anchors.verticalCenter: transmitterName.verticalCenter
        sensorNumber: transmitter.sensorNumber
    }






}
