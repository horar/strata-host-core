import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0


Rectangle {
    id: root
    color:"transparent"

    property int node1ID: 0
    property int node2ID: 0

    onVisibleChanged: {
        if (visible){
            resetUI();

            var nodeCount = 0;

            for (var alpha = 0;  alpha < platformInterface.network_notification.nodes.length  ; alpha++){
                //for each node that is marked visible set the visibilty of the node appropriately
                console.log("looking at node",alpha, platformInterface.network_notification.nodes[alpha].index, platformInterface.network_notification.nodes[alpha].ready)
                if (platformInterface.network_notification.nodes[alpha].ready != 0){
                    nodeCount++;
                    if (nodeCount === 1){
                        root.node1ID = platformInterface.network_notification.nodes[alpha].index
                        console.log("node 1 set to",root,node1ID)
                    }
                    else if (nodeCount === 2){
                        root.node2ID = platformInterface.network_notification.nodes[alpha].index
                        console.log("node 1 set to",root,node2ID)
                    }
                }
            }
        }
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
            property int address: root.node1ID
            id:nodeAddressText
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text:{
                if (address != 0)
                  return  "uaddr " + address
                else
                  return "uddr -"
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
                text:"primary element "
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
                      return "uddr -"
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
                    text:"light hsl client model"
                    font.pixelSize: 12
                }

                Text{
                    property int address: 1309
                    id:modelAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"model id 0x" + address
                    font.pixelSize: 15
                }
            }
        }

    }

    Text{
        id:title
        anchors.top:parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text:"one-to-one"
        font.pixelSize: 72
    }

    MSwitch{
        id:switchOutline
        height:160
        width:100
        anchors.left:parent.left
        anchors.leftMargin:parent.width*.1
        anchors.verticalCenter: parent.verticalCenter

        property var button: platformInterface.demo_click_notification
        onButtonChanged:{
            if (platformInterface.demo_click_notification.demo === "one_to_one")
                if (platformInterface.demo_click_notification.button === "switch")
                    if (platformInterface.demo_click_notification.value === "on"){
                        switchOutline.isOn = true;
                        lightBulb.onOpacity = 1
                    }
                    else{
                        switchOutline.isOn = false;
                        lightBulb.onOpacity = 0
                    }

        }

        onClicked:{
            if (!isOn){     //turning the lightbulb on
                lightBulb.onOpacity = 1
                platformInterface.light_hsl_set.update(65535,0,0,100);  //set color to white
                switchOutline.isOn = true
              }
              else{         //turning the lightbulb off
                lightBulb.onOpacity = 0
                platformInterface.light_hsl_set.update(65535,0,0,0);  //set color to black
                switchOutline.isOn = false
              }
        }
    }





    Image{
        id:arrowImage
        anchors.left:nodeRectangle.right
        anchors.leftMargin: 10
        anchors.right:bulbNodeRectangle.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/rightArrow.svg"
        height:25
        //sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        mipmap:true

        Text{
            property int address: root.node2ID
            id:messageText
            anchors.top:parent.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text:{
                if (address != 0)
                  return  "message to uaddr " + address
                else
                  return "message to uddr -"
            }
            font.pixelSize: 18
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
            property int address: root.node2ID
            id:bulbNodeAddressText
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text:{
                if (address != 0)
                  return  "uaddr " + address
                else
                  return "uddr -"
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
                text:"primary element"
                font.pixelSize: 18
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
                      return "uddr -"
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
                    text:"light hsl server model"
                    font.pixelSize: 12
                }

                Text{
                    property int address: 1307
                    id:bulbModelAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"model id 0x" + address
                    font.pixelSize: 15
                }
            }
        }

    }
    MLightBulb{
        id:lightBulb
        height:parent.height * .2
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.1
        anchors.verticalCenter: parent.verticalCenter

        onBulbClicked: {
            platformInterface.demo_click.update("one_to_one","bulb1","on")
            console.log("bulb clicked")
        }
    }



    Button{
        id:resetButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 20
        text:"configure"

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
                platformInterface.set_demo.update("one_to_one")
                root.resetUI()
            }
    }

    function resetUI(){
        switchOutline.isOn = false
    }


}
