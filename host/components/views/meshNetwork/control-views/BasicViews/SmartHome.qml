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
    //anchors.fill:parent


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
        }

        property var nodeRemoved: platformInterface.node_removed
        onNodeRemovedChanged: {
            var theNodeNumber = platformInterface.node_removed.node_id
            if(meshArray[theNodeNumber] !== undefined ){
                meshArray[theNodeNumber].opacity = 0
            }
        }


        MeshObject{ id: mesh7; objectName: "one"; pairingModel:""; subName:"";nodeNumber: "8"}
        MeshObject{ id: mesh6; objectName: "two"; pairingModel:"" ;nodeNumber: "6"}
        MeshObject{ id: mesh4; objectName: "three"; pairingModel:"";nodeNumber: "4"}
        MeshObject{ id: mesh2; objectName: "four"; pairingModel:"Window";nodeNumber: "2" }
        ProvisionerObject{ id: provisioner; nodeNumber:"1" }
        MeshObject{ id: mesh1; objectName: "five"; pairingModel:"Door";nodeNumber: "3"}
        MeshObject{ id: mesh3; objectName: "six" ; pairingModel:"Lights";nodeNumber: "5"}
        MeshObject{ id: mesh5; objectName: "seven"; pairingModel:""; subName:""; nodeNumber: "7"}
        MeshObject{ id: mesh8; objectName: "eight"; pairingModel:"";nodeNumber: "9"}
    }


    Image{
        id:mainImage
        source:"qrc:/views/meshNetwork/images/smartHome_lightsOn.png"
        height:parent.height*.70
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:1

        onHeightChanged: {
            console.log("smart home height and width",mainImage.height, mainImage.width)
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
                //since this connection draws straight through the door, it doesn't look good
//                targetPair =[target2, target3];
//                dragTargets.push(targetPair);
            }

            function clearPairings(){
                target1.color = "transparent"
                target2.color = "transparent"
                target3.color = "transparent"
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
                nodeNumber:"3"
                color:mesh7.color
            }

            DragTarget{
                //door control
                id:target2
                objectName:"target2"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .4
                anchors.top:parent.top
                anchors.topMargin: parent.height * .30
                nodeType: "door"
                nodeNumber:"4"
                color:mesh6.color
            }

            DragTarget{
                //lighting control
                id:target3
                objectName:"target3"
                anchors.left:parent.left
                anchors.leftMargin: parent.width * .75
                anchors.top:parent.top
                anchors.topMargin: parent.height * .22
                nodeType:"lights"
                nodeNumber:"5"
                color:mesh4.color
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
