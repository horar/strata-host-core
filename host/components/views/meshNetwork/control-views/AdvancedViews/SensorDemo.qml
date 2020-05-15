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
        if (visible){
            resetThermostatBar.start()
            root.updateNodeIDs();
            }
     }

    function updateNodeIDs(){
        //start at node 2, the node after the provisioner
        var alpha = 2;
        var sensorNodeFound = false
        while (alpha < root.availableNodes.length && !sensorNodeFound){
            //for each node that is marked visible set the visibilty of the node appropriately
            //console.log("looking at node",alpha, platformInterface.network_notification.nodes[alpha].index, platformInterface.network_notification.nodes[alpha].ready)
            if (root.availableNodes[alpha] !== 0){
                root.sensorNodeID = alpha
                console.log("sensor node set to",root.sensorNodeID)
                sensorNodeFound = true;
            }
            alpha++;
        }
    }

    //an array to hold the available nodes that can be used in this demo
    //values will be 0 if not available, or 1 if available.
    //node 0 is never used in the network, and node 1 is always the provisioner
    property var availableNodes: [0, 0, 0 ,0, 0, 0, 0, 0, 0, 0];
    onAvailableNodesChanged: {
        root.updateNodeIDs();
    }

    property var network: platformInterface.network_notification
    onNetworkChanged:{

        for (var alpha = 0;  alpha < platformInterface.network_notification.nodes.length  ; alpha++){
            if (platformInterface.network_notification.nodes[alpha].ready === 0){
                root.availableNodes[alpha] = 0;
                }
            else{
                root.availableNodes[alpha] = 1;
            }
        }
        availableNodesChanged();
    }



    property var newNodeAdded: platformInterface.node_added
    onNewNodeAddedChanged: {
        //console.log("new node added",platformInterface.node_added.index)
        var theNodeNumber = platformInterface.node_added.index
        if (root.availableNodes[theNodeNumber] !== undefined){
            root.availableNodes[theNodeNumber] = 1;
            }
        availableNodesChanged();
    }

    property var nodeRemoved: platformInterface.node_removed
    onNodeRemovedChanged: {
        var theNodeNumber = platformInterface.node_removed.node_id
        if(root.availableNodes[theNodeNumber] !== undefined ){
            root.availableNodes[theNodeNumber] = 0
        }
        availableNodesChanged();
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

    Text{
        property int address: root.sensorNodeID
        id:primaryElementAddressText
        anchors.top:sensorImage.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: sensorImage.horizontalCenter
        anchors.horizontalCenterOffset: -sensorImage.width * .15

        text:{
            if (address != 0)
              return  "uaddr " + address
            else
              return "uaddr -"
        }
        font.pixelSize: 24
    }

    function resetUI(){
        resetThermostatBar.start()
    }
}
