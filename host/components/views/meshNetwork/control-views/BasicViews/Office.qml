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

    property var activeNodes:[]     //nodes which are currently populated to be used for the switch_views command
    property var activeNodeRoles:[] //the corresponding role for each node in activeNodes

    onVisibleChanged: {
        if (visible){
            console.log("office is now visible")
            root.sendNodeSwitchCommand();
            }
        }

    function sendNodeSwitchCommand(){
        root.getActiveNodesAndRoles();
        platformInterface.switch_views.update(activeNodes,activeNodeRoles)
    }

    function getActiveNodesAndRoles(){
        var currentNode = 0;

        //iterate over the meshArray, but start at 2, since the node 0 is never used, and node 1 is always a provisioner
        for(var alpha=2; alpha < meshObjectRow.meshArray.length; alpha++){
            //check to see if this mesh object has been assigned to a numbered node
            if (meshObjectRow.meshArray[alpha] !== undefined && meshObjectRow.meshArray[alpha].nodeNumber !== ""){
                //console.log("looking at node",alpha,"node number is",meshObjectRow.meshArray[alpha].nodeNumber,"role is",meshObjectRow.meshArray[alpha].pairingModel);
                //put the node number in the next spot in the activeNodes array
                root.activeNodes[currentNode] = parseInt(meshObjectRow.meshArray[alpha].nodeNumber);
                //put the pairing model in the next spot in the activeNodeRoles array
                root.activeNodeRoles[currentNode] = meshObjectRow.meshArray[alpha].pairingModel;
                //if the node has no pairing model, use "default"
                if (root.activeNodeRoles[currentNode] === ""){
                    root.activeNodeRoles[currentNode] = "default"
                }
                currentNode++;
            }
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

        function findEmptySlot(inCurrentSlot){
            //console.log("emptyslot starting search in position",inCurrentSlot,"array length is",meshArray.length)
            for(var beta = inCurrentSlot; beta < meshArray.length; beta++){
               if ( meshArray[beta].nodeNumber == ""){
                    //console.log(" found emptyslot in position",beta)
                   return beta;
                   }
                 }
            //we didn't find an empty slot? try again from the start
            for(beta = 1; beta < inCurrentSlot; beta++){
               if ( meshArray[beta].nodeNumber == ""){
                   //console.log(" found emptyslot in position",beta)
                   return beta;
                   }
                 }
            //still here? Return the 0th slot, it's always open
            //console.log(" NO emptyslot found, returning 0")
            return 0;
        }

        property var network: platformInterface.network_notification
        onNetworkChanged:{

            //iterate over the nodes in the notification, and over the meshArray nodes for each node in the
            //notification. If the node exists in the meshArray, but not in the notification, the node has been lost without a notification
            //coming through, so remove the node from the meshArray
            //console.log("updating nodes",platformInterface.network_notification.nodes.length)
            var nodeFoundInMeshArray = false;

            for (var alpha = 1;  alpha < platformInterface.network_notification.nodes.length  ; alpha++){
                //console.log("looking for node number",platformInterface.network_notification.nodes[alpha].index,"in meshArray")
                //we can skip the first element in the nodeArray, as it's awlays null
                for(var beta = 1; beta < meshArray.length; beta++){
                    //console.log("comparing",platformInterface.network_notification.nodes[alpha].index, meshArray[beta].nodeNumber)
                    if (meshArray[beta].nodeNumber !== "" && meshArray[beta].nodeNumber == platformInterface.network_notification.nodes[alpha].index){
                        //console.log("found node",platformInterface.network_notification.nodes[alpha].index, "at location",beta)
                        if (platformInterface.network_notification.nodes[alpha].ready === 0){
                            //remove the item from the meshArray. It's not in the network anymore
                            nodeFoundInMeshArray = true;
                            meshArray[beta].objectColor = "#d3d3d3"
                            meshArray[beta].nodeNumber = ""
                            //console.log("Removing. Node not ready")
                        }
                        else if (platformInterface.network_notification.nodes[alpha].ready !== 0){
                            //the node is in both the notification and in the meshArray, no need to update anything
                            //unless this is the provisioner, which doesn't start as a grey node
                            if (alpha === 1){
                                //console.log("updating provisioner color to",platformInterface.network_notification.nodes[alpha].color)
                                meshArray[alpha].objectColor = platformInterface.network_notification.nodes[alpha].color
                            }
                            //console.log("node",platformInterface.network_notification.nodes[alpha].index,"found in meshArray")
                            nodeFoundInMeshArray = true;
                        }
                    }   //if node numbers match
                }   //beta for loop
                //console.log("finished looking for node",platformInterface.network_notification.nodes[alpha].index,"found=",nodeFoundInMeshArray,"ready=",platformInterface.network_notification.nodes[alpha].ready)
                if (!nodeFoundInMeshArray && platformInterface.network_notification.nodes[alpha].ready !== 0){
                    //we looked through the whole meshArray, and didn't find the nodeNumber that was in the notification
                    //so we should add this node in an empty slot
                    var emptySlot = alpha;

                    //check to see if the the node already has an object there before adding a new one
                    if (meshArray[alpha].objectColor != "lightgrey"){
                        emptySlot = findEmptySlot(alpha)
                        //console.log("node",platformInterface.network_notification.nodes[alpha].index,"not found in meshArray. Adding in slot",emptySlot)
                        meshArray[emptySlot].opacity = 1.0
                        meshArray[emptySlot].objectColor = platformInterface.network_notification.nodes[alpha].color
                        meshArray[emptySlot].nodeNumber = platformInterface.network_notification.nodes[alpha].index
                    }
                    else{
                        //console.log("adding node",platformInterface.network_notification.nodes[alpha].index,"in position",alpha)
                        meshArray[alpha].opacity = 1.0
                        meshArray[alpha].objectColor = platformInterface.network_notification.nodes[alpha].color
                        meshArray[alpha].nodeNumber = platformInterface.network_notification.nodes[alpha].index
                    }
                }
                nodeFoundInMeshArray = false; //reset for next iteration notification node
            }
       }



        property var newNodeAdded: platformInterface.node_added
        onNewNodeAddedChanged: {
            //console.log("new node added",platformInterface.node_added.index)
            var theNodeNumber = platformInterface.node_added.index
            var emptySlot = theNodeNumber

            //console.log("adding new node",platformInterface.node_added.index)
            if (theNodeNumber !== 1 && (meshArray[theNodeNumber].objectColor != "lightgrey")){
                emptySlot = findEmptySlot(theNodeNumber)
                //console.log("node not empty, adding in position",emptySlot)
            }

            meshArray[emptySlot].opacity = 1;
            meshArray[emptySlot].objectColor = platformInterface.node_added.color
            meshArray[emptySlot].nodeNumber = theNodeNumber
        }

        property var nodeRemoved: platformInterface.node_removed
        onNodeRemovedChanged: {
            var theNodeNumber = platformInterface.node_removed.index
            for (var alpha=0; alpha < meshArray.length; alpha++){
                //console.log("looking at node",alpha);
                if(meshArray[alpha].nodeNumber !== undefined  && meshArray[alpha].nodeNumber == theNodeNumber){
                    //console.log("removing node",alpha);
                    meshArray[alpha].objectColor = "lightgrey"
                    meshArray[alpha].nodeNumber = ""
                }
            }
        }

        MeshObject{ id: mesh7; scene:"office"; displayName:"Security Camera";pairingModel:"security_camera"; nodeNumber: "";
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor) }
        MeshObject{ id: mesh6; scene:"office"; displayName:"Doorbell"; pairingModel:"doorbell";nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh4; scene:"office"; displayName:"Door"; pairingModel:"door"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh2; scene:"office"; displayName:"Dimmer";pairingModel:"dimmer"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        ProvisionerObject{ id: provisioner; nodeNumber:"1" }
        //
        MeshObject{ id: mesh1; scene:"office"; displayName:"Robotic Arm"; pairingModel:"robotic_arm"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh3; scene:"office"; displayName:"Solar Panel"; subName:"(Relay)"; pairingModel:"relay"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh5; scene:"office"; displayName:"HVAC"; subName:"(Remote)";pairingModel:"hvac"; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh8; scene:"office"; displayName:""; pairingModel:""; nodeNumber: ""
            onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}

    }


    Image{
        id:mainImage
        source:"../../images/office.jpg"
        height:parent.height*.60
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:1

        property alias alarm: alarmTimer

        property var triggered: platformInterface.alarm_triggered
        onTriggeredChanged: {
            //console.log("alarm triggered=",platformInterface.alarm_triggered.triggered)
            if (platformInterface.alarm_triggered.triggered === "true"){
                alarmTimer.start()
            }
            else{
                alarmTimer.stop()
                mainImage.source = "../../images/office.jpg"
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
                    mainImage.source = "../../images/office_doorOpen.jpg"
                }
                else{
                    mainImage.source = "../../images/office_alarmOn.jpg"
                }
                redLightOn = !redLightOn;
            }

            onRunningChanged:{
                if (!running){
                    redLightOn = true;
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

            function findEmptySlot(inCurrentSlot){
                //console.log("emptyslot starting search in position",inCurrentSlot,"array length is",targetArray.length)
                for(var beta = inCurrentSlot; beta < targetArray.length; beta++){
                   if ( targetArray[beta].nodeNumber == ""){
                        //console.log(" found emptyslot in position",beta)
                       return beta;
                       }
                     }
                //we didn't find an empty slot? try again from the start
                for(beta = 1; beta < inCurrentSlot; beta++){
                   if ( targetArray[beta].nodeNumber == ""){
                       //console.log(" found emptyslot in position",beta)
                       return beta;
                       }
                     }
                //still here? Return the 0th slot, it's always open
                //console.log(" NO emptyslot found, returning 0")
                return 0;
            }


            property var network: platformInterface.network_notification
            onNetworkChanged:{

                var nodeFoundInMeshArray = false;

                for (var alpha = 1;  alpha < platformInterface.network_notification.nodes.length  ; alpha++){
                    for(var beta = 1; beta < targetArray.length; beta++){
                        //console.log("comparing",platformInterface.network_notification.nodes[alpha].index, targetArray[beta].nodeNumber)
                        if (targetArray[beta].nodeNumber !== "" && targetArray[beta].nodeNumber == platformInterface.network_notification.nodes[alpha].index){
                            //console.log("found node",platformInterface.network_notification.nodes[alpha].index, "at location",beta)
                            if (platformInterface.network_notification.nodes[alpha].ready === 0){
                                //remove the item from the meshArray. It's not in the network anymore
                                nodeFoundInMeshArray = true;
                                targetArray[beta].color = "transparent"
                                targetArray[beta].nodeNumber = ""
                            }
                            else if (platformInterface.network_notification.nodes[alpha].ready !== 0){
                                //the node is in both the notification and in the targetArray, no need to update anything
                                //unless this is the provisioner, which doesn't start as a grey node
                                if (alpha === 1){
                                    //console.log("updating provisioner color to",platformInterface.network_notification.nodes[alpha].color)
                                    targetArray[alpha].color = platformInterface.network_notification.nodes[alpha].color
                                }
                                nodeFoundInMeshArray = true;
                            }
                        }   //if node numbers match
                    }   //beta for loop
                    //console.log("finished looking for node",platformInterface.network_notification.nodes[alpha].index,"found=",nodeFoundInMeshArray,"ready=",platformInterface.network_notification.nodes[alpha].ready)
                    if (!nodeFoundInMeshArray && platformInterface.network_notification.nodes[alpha].ready !== 0){
                        //we looked through the whole meshArray, and didn't find the nodeNumber that was in the notification
                        //so we should add this node in an empty slot
                        var emptySlot = alpha;

                        //check to see if the the node already has an object there before adding a new one
                        if (targetArray[alpha].color != "transparent"){
                            emptySlot = findEmptySlot(alpha)
                            //console.log("node",platformInterface.network_notification.nodes[alpha].index,"not found in meshArray. Adding in slot",emptySlot)
                            targetArray[emptySlot].color = platformInterface.network_notification.nodes[alpha].color
                            targetArray[emptySlot].nodeNumber = platformInterface.network_notification.nodes[alpha].index
                        }
                        else{
                            targetArray[alpha].color = platformInterface.network_notification.nodes[alpha].color
                            targetArray[alpha].nodeNumber = platformInterface.network_notification.nodes[alpha].index
                        }
                    }
                    nodeFoundInMeshArray = false; //reset for next iteration notification node
                }
           }

            property var newNodeAdded: platformInterface.node_added
            onNewNodeAddedChanged: {
                var theNodeNumber = platformInterface.node_added.index
                var emptySlot = theNodeNumber

                if (theNodeNumber !== 1 && (targetArray[theNodeNumber].color != "transparent")){
                    emptySlot = findEmptySlot(theNodeNumber)
                    //console.log("node not empty, adding in position",emptySlot)
                }

                targetArray[emptySlot].nodeNumber = platformInterface.node_added.index
                targetArray[emptySlot].color = platformInterface.node_added.color
                //console.log("new node added",theNodeNumber,"to role",targetArray[theNodeNumber].nodeType)
            }


            property var nodeRemoved: platformInterface.node_removed
            onNodeRemovedChanged: {
                var theNodeNumber = platformInterface.node_removed.index
                for (var alpha=0; alpha < targetArray.length; alpha++){
                    //console.log("looking for node node",theNodeNumber)
                    if (targetArray[alpha] !== undefined && targetArray[alpha].nodeNumber == theNodeNumber){
                        //console.log("removing node",theNodeNumber)
                        targetArray[alpha].nodeNumber = ""
                        targetArray[alpha].color = "transparent"
                    }
                }
            }

            function nodeActivated( scene,  pairingModel,  inNodeNumber,  nodeColor){
                console.log("nodeActivated with scene=",scene,"model=",pairingModel,"node=",inNodeNumber,"and color",nodeColor)
                if (scene === "office"){
                    //the node must have come from somewhere, so iterate over the nodes, and find the node that previously had
                    //this node number, and set it back to transparent
                    targetArray.forEach(function(item, index, array){
                        if (item.nodeNumber === inNodeNumber){
                            console.log("removing node",item.nodeNumber," from role",item.nodeType)
                            item.nodeNumber = ""
                            item.color = "transparent"
                            }
                        })

                    targetArray.forEach(function(item, index, array){
                        if (item.nodeType === pairingModel){
                            console.log("assigning",item.nodeType,"node",inNodeNumber)
                            item.nodeNumber = inNodeNumber
                            item.color = nodeColor
                        }
                    })
                }
            }

            DragTarget{
                //security camera upper left
                id:target1
                anchors.left:parent.left
                anchors.leftMargin: parent.width * 0.05
                anchors.top:parent.top
                anchors.topMargin: parent.height * .32
                scene:"office"
                nodeType:"security_camera"
                nodeNumber:""
            }

            DragTarget{
                //left of the back door
                id:target2
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
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .30
                anchors.top:parent.top
                anchors.topMargin: parent.height * .61
                scene:"office"
                nodeType:"door"
                nodeNumber:""

                onAlarmTriggered:{
                    console.log("alarm triggerd caught for target 3")
                    mainImage.alarm.start()
                }

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
                nodeType:"high_power"
                color:"green"
            }
            //—————————————————————————————————————

            DragTarget{
                //robot arm
                id:target6
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .63
                anchors.top:parent.top
                anchors.topMargin: parent.height * .53
                scene:"office"
                nodeType:"robotic_arm"
            }

            DragTarget{
                //roof fan
                id:target7
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
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .80
                anchors.top:parent.top
                anchors.topMargin: parent.height * .47
                scene:"office"
                nodeType:"relay"
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
