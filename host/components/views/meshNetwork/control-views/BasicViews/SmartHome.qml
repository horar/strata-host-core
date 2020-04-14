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

    onVisibleChanged: {
        if (visible){
            console.log("office is now visible")
            //iterate over the meshArray, and send role and node numbers for each
            meshObjectRow.meshArray.forEach(function(item, index, array){
                platformInterface.set_node_mode.update(item.pairingModel,item.nodeNumber,true)
                })
        }

    }


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

        property var meshArray: [0,provisioner,mesh2, mesh1,mesh4, mesh3,mesh6,mesh5, mesh7,mesh8]
        property var targetArray: [0, target1,target2, target3]
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
            meshArray[theNodeNumber].objectColor = platformInterface.node_added.color
            //targetArray[theNodeNumber].color = platformInterface.node_added.color
            meshArray[theNodeNumber].nodeNumber = theNodeNumber
        }

        property var nodeRemoved: platformInterface.node_removed
        onNodeRemovedChanged: {
            var theNodeNumber = platformInterface.node_removed.node_id
            if(meshArray[theNodeNumber] !== undefined ){
                meshArray[theNodeNumber].opacity = 0
            }
        }

        MeshObject{ id: mesh7; scene:"smart_home"; pairingModel:""; subName:"";nodeNumber: "8";
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh6; scene:"smart_home"; pairingModel:"" ;nodeNumber: "6";
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh4; scene:"smart_home"; pairingModel:"";nodeNumber: "4";
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh2; scene:"smart_home"; displayName:"Window"; pairingModel:"window";nodeNumber: "2";
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        ProvisionerObject{ id: provisioner; nodeNumber:"1" }
        MeshObject{ id: mesh1; scene:"smart_home"; displayName:"Door"; pairingModel:"smart_home_door";nodeNumber: "3"
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh3; scene:"smart_home"; displayName:"Lights"; pairingModel:"lights";nodeNumber: "5";
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh5; scene:"smart_home"; pairingModel:""; subName:""; nodeNumber: "7"
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
        MeshObject{ id: mesh8; scene:"smart_home"; pairingModel:"";nodeNumber: "9"
             onNodeActivated:dragTargetContainer.nodeActivated(scene, pairingModel, nodeNumber, nodeColor)}
    }


    Image{
        id:mainImage
        source:"qrc:/views/meshNetwork/images/smartHome_lightsOn.jpg"
        height:parent.height*.68
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:1

        property var color: platformInterface.room_color_notification
        onColorChanged: {
            var newColor = platformInterface.room_color_notification.color
            if (newColor === "on")
              mainImage.source = "qrc:/views/meshNetwork/images/smartHome_lightsOn.jpg"
            else if (newColor === "off")
                mainImage.source = "qrc:/views/meshNetwork/images/smartHome_lightsOff.jpg"
            else if (newColor === "blue")
                mainImage.source = "qrc:/views/meshNetwork/images/smartHome_blue.jpg"
            else if (newColor === "green")
                mainImage.source = "qrc:/views/meshNetwork/images/smartHome_green.jpg"
            else if (newColor === "purple")
                mainImage.source = "qrc:/views/meshNetwork/images/smartHome_purple.jpg"
            else if (newColor === "orange")
                mainImage.source = "qrc:/views/meshNetwork/images/smartHome_orange.jpg"
            }

        property var door: platformInterface.toggle_door_notification
        onDoorChanged: {
             var doorState = platformInterface.toggle_door_notification.value
            if (doorState === "open")
                mainImage.source = "qrc:/views/meshNetwork/images/smartHome_doorOpen.jpg"
              else
                mainImage.source = "qrc:/views/meshNetwork/images/smartHome_lightsOn.jpg"
            }

        property var window: platformInterface.toggle_window_shade_notification
        onWindowChanged: {

             var windowState = platformInterface.toggle_window_shade_notification.value
            console.log("settting window to be",windowState)
            if (windowState === "open")
                mainImage.source = "qrc:/views/meshNetwork/images/smartHome_windowOpen.jpg"
              else
                mainImage.source = "qrc:/views/meshNetwork/images/smartHome_lightsOn.jpg"
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

            }

            property var targetArray: [0, 0, target1, target2, 0, target3,0,0,0,0]

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
                //console.log("removing node",theNodeNumber)
                targetArray[theNodeNumber].nodeNumber = ""
                targetArray[theNodeNumber].color = "transparent"
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
                nodeType:"window"
                scene:"smart_home"
                nodeNumber:""
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
                nodeType: "smart_home_door"
                nodeNumber:""
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
                nodeType:"lights"
                nodeNumber:"="
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
