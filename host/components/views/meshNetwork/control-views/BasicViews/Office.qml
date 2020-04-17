import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


Rectangle {
    id: root
    visible: true

    property int objectWidth: 50
    property int objectHeight: 50
    property int nodeWidth: 32
    property int nodeHeight: 32
    property int highestZLevel: 1
    property int numberOfNodes: 8

    property real backgroundCircleRadius: root.width/4
    property int meshObjectCount:0
    property variant meshObjects
    property var dragTargets:[]

    onVisibleChanged: {
        if (visible){
            console.log("office is now visible")
            //iterate over the meshArray, and send role and node numbers for each
            meshObjectRow.meshArray.forEach(function(item, index, array){
                //removed temporarily because sending nine commands back to back overloads the network.
                //platformInterface.set_node_mode.update(item.pairingModel,item.nodeNumber,true)
                })
        }

    }

    Row{
        id:meshObjectRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:parent.top
        anchors.topMargin: 20
        spacing: 20.0

        function clearPairings(){
            //console.log("clearing pairings")
            mesh1.pairingModel = ""
            mesh2.pairingModel = ""
            mesh3.pairingModel = ""
            mesh4.pairingModel = ""
            mesh5.pairingModel = ""
            mesh6.pairingModel = ""
            mesh7.pairingModel = ""
            mesh8.pairingModel = ""
        }

        property var meshArray: [0,provisioner,mesh4, mesh6, mesh1, mesh2, mesh3,mesh5, mesh7,mesh8]

        property var initialNodeVisibilityColors: platformInterface.network_notification
        onInitialNodeVisibilityColorsChanged:{

            //iterate over the nodes in the notification
            console.log("updating nodes",platformInterface.network_notification.nodes.length)
            for (var alpha = 0;  alpha < platformInterface.network_notification.nodes.length  ; alpha++){
                //for each node that is marked visible set the visibilty of the node appropriately
                if (platformInterface.network_notification.nodes[alpha].ready === 0){
                    meshArray[alpha].opacity = 0.5
                    meshArray[alpha].enabled = false
                    meshArray[alpha].objectColor = "lightgrey"
                    meshArray[alpha].nodeNumber = ""
                    //targetArray[alpha].color = "transparent"

                    //special case because sometimes the 0th element of the notification array
                    //really represents the first element
                    if (alpha === 1){
                        if (platformInterface.network_notification.nodes[0].ready === 1 ){
                            meshArray[alpha].opacity = 1.0
                            meshArray[alpha].enabled = true
                            meshArray[alpha].objectColor = platformInterface.network_notification.nodes[alpha].color

                        }
                    }
                }
                else {
                    meshArray[alpha].opacity = 1.0
                    meshArray[alpha].enabled = true
                    meshArray[alpha].objectColor = platformInterface.network_notification.nodes[alpha].color
                    meshArray[alpha].nodeNumber = platformInterface.network_notification.nodes[alpha].index

                    //special case because sometimes the 0th element of the notification array
                    //really represents the first element
                    if (alpha == 0){
                        if (meshArray[alpha.enabled == true])
                            meshArray[1] = true;
                    }

                    //targetArray[alpha].color = platformInterface.network_notification.nodes[alpha].color
                }
            }
        }



        property var newNodeAdded: platformInterface.node_added
        onNewNodeAddedChanged: {
            //console.log("new node added",platformInterface.node_added.index)
            var theNodeNumber = platformInterface.node_added.index
            meshArray[theNodeNumber].opacity = 1;
            //console.log("set the opacity of node",theNodeNumber, "to 1");
            meshArray[theNodeNumber].nodeNumber = platformInterface.node_added.index
            meshArray[theNodeNumber].objectColor = platformInterface.node_added.color
        }

        property var nodeRemoved: platformInterface.node_removed
        onNodeRemovedChanged: {
            var theNodeNumber = platformInterface.node_removed.node_id
            if(meshArray[theNodeNumber] !== undefined ){
                meshArray[theNodeNumber].opacity = 0
            }
        }

        MeshObject{ id: mesh7; scene:"office"; displayName:"Security Camera";pairingModel:"security"; nodeNumber: "";
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor) }
        MeshObject{ id: mesh6; scene:"office"; displayName:"Doorbell"; pairingModel:"doorbell";nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh4; scene:"office"; displayName:"Door"; pairingModel:"door"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh2; scene:"office"; displayName:"Dimmer";pairingModel:"dimmer"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        ProvisionerObject{ id: provisioner; nodeNumber:"1" }
        //
        MeshObject{ id: mesh1; scene:"office"; displayName:"Robotic Arm"; pairingModel:"robot_arm"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh3; scene:"office"; displayName:"Solar Panel"; subName:"(Relay)"; pairingModel:"solar_panel"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh5; scene:"office"; displayName:"HVAC"; subName:"(Remote)";pairingModel:"hvac"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh8; scene:"office"; displayName:""; pairingModel:""; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}

    }


    Image{
        id:mainImage
        source:"qrc:/views/meshNetwork/images/office.jpg"
        //anchors.left:parent.left
        height:parent.height*.7
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:1

        property var triggered: platformInterface.alarm_triggered
        onTriggeredChanged: {
            console.log("alarm triggered=",platformInterface.alarm_triggered.triggered)
            if (platformInterface.alarm_triggered.triggered === "true"){
                alarmTimer.start()
            }
            else{
                alarmTimer.stop()
                mainImage.source = "qrc:/views/meshNetwork/images/office.jpg"
            }
        }

        Timer{
            //this should cause the images to alternate between the view with the
            //back door open, and the view with the back door open and the red light on
            id:alarmTimer
            interval:1000
            triggeredOnStart: true
            repeat:true

            property var redLightOn: true

            onTriggered:{
                if (redLightOn){
                    mainImage.source = "qrc:/views/meshNetwork/images/office_doorOpen.jpg"
                }
                else{
                    mainImage.source = "qrc:/views/meshNetwork/images/office_alarmOn.jpg"
                }
                redLightOn = !redLightOn;
            }

            onRunningChanged:{
                if (!running){
                    redLightOn = true;
                }
            }
        }



        NodeConnector{
            id:nodeConnector
            anchors.left:dragTargetContainer.left
            anchors.right:dragTargetContainer.right
            anchors.top:dragTargetContainer.top
            height: dragTargetContainer.height
            visible:false

            dragObjects: dragTargets

            Connections{
                target: sensorRow
                onShowMesh:{
                    nodeConnector.visible = true
                }
                onHideMesh:{
                    nodeConnector.visible = false
                }
            }
        }


        Rectangle{
            id:dragTargetContainer
            anchors.fill:mainImage
            color:"transparent"
            property var targetPair:[]

            Component.onCompleted: {
                //add the dragTarget pairs to an array that can be used to draw lines between them
                //programatically
                targetPair =[target1, target2];
                dragTargets.push(targetPair);
                targetPair =[target1, target3];
                dragTargets.push(targetPair);
                targetPair =[target1, target4];
                dragTargets.push(targetPair);
                targetPair =[target2, target3];
                dragTargets.push(targetPair);
                targetPair =[target3, target4];
                dragTargets.push(targetPair);
                targetPair =[target3, target6];
                dragTargets.push(targetPair);
                targetPair =[target4, target5];
                dragTargets.push(targetPair);
                targetPair =[target5, target6];
                dragTargets.push(targetPair);
                targetPair =[target5, target8];
                dragTargets.push(targetPair);
                targetPair =[target6, target4];
                dragTargets.push(targetPair);
                targetPair =[target6, target8];
                dragTargets.push(targetPair);
                targetPair =[target7, target8];
                dragTargets.push(targetPair);
            }

            function clearPairings(){
                target1.color = "transparent"
                target2.color = "transparent"
                target3.color = "transparent"
                target4.color = "transparent"
                //target5.color = "transparent" //this is the provisioner, which should always stay green
                target6.color = "transparent"
                target7.color = "transparent"
                target8.color = "transparent"
            }

            property var targetArray: [0, target5,target3 ,target2,target6 , target4,target8 , target7, target1, 0]

            property var network: platformInterface.network_notification
            onNetworkChanged:{

                //iterate over the nodes in the notification
                console.log("updating nodes",platformInterface.network_notification.nodes.length)
                for (var alpha = 0;  alpha < platformInterface.network_notification.nodes.length  ; alpha++){
                    //for each node that is marked visible set the visibilty of the node appropriately
                    if (platformInterface.network_notification.nodes[alpha].ready === 0){
                        targetArray[alpha].objectColor = "transparent"
                        targetArray[alpha].nodeNumber = ""

                        //special case because sometimes the 0th element of the notification array
                        //really represents the first element
                        if (alpha === 1){
                            if (platformInterface.network_notification.nodes[0].ready === 1 ){
                                targetArray[alpha].color = platformInterface.network_notification.nodes[alpha].color

                            }
                        }
                    }
                    else {
                        targetArray[alpha].color = platformInterface.network_notification.nodes[alpha].color
                        targetArray[alpha].nodeNumber = platformInterface.network_notification.nodes[alpha].index


                    }
                }
            }

            property var newNodeAdded: platformInterface.node_added
            onNewNodeAddedChanged: {

                var theNodeNumber = platformInterface.node_added.index

                targetArray[theNodeNumber].nodeNumber = platformInterface.node_added.index
                targetArray[theNodeNumber].color = platformInterface.node_added.color
                console.log("new node added",theNodeNumber,"to role",targetArray[theNodeNumber].nodeType)
            }

            property var nodeRemoved: platformInterface.node_removed
            onNodeRemovedChanged: {
                var theNodeNumber = platformInterface.node_removed.node_id
                console.log("removing node",theNodeNumber)
                targetArray[theNodeNumber].nodeNumber = ""
                targetArray[theNodeNumber].color = "transparent"
            }

            function nodeActivated( scene,  pairingModel,  inNodeNumber,  nodeColor){
                //console.log("nodeActivated with scene=",scene,"model=",pairingModel,"node=",inNodeNumber,"and color",nodeColor)
                if (scene === "office"){
                    //the node must have come from somewhere, so iterate over the nodes, and find the node that previously had
                    //this node number, and set it back to transparent
                    targetArray.forEach(function(item, index, array){
                        if (item.nodeNumber === inNodeNumber){
                            //console.log("removing node from role",item.nodeType)
                            item.nodeNumber = ""
                            item.color = "transparent"
                            }
                        })

                    targetArray.forEach(function(item, index, array){
                        if (item.nodeType === pairingModel){
                            //console.log("assigning",item.nodeType,"node",inNodeNumber)
                            item.nodeNumber = inNodeNumber
                            item.color = nodeColor
                        }
                    })
                }
            }

            DragTarget{
                //security camera upper left
                id:target1
                //objectName:"target1"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * 0.05
                anchors.top:parent.top
                anchors.topMargin: parent.height * .32
                scene:"office"
                nodeType:"security"
                nodeNumber:""
            }

            DragTarget{
                //left of the back door
                id:target2
                //objectName:"target2"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .16
                anchors.top:parent.top
                anchors.topMargin: parent.height * .69
                scene:"office"
                nodeType: "doorbell"
                nodeNumber:""
            }

            DragTarget{
                //on the back door
                id:target3
                //objectName:"target3"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .30
                anchors.top:parent.top
                anchors.topMargin: parent.height * .61
                scene:"office"
                nodeType:"door"
                nodeNumber:""
            }
            DragTarget{
                //right of front door
                id:target4
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .45
                anchors.top:parent.top
                anchors.topMargin: parent.height * .33
                scene:"office"
                nodeType:"dimmer"
                nodeNumber:""
            }

            //******PROVISIONING NODE**************
            DragTarget{

                id:target5
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .65
                anchors.top:parent.top
                anchors.topMargin: parent.height * .37
                nodeType:"provisioner"
                color:"green"
            }
            //—————————————————————————————————————

            DragTarget{
                //robot arm
                id:target6
                //objectName:"target6"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .63
                anchors.top:parent.top
                anchors.topMargin: parent.height * .53
                scene:"office"
                nodeType:"robot_arm"
            }

            DragTarget{
                //roof fan
                id:target7
                //objectName:"target7"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .80
                anchors.top:parent.top
                anchors.topMargin: parent.height * .23
                scene:"office"
                nodeType:"hvac"
                nodeNumber:""
            }
            DragTarget{
                //solar panel
                id:target8
                //objectName:"target8"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .80
                anchors.top:parent.top
                anchors.topMargin: parent.height * .47
                scene:"office"
                nodeType:"solar_panel"
                nodeNumber:""
            }

        }

    }

    SensorRow{
        id:sensorRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 50
        height:50
    }
}
