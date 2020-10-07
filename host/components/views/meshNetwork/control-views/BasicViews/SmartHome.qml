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
            //console.log("smart home is now visible")
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
                //if the node has no pairing model, use "default"
                root.activeNodeRoles[currentNode] = meshObjectRow.meshArray[alpha].pairingModel;
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
        }

        property var meshArray: [0,provisioner,mesh2, mesh1,mesh3, mesh4,mesh6,mesh5, mesh7,mesh8]

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
                            //unless this is the provisioner, in which case we'll update the color, as it doesn't start as a grey node
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
                        //console.log("Conflict. node",platformInterface.network_notification.nodes[alpha].index,"not found in meshArray. Adding in slot",emptySlot)
                        meshArray[emptySlot].opacity = 1.0
                        meshArray[emptySlot].objectColor = platformInterface.network_notification.nodes[alpha].color
                        meshArray[emptySlot].nodeNumber = platformInterface.network_notification.nodes[alpha].index
                    }
                    else{
                        //console.log("no conflict. Adding in position",alpha)
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
                console.log("node not empty, adding in position",emptySlot)
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

        MeshObject{ id: mesh7; scene:"smart_home"; pairingModel:""; subName:"";nodeNumber: "";
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh6; scene:"smart_home"; pairingModel:"" ;nodeNumber: "";
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh4; scene:"smart_home"; pairingModel:"";nodeNumber: "";
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh2; scene:"smart_home"; displayName:"Window"; pairingModel:"window_shade";nodeNumber: "";    //was 2
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        ProvisionerObject{ id: provisioner; nodeNumber:"1" }
        MeshObject{ id: mesh1; scene:"smart_home"; displayName:"Door"; pairingModel:"smarthome_door";nodeNumber: ""     //was 3
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh3; scene:"smart_home"; displayName:"Lights"; pairingModel:"smarthome_lights";nodeNumber: "";    //was 5
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh5; scene:"smart_home"; pairingModel:""; subName:""; nodeNumber: ""
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh8; scene:"smart_home"; pairingModel:"";nodeNumber: ""
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
    }


    Image{
        id:mainImage
        source:"../../images/smartHome_lightsOn.jpg"
        height:parent.height*.6
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 20
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:1

        function toggleWindow(){
           if (platformInterface.window_shade.value === "open")
                platformInterface.window_shade.value = "closed"
              else
                platformInterface.window_shade.value = "open"

           var doorState = platformInterface.smarthome_door.value
           var windowState = platformInterface.window_shade.value
           if (doorState === "open" && windowState === "open")
                 mainImage.source = "../../images/smartHome_doorOpenWindowOpen.jpg"
             else if (doorState === "open" && windowState === "closed")
                 mainImage.source = "../../images/smartHome_doorOpen.jpg"
             else if (doorState === "closed" && windowState === "open")
               mainImage.source = "../../images/smartHome_windowOpen.jpg"
             else if (doorState === "closed" && windowState === "closed")
                mainImage.source = "../../images/smartHome_lightsOn.jpg"
        }

        function setColor(inColor){
            if (inColor === "white")
              mainImage.source = "../../images/smartHome_lightsOn.jpg"
            else if (inColor === "black")
                mainImage.source = "../../images/smartHome_lightsOff.jpg"
            else if (inColor === "blue")
                mainImage.source = "../../images/smartHome_blue.jpg"
            else if (inColor === "green")
                mainImage.source = "../../images/smartHome_green.jpg"
            else if (inColor === "purple")
                mainImage.source = "../../images/smartHome_purple.jpg"
            else if (inColor === "orange")
                mainImage.source = "../../images/smartHome_orange.jpg"
        }

        function toggleDoor(){
            if (platformInterface.smarthome_door.value === "open")
                 platformInterface.smarthome_door.value = "closed"
               else
                 platformInterface.smarthome_door.value = "open"

            var doorState = platformInterface.smarthome_door.value
            var windowState = platformInterface.window_shade.value
            if (doorState === "open" && windowState === "open")
                  mainImage.source = "../../images/smartHome_doorOpenWindowOpen.jpg"
              else if (doorState === "open" && windowState === "closed")
                  mainImage.source = "../../images/smartHome_doorOpen.jpg"
              else if (doorState === "closed" && windowState === "open")
                mainImage.source = "../../images/smartHome_windowOpen.jpg"
              else if (doorState === "closed" && windowState === "closed")
                 mainImage.source = "../../images/smartHome_lightsOn.jpg"
        }

        property var color: platformInterface.room_color_notification
        onColorChanged: {
            var newColor = platformInterface.room_color_notification.color
            if (newColor === "white")
              mainImage.source = "../../images/smartHome_lightsOn.jpg"
            else if (newColor === "black")
                mainImage.source = "../../images/smartHome_lightsOff.jpg"
            else if (newColor === "blue")
                mainImage.source = "../../images/smartHome_blue.jpg"
            else if (newColor === "green")
                mainImage.source = "../../images/smartHome_green.jpg"
            else if (newColor === "purple")
                mainImage.source = "../../images/smartHome_purple.jpg"
            else if (newColor === "orange")
                mainImage.source = "../../images/smartHome_orange.jpg"
            }

        property var door: platformInterface.smarthome_door
        onDoorChanged: {
            var doorState = platformInterface.smarthome_door.value
            var windowState = platformInterface.window_shade.value
            if (doorState === "open" && windowState === "open")
                  mainImage.source = "../../images/smartHome_doorOpenWindowOpen.jpg"
              else if (doorState === "open" && windowState === "closed")
                  mainImage.source = "../../images/smartHome_doorOpen.jpg"
              else if (doorState === "closed" && windowState === "open")
                mainImage.source = "../../images/smartHome_windowOpen.jpg"
              else if (doorState === "closed" && windowState === "closed")
                 mainImage.source = "../../images/smartHome_lightsOn.jpg"
            }

        property var window: platformInterface.window_shade
        onWindowChanged: {
             var doorState = platformInterface.smarthome_door.value
             var windowState = platformInterface.window_shade.value
            console.log("settting window to be",windowState)
            if (doorState === "open" && windowState === "open")
                  mainImage.source = "../../images/smartHome_doorOpenWindowOpen.jpg"
              else if (doorState === "open" && windowState === "closed")
                  mainImage.source = "../../images/smartHome_doorOpen.jpg"
              else if (doorState === "closed" && windowState === "open")
                mainImage.source = "../../images/smartHome_windowOpen.jpg"
              else if (doorState === "closed" && windowState === "closed")
                 mainImage.source = "../../images/smartHome_lightsOn.jpg"
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

            }

            property var targetArray: [0, 0, target1, target2,target3,target4, target5,target6,target7,target8]

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

                var nodeFoundInTargetArray = false;

                for (var alpha = 2;  alpha < platformInterface.network_notification.nodes.length  ; alpha++){
                    for(var beta = 2; beta < targetArray.length; beta++){
                        //console.log("TargetArray: comparing",platformInterface.network_notification.nodes[alpha].index, targetArray[beta].nodeNumber)
                        if (targetArray[beta].nodeNumber !== "" && targetArray[beta].nodeNumber == platformInterface.network_notification.nodes[alpha].index){
                            //console.log("found node",platformInterface.network_notification.nodes[alpha].index, "at location",beta)
                            if (platformInterface.network_notification.nodes[alpha].ready === 0){
                                //remove the item from the meshArray. It's not in the network anymore
                                nodeFoundInTargetArray = true;
                                targetArray[beta].color = "transparent"
                                targetArray[beta].nodeNumber = ""
                            }
                            else if (platformInterface.network_notification.nodes[alpha].ready !== 0){
                                //the node is in both the notification and in the targetArray, no need to update anything
                                if (alpha === 1){
                                    //console.log("updating provisioner color to",platformInterface.network_notification.nodes[alpha].color)
                                    targetArray[alpha].color = platformInterface.network_notification.nodes[alpha].color
                                }
                                nodeFoundInTargetArray = true;
                            }
                        }   //if node numbers match
                    }   //beta for loop
                    //console.log("finished looking for node",platformInterface.network_notification.nodes[alpha].index,"found=",nodeFoundInTargetArray,"ready=",platformInterface.network_notification.nodes[alpha].ready)
                    if (!nodeFoundInTargetArray && platformInterface.network_notification.nodes[alpha].ready !== 0){
                        //we looked through the whole meshArray, and didn't find the nodeNumber that was in the notification
                        //so we should add this node in an empty slot
                        var emptySlot = alpha;

                        //check to see if the the node already has an object there before adding a new one
                        if (targetArray[alpha].nodeNumber != ""){
                            emptySlot = findEmptySlot(alpha)
                            //console.log("conflict. Adding in position",emptySlot,"current node number was",targetArray[alpha].nodeNumber)
                            //console.log("node",platformInterface.network_notification.nodes[alpha].index,"not found in meshArray. Adding in slot",emptySlot)
                            targetArray[emptySlot].color = platformInterface.network_notification.nodes[alpha].color
                            targetArray[emptySlot].nodeNumber = platformInterface.network_notification.nodes[alpha].index
                        }
                        else{
                            //console.log("no conflict. Adding in position",alpha)
                            targetArray[alpha].color = platformInterface.network_notification.nodes[alpha].color
                            targetArray[alpha].nodeNumber = platformInterface.network_notification.nodes[alpha].index
                        }
                    }
                    nodeFoundInTargetArray = false; //reset for next iteration notification node
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

            //this is called when the user drags a node in the row at the top to a new location.
            //the new location, color, pairing model and node number are communicated here.
            function nodeActivated( scene,  pairingModel,  inNodeNumber,  nodeColor){
                console.log("nodeActivated with scene=",scene,"model=",pairingModel,"node=",inNodeNumber,"and color",nodeColor)
                if (scene === "smart_home"){
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
                //window transparency control
                id:target1
                objectName:"target1"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * 0.05
                anchors.top:parent.top
                anchors.topMargin: parent.height * .4
                nodeType:"window_shade"
                scene:"smart_home"
                nodeNumber:""

                onToggleWindow: mainImage.toggleWindow();
            }

            DragTarget{
                //door control
                id:target2
                objectName:"target2"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .4
                anchors.top:parent.top
                anchors.topMargin: parent.height * .30
                scene:"smart_home"
                nodeType: "smarthome_door"
                nodeNumber:""

                onToggleDoor: mainImage.toggleDoor();
            }

            DragTarget{
                //lighting control
                id:target3
                objectName:"target3"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .75
                anchors.top:parent.top
                anchors.topMargin: parent.height * .22
                scene:"smart_home"
                nodeType:"smarthome_lights"
                nodeNumber:""

                onSetRoomColor: mainImage.setColor(inColor)
            }
            DragTarget{
                id:target4
                nodeNumber:""
                visible:false
            }
            DragTarget{
                id:target5
                nodeNumber:""
                visible:false
            }
            DragTarget{
                id:target6
                nodeNumber:""
                visible:false
            }
            DragTarget{
                id:target7
                nodeNumber:""
                visible:false
            }
            DragTarget{
                id:target8
                nodeNumber:""
                visible:false
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
