import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


Rectangle {
    id: root

    property int node1ID: 0
    property int node2ID: 0
    property int node3ID: 0
    property int node4ID: 0

    onVisibleChanged: {
        if (visible){
            resetUI();
            root.updateNodeIDs()
        }
    }

    function updateNodeIDs(){
        node1ID = node2ID = node3ID = node4ID = 0;      //clear previous values
        var nodeCount = 0;
        for (var alpha = 1;  alpha < root.availableNodes.length  ; alpha++){
            //for each node that is marked visible set the visibilty of the node appropriately
            //console.log("looking at node",alpha, platformInterface.network_notification.nodes[alpha].index, platformInterface.network_notification.nodes[alpha].ready)
            if (root.availableNodes[alpha] !== 0){
                nodeCount++;
                if (nodeCount === 1){
                    root.node1ID = alpha
                    //console.log("node 1 set to",root.node1ID)
                }
                else if (nodeCount === 2){
                    root.node2ID = alpha
                    //console.log("node 2 set to",root.node2ID)
                }
                else if (nodeCount === 3){
                    root.node3ID = alpha
                    //console.log("node 3 set to",root.node3ID)
                }
                else if (nodeCount === 4){
                    root.node4ID = alpha
                    //console.log("node 4 set to",root.node4ID)
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
        anchors.topMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        text:"One-to-Many"
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
            property int nodeNumber: 1
            id:nodeText
            anchors.top:parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text:"Node " + nodeNumber
            font.pixelSize: 18
        }

        Text{
            property int address: root.node1ID
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
                property int address: root.node1ID
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
                    text:"Light HSL Client Model"
                    font.pixelSize: 12
                }

                Text{
                    id:modelAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"Model ID 0x1309"
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

        property var button: platformInterface.one_to_many_demo
        onButtonChanged:{
            if (platformInterface.one_to_many_demo.lights === "on"){
                        switchOutline.isOn = true;
                        lightBulb1.onOpacity =1
                        lightBulb2.onOpacity =1
                        lightBulb3.onOpacity =1
                    }
                    else{
                        switchOutline.isOn = false;
                        lightBulb1.onOpacity =0
                        lightBulb2.onOpacity =0
                        lightBulb3.onOpacity =0
                    }

        }

        onClicked:{
            if (!isOn){     //turning the lightbulb on
                lightBulb1.onOpacity =1
                lightBulb2.onOpacity =1
                lightBulb3.onOpacity =1
                platformInterface.light_hsl_set.update(65535,0,0,50);  //set color to white
                switchOutline.isOn = true
              }
              else{         //turning the lightbulb off
                lightBulb1.onOpacity =0
                lightBulb2.onOpacity =0
                lightBulb3.onOpacity =0
                platformInterface.light_hsl_set.update(65535,0,0,0);  //set color to black
                switchOutline.isOn = false
              }
        }


    }

    Image{
        id:arrowImage
        anchors.left:nodeRectangle.right
        anchors.leftMargin: 10
        anchors.right:bulbGroup.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        source: "../../images/rightArrow.svg"
        height:25
        //sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        mipmap:true

        Text{
            id:messageText
            anchors.top:parent.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text:"Message to uaddr 0xFFFF"
            font.pixelSize: 18
        }
    }

    Rectangle{
        id: bulbGroup
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.05
        anchors.top:parent.top
        anchors.topMargin: 100
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 50
        width:200
        color:"transparent"
        border.color:"transparent"
        border.width: 3



        Column{
            id:bulbColumn
            anchors.fill:parent
            topPadding: 10
            spacing:10

            property var spacerHeight: 50

            Rectangle{
                id:bulbNodeRectangle
                height:bulbColumn.height/3 - bulbColumn.spacing*2 - bulbColumn.spacerHeight
                width:parent.width-10
                anchors.horizontalCenter: parent.horizontalCenter
                radius:10
                border.color:"black"

                Text{
                    property int nodeNumber: 2
                    id:blubNodeText
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"Node " + nodeNumber
                    font.pixelSize: 15
                }

                Text{
                    property int address: root.node2ID
                    id:bulbNodeAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:{
                        if (address != 0)
                          return  "uaddr " + address
                        else
                          return "uaddr -"
                    }
                    font.pixelSize: 15
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
                        font.pixelSize: 15
                    }

                    Text{
                        property int address: root.node2ID
                        id:bulbPrimaryElementAddressText
                        anchors.bottom:parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:{
                            if (address != 0)
                              return  "uaddr " + address
                            else
                              return "uaddr -"
                        }
                        font.pixelSize: 15
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
                            text:"Light HSL Server Model"
                            font.pixelSize: 12
                        }

                        MLightBulb{
                            id:lightBulb1
                            height:{
                                if (bulbModelRectangle.height > 50)
                                    return bulbModelRectangle.height *.65
                                else
                                    return 0
                            }
                            anchors.verticalCenter: bulbModelRectangle.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            onBulbClicked: {
                                platformInterface.demo_click.update("one_to_many","bulb1","on")
                                console.log("bulb1 clicked")
                            }
                        }

                        Text{
                            property int address: 1307
                            id:bulbModelAddressText
                            anchors.bottom:parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"Model ID 0x" + address
                            font.pixelSize: 15
                        }
                    }
                }

            }


            Rectangle{
                id:bulbNodeRectangle2
                height:bulbColumn.height/3 - bulbColumn.spacing*2 - bulbColumn.spacerHeight
                width:parent.width-10
                anchors.horizontalCenter: parent.horizontalCenter
                radius:10
                border.color:"black"

                Text{
                    property int nodeNumber: 3
                    id:blubNodeText2
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"Node " + nodeNumber
                    font.pixelSize: 15
                }

                Text{
                    property int address: root.node3ID
                    id:bulbNodeAddressText2
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:{
                        if (address != 0)
                          return  "uaddr " + address
                        else
                          return "uaddr -"
                    }
                    font.pixelSize: 15
                }

                Rectangle{
                    id:bulbPrimaryElementRectangle2
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
                        id:bulbPrimaryElementText2
                        anchors.top:parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:"Primary Element"
                        font.pixelSize: 15
                    }

                    Text{
                        property int address: root.node3ID
                        id:bulbPrimaryElementAddressText2
                        anchors.bottom:parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:{
                            if (address != 0)
                              return  "uaddr " + address
                            else
                              return "uaddr -"
                        }
                        font.pixelSize: 15
                    }

                    Rectangle{
                        id:bulbModelRectangle2
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
                            id:bulbModelText2
                            anchors.top:parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"Light HSL Server Model"
                            font.pixelSize: 12
                        }

                        MLightBulb{
                            id:lightBulb2
                            height:{
                                if (bulbModelRectangle2.height > 50)
                                    return bulbModelRectangle2.height *.65
                                else
                                    return 0
                            }
                            anchors.verticalCenter: bulbModelRectangle2.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            onBulbClicked: {
                                platformInterface.demo_click.update("one_to_many","bulb2","on")
                                console.log("bulb1 clicked")
                            }
                        }

                        Text{
                            property int address: 1307
                            id:bulbModelAddressText2
                            anchors.bottom:parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"Model ID 0x" + address
                            font.pixelSize: 15
                        }
                    }
                }

            }

            Rectangle{
                id:spacer
                height:bulbColumn.spacerHeight
                width:parent.width-10
                color:"transparent"

                Text{
                    id:elipsisText
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -10
                    text:"..."
                    font.pixelSize: 36

                }
            }

            Rectangle{
                id:bulbNodeRectangle3
                height:bulbColumn.height/3 - bulbColumn.spacing*2 - bulbColumn.spacerHeight
                width:parent.width-10
                anchors.horizontalCenter: parent.horizontalCenter
                radius:10
                border.color:"black"

                Text{
                    property int nodeNumber: 4
                    id:blubNodeText3
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"Node n"
                    font.pixelSize: 15
                }

                Text{
                    property int address: root.node4ID
                    id:bulbNodeAddressText3
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:{
                        if (address != 0)
                          return  "uaddr " + address
                        else
                          return "uaddr -"
                    }
                    font.pixelSize: 15
                }

                Rectangle{
                    id:bulbPrimaryElementRectangle3
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
                        id:bulbPrimaryElementText3
                        anchors.top:parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:"Primary Element"
                        font.pixelSize: 15
                    }

                    Text{
                        property int address: root.node4ID
                        id:bulbPrimaryElementAddressText3
                        anchors.bottom:parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text:{
                            if (address != 0)
                              return  "uaddr " + address
                            else
                              return "uaddr -"
                        }
                        font.pixelSize: 15
                    }

                    Rectangle{
                        id:bulbModelRectangle3
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
                            id:bulbModelText3
                            anchors.top:parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"Light HSL Server Model"
                            font.pixelSize: 12
                        }

                        MLightBulb{
                            id:lightBulb3
                            height:{
                                if (bulbModelRectangle3.height > 50)
                                    return bulbModelRectangle3.height *.65
                                else
                                    return 0
                            }
                            anchors.verticalCenter: bulbModelRectangle3.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            onBulbClicked: {
                                platformInterface.demo_click.update("one_to_many","bulb3","on")
                                console.log("bulb1 clicked")
                            }
                        }

                        Text{
                            property int address: 1307
                            id:bulbModelAddressText3
                            anchors.bottom:parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            text:"Model ID 0x" + address
                            font.pixelSize: 15
                        }
                    }
                }

            }

        }


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
                //platformInterface.set_demo.update("one_to_many")
                //according to documentation, no action is needed to configure the one to many demo
                root.resetUI()
            }
    }

    function resetUI(){
        switchOutline.isOn = false
        lightBulb1.onOpacity = 0
        lightBulb2.onOpacity = 0
        lightBulb3.onOpacity = 0
    }


}
