import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


Rectangle {
    id: root

    property int sensorNodeID:0

    onVisibleChanged: {
        resetThermostatBar.start()

        //start at node 2, the node after the provisioner
        var alpha = 2;
        var sensorNodeFound = false
        while (alpha < platformInterface.network_notification.nodes.length && !sensorNodeFound){
            //for each node that is marked visible set the visibilty of the node appropriately
            console.log("looking at node",alpha, platformInterface.network_notification.nodes[alpha].index, platformInterface.network_notification.nodes[alpha].ready)
            if (platformInterface.network_notification.nodes[alpha].ready !== 0){
                root.sensorNodeID = platformInterface.network_notification.nodes[alpha].index
                console.log("sensor node set to",root.sensorNodeID)
                sensorNodeFound = true;
            }
            alpha++;
        }
    }

    Text{




        id:title
        anchors.top:parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text:"Sensor"
        font.pixelSize: 72
    }

    Button{
        id:getTemperatureButton
        anchors.left:parent.left
        anchors.leftMargin: parent.width * .2
        anchors.verticalCenter: parent.verticalCenter
        text:"Get Temperature"

        contentItem: Text {
                text: getTemperatureButton.text
                font.pixelSize: 24
                opacity: enabled ? 1.0 : 0.3
                color: "black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                color: getTemperatureButton.down ? "lightgrey" : "transparent"
                border.color: "black"
                border.width: 2
                radius: 10
            }

            onClicked: {
                platformInterface.get_sensor.update(root.sensorNodeID,"temperature")
                growThermostatBar.start()
            }
    }

    Text{
        id:temperatureText
        anchors.top: getTemperatureButton.bottom
        anchors.topMargin: 40
        anchors.left: getTemperatureButton.left
        font.pixelSize: 24
        text:""
        visible:false

        property var sensorData: platformInterface.sensor_status
        onSensorDataChanged:{
            if (platformInterface.sensor_status.uaddr === root.sensorNodeID)
                if (platformInterface.sensor_status.sensor_type === "temperature"){
                    temperatureText.visible = true
                    temperatureText.text = "current temperature is " + platformInterface.sensor_status.data + "°C"
                }
        }
    }

    Image{
        id:arrowImage
        anchors.left:getTemperatureButton.right
        anchors.leftMargin: 10
        anchors.right:sensorImage.left
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/leftArrow.svg"
        height:25
        fillMode: Image.PreserveAspectFit
        mipmap:true
    }

    Image{
        id:sensorImage
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.1
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/sensorIcon.svg"
        height:400
        fillMode: Image.PreserveAspectFit
        mipmap:true

        Rectangle{
            id:thermostatBar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -30
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 100
            width:25
            height:10
            color:"#f5a623"
        }
    }

    PropertyAnimation{
        id:growThermostatBar
        target: thermostatBar;
        property: "height";
        to: 225;
        duration: 1000
        running:false
    }

    PropertyAnimation{
        id:resetThermostatBar
        target: thermostatBar;
        property: "height";
        to: 10;
        duration: 0
        running:false
    }

    function resetUI(){
        resetThermostatBar.start()
    }
}
