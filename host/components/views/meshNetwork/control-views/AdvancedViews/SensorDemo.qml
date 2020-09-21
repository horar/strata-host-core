import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


Rectangle {
    id: root

    property int switchNodeID:0
    property int sensorNodeID:0

    onVisibleChanged: {
        if (visible){
            resetUI();
            root.updateNodeIDs();
            }
     }

    function updateNodeIDs(){
        var nodeCount = 0;

        switchNodeID = sensorNodeID = 0; //clear previous values
        for (var alpha = 1;  alpha < root.availableNodes.length  ; alpha++){
            //for each node that is marked visible set the visibilty of the node appropriately
            //console.log("looking at node",alpha, platformInterface.network_notification.nodes[alpha].index, platformInterface.network_notification.nodes[alpha].ready)
            if (root.availableNodes[alpha] !== 0){
                nodeCount++;
                if (nodeCount === 1){
                    root.switchNodeID = alpha
                    //console.log("switch node set to",root.switchNodeID)
                }
                else if (nodeCount === 2){
                    root.sensorNodeID = alpha
                    //console.log("sensor node set to",root.sensorNodeID)
                }
            }
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
        var theNodeNumber = platformInterface.node_removed.index
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


    Rectangle{
        id:nodeRectangle
        width: switchOutline.width + 100
        height:switchOutline.height + 200
        anchors.horizontalCenter: switchOutline.horizontalCenter
        anchors.verticalCenter: switchOutline.verticalCenter
        radius:10
        border.color:"black"

        Text{
            id:nodeText
            anchors.top:parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text:"node 1"
            font.pixelSize: 18
        }

        Text{
            property int address: root.switchNodeID
            id:nodeAddressText
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text:{
                if (address != 0)
                  return  "uaddr " + address
                else
                  return "uaddr -"
            }

            font.pixelSize: 18
        }

        Rectangle{
            id:primaryElementRectangle
            anchors.left:parent.left
            anchors.leftMargin:15
            anchors.right:parent.right
            anchors.rightMargin: 15
            anchors.top:parent.top
            anchors.topMargin:25
            anchors.bottom:parent.bottom
            anchors.bottomMargin:25
            radius:10
            border.color:"black"

            Text{
                id:primaryElementText
                anchors.top:parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text:"Primary Element "
                font.pixelSize: 18
            }

            Text{
                property int address: root.switchNodeID
                id:primaryElementAddressText
                anchors.bottom:parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text:{
                    if (address != 0)
                      return  "uaddr " + address
                    else
                      return "uaddr -"
                }
                font.pixelSize: 18
            }

            Rectangle{
                id:modelRectangle
                anchors.left:parent.left
                anchors.leftMargin:15
                anchors.right:parent.right
                anchors.rightMargin: 15
                anchors.top:parent.top
                anchors.topMargin:25
                anchors.bottom:parent.bottom
                anchors.bottomMargin:25
                radius:10
                border.color:"black"

                Text{
                    id:modelText
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"Sensor Client Model"
                    font.pixelSize: 12
                }

                Text{
                    property int address: 1102
                    id:modelAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"Model ID 0x" + address
                    font.pixelSize: 15
                }
            }
        }

    }

    MSwitch{
        id:switchOutline
        height:parent.height * .2
        width:height * .6
        anchors.left:parent.left
        anchors.leftMargin:parent.width*.1
        anchors.verticalCenter: parent.verticalCenter

        onClicked:{
            platformInterface.get_sensor.update(root.sensorNodeID,"temperature")
            switchOutline.isOn = ! switchOutline.isOn
        }
    }

    Image{
        id:rightArrowImage
        anchors.left:nodeRectangle.right
        anchors.leftMargin: 10
        anchors.right:bulbNodeRectangle.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        source: "../../images/rightArrow.svg"
        height:25
        //sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        mipmap:true

        Text{
            property int address: root.sensorNodeID
            id:messageText
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            text:{
                if (address != 0)
                  return  "Message to uaddr " + address
                else
                  return "Message to uaddr -"
            }
            font.pixelSize: 18
        }
    }

    Image{
        id:leftArrowImage
        anchors.top:rightArrowImage.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter : rightArrowImage.horizontalCenter
        source: "../../images/leftArrow.svg"
        height:25
        sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        mipmap:true

        Text{
            id:temperatureText
            anchors.top: parent.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 18
            text:""
            visible:false

            property var sensorData: platformInterface.sensor_status
            onSensorDataChanged:{
                if (platformInterface.sensor_status.uaddr === root.sensorNodeID)
                    if (platformInterface.sensor_status.sensor_type === "temperature"){
                        temperatureText.visible = true
                        temperatureText.text = "Current temperature is " + platformInterface.sensor_status.data + "°C"
                    }
            }
        }


    }

    Rectangle{
        id:bulbNodeRectangle
        width: lightBulb.width + 100
        height:lightBulb.height + 200
        anchors.horizontalCenter: lightBulb.horizontalCenter
        anchors.verticalCenter: lightBulb.verticalCenter
        radius:10
        border.color:"black"

        Text{
            property int nodeNumber: 2
            id:blubNodeText
            anchors.top:parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text:"node " + nodeNumber
            font.pixelSize: 18
        }

        Text{
            property int address: root.sensorNodeID
            id:bulbNodeAddressText
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text:{
                if (address != 0)
                  return  "uaddr " + address
                else
                  return "uaddr -"
            }
            font.pixelSize: 18
        }

        Rectangle{
            id:bulbPrimaryElementRectangle
            anchors.left:parent.left
            anchors.leftMargin:15
            anchors.right:parent.right
            anchors.rightMargin: 15
            anchors.top:parent.top
            anchors.topMargin:25
            anchors.bottom:parent.bottom
            anchors.bottomMargin:25
            radius:10
            border.color:"black"

            Text{
                id:bulbPrimaryElementText
                anchors.top:parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text:"Primary Element"
                font.pixelSize: 18
            }

            Text{
                property int address: root.sensorNodeID
                id:bulbPrimaryElementAddressText
                anchors.bottom:parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text:{
                    if (address != 0)
                      return  "uaddr " + address
                    else
                      return "uaddr -"
                }
                font.pixelSize: 18
            }

            Rectangle{
                id:bulbModelRectangle
                anchors.left:parent.left
                anchors.leftMargin:15
                anchors.right:parent.right
                anchors.rightMargin: 15
                anchors.top:parent.top
                anchors.topMargin:25
                anchors.bottom:parent.bottom
                anchors.bottomMargin:25
                radius:10
                border.color:"black"

                Text{
                    id:bulbModelText
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"Sensor Server Model"
                    font.pixelSize: 12
                }

                Text{
                    property int address: 1100
                    id:bulbModelAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"Model ID 0x" + address
                    font.pixelSize: 15
                }
            }
        }

    }

    Image{
        id:lightBulb
        height:parent.height * .2
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.1
        anchors.verticalCenter: parent.verticalCenter
        source: "../../images/sensorIcon.svg"
        fillMode: Image.PreserveAspectFit
        mipmap:true
    }

    Button{
        id:resetButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 20
        text:"Configure"
        visible:false

        contentItem: Text {
                text: resetButton.text
                font.pixelSize: 20
                opacity: enabled ? 1.0 : 0.3
                color: "grey"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                color: resetButton.down ? "lightgrey" : "transparent"
                border.color: "grey"
                border.width: 2
                radius: 10
            }

            onClicked: {
                platformInterface.set_onetoone_demo.update()
                root.resetUI()
            }
    }

    function resetUI(){
        switchOutline.isOn = false
    }

}
