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

    onVisibleChanged: {
        if (visible)
            resetUI();

        var nodeCount = 0;
        for (var alpha = 0;  alpha < platformInterface.network_notification.nodes.length  ; alpha++){
            //for each node that is marked visible set the visibilty of the node appropriately
            console.log("looking at node",alpha, platformInterface.network_notification.nodes[alpha].index, platformInterface.network_notification.nodes[alpha].ready)
            if (platformInterface.network_notification.nodes[alpha].ready !== 0){
                nodeCount++;
                if (nodeCount === 1){
                    root.node1ID = platformInterface.network_notification.nodes[alpha].index
                    //console.log("node 1 set to",root,node1ID)
                }
                else if (nodeCount === 2){
                    root.node2ID = platformInterface.network_notification.nodes[alpha].index
                    //console.log("node 1 set to",root,node2ID)
                }
                else if (nodeCount === 3){
                    root.node3ID = platformInterface.network_notification.nodes[alpha].index
                }
            }
        }
    }

    Text{
        id:title
        anchors.top:parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text:"relay"
        font.pixelSize: 72
    }

    Rectangle{
        id:nodeRectangle
        width: switchOutline.width + 50
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
            text:"node " + nodeNumber
            font.pixelSize: 15
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
            font.pixelSize: 15
        }

        Rectangle{
            id:primaryElementRectangle
            anchors.left:parent.left
            anchors.leftMargin:10
            anchors.right:parent.right
            anchors.rightMargin: 10
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
                font.pixelSize: 15
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
                font.pixelSize: 15
            }

            Rectangle{
                id:modelRectangle
                anchors.left:parent.left
                anchors.leftMargin:10
                anchors.right:parent.right
                anchors.rightMargin: 10
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
                    font.pixelSize: 10
                }

                Text{
                    property int address: 1309
                    id:modelAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"model id 0x" + address
                    font.pixelSize: 10
                }
            }
        }

    }

    MSwitch{
        id:switchOutline
        height:parent.height * .2
        width:height * .6
        anchors.left:parent.left
        anchors.leftMargin:parent.width*.05
        anchors.verticalCenter: parent.verticalCenter

        property var button: platformInterface.demo_click_notification
        onButtonChanged:{
            if (platformInterface.demo_click_notification.demo === "relay")
                if (platformInterface.demo_click_notification.button === "switch1")
                    if (platformInterface.demo_click_notification.value === "on"){
                        switchOutline.isOn = true;
                        if(relaySwitch.checked)
                            lightBulb.onOpacity = 1
                    }
                       else{
                        switchOutline.isOn = false;
                        if(relaySwitch.checked)
                            lightBulb.onOpacity = 0
                    }

        }

        //this switch should have no effect on the lightbulb if the relay switch is off
        onClicked:{
            if (!isOn){         //turning the bulb off
                platformInterface.light_hsl_set.update(65535,0,0,100);  //set color to white
                lightBulb1.onOpacity = 1
                if (relaySwitch.checked){
                    lightBulb2.onOpacity = 1
                }
            }
            else{       //turning the lightbulb off
                platformInterface.light_hsl_set.update(65535,0,0,0);  //set color to black
                lightBulb1.onOpacity = 0
                if (relaySwitch.checked){
                    lightBulb2.onOpacity = 0
                }
            }

            switchOutline.isOn = !switchOutline.isOn
        }


//        onIsOnChanged: {
//            if (isOn && relaySwitch.checked){
//                lightBulb.onOpacity = 1
//                platformInterface.demo_click.update("relay","switch1","on")
//            }
//              else if (!isOn && relaySwitch.checked){
//                lightBulb.onOpacity = 0
//                platformInterface.demo_click.update("relay","switch1","off")
//            }
//        }
    }

    Image{
        id:arrowImage
        anchors.left:nodeRectangle.right
        anchors.leftMargin: 10
        anchors.right:nodeRectangle2.left
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/rightArrow.svg"
        height:12
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
                  return  "message \nto uaddr " + address
                else
                  return "message \nto uaddr -"
            }
            font.pixelSize: 15
        }
    }

    Rectangle{
        id:nodeRectangle2
        width: lightBulb1.width + 50
        height:lightBulb1.height + 250
        anchors.horizontalCenter: lightBulb1.horizontalCenter
        anchors.verticalCenter: lightBulb1.verticalCenter
        anchors.verticalCenterOffset: 25
        radius:10
        border.color:"black"

        Text{
            property int nodeNumber: 2
            id:nodeText2
            anchors.top:parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text:"node " + nodeNumber
            font.pixelSize: 15
        }

        Text{
            property int address: root.node2ID
            id:nodeAddressText2
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
            id:primaryElementRectangle2
            anchors.left:parent.left
            anchors.leftMargin:10
            anchors.right:parent.right
            anchors.rightMargin: 10
            anchors.top:parent.top
            anchors.topMargin:25
            anchors.bottom:parent.bottom
            anchors.bottomMargin:100
            radius:10
            border.color:"black"

            Text{
                id:primaryElementText2
                anchors.top:parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                text:"primary element "
                font.pixelSize: 15
            }

            Text{
                property int address: root.node2ID
                id:primaryElementAddressText2
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
                id:modelRectangle2
                anchors.left:parent.left
                anchors.leftMargin:10
                anchors.right:parent.right
                anchors.rightMargin: 10
                anchors.top:parent.top
                anchors.topMargin:25
                anchors.bottom:parent.bottom
                anchors.bottomMargin:25
                radius:10
                border.color:"black"

                Text{
                    id:modelText2
                    anchors.top:parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"light hsl server model"
                    font.pixelSize: 10
                }

                Text{
                    id:modelAddressText2
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"model id 0x1307"
                    font.pixelSize: 10
                }
            }
        }

        SGSwitch{
            id:relaySwitch
            anchors.top:primaryElementRectangle2.bottom
            anchors.topMargin:10
            anchors.horizontalCenter: parent.horizontalCenter
            width:60
            height:30
            grooveFillColor: "limegreen"
            grooveColor:"lightgrey"

            property var button: platformInterface.demo_click_notification
            onButtonChanged:{
                if (platformInterface.demo_click_notification.demo === "relay")
                    if (platformInterface.demo_click_notification.button === "relay_switch")
                        if (platformInterface.demo_click_notification.value === "on")
                            relaySwitch.isOn = true;
                           else
                            relaySwitch.isOn = false;

            }

            onToggled: {
                //note that turning on or off the relay doesn't change the state of the light
                if (checked){
                    platformInterface.demo_click.update("relay","relay_switch","on")
                }
                else{
                    platformInterface.demo_click.update("relay","relay_switch","off")
                }
            }
        }

        Text{
            id:relaySwitchLabel
            anchors.top:relaySwitch.bottom
            anchors.topMargin: 0
            anchors.horizontalCenter: relaySwitch.horizontalCenter
            text:"relay"
            font.pixelSize: 24
        }

    }

    MLightBulb{
        id:lightBulb1
        height:parent.height * .2
        anchors.horizontalCenter:parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        onBulbClicked: {
            platformInterface.demo_click.update("relay","bulb1","on")
            console.log("bulb clicked")
        }
    }







    Image{
        id:arrowImage2
        anchors.left:nodeRectangle2.right
        anchors.right:bulbNodeRectangle.left
        anchors.verticalCenter: parent.verticalCenter
        source: "qrc:/views/meshNetwork/images/rightArrow.svg"
        height:12
        //sourceSize: Qt.size(width, height)
        fillMode: Image.PreserveAspectFit
        mipmap:true

        Text{
            id:messageText2
            anchors.top:parent.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            text:"relay \nmessage"
            font.pixelSize: 15
        }
    }

    Rectangle{
        id:bulbNodeRectangle
        width: lightBulb2.width + 50
        height:lightBulb2.height + 200
        anchors.horizontalCenter: lightBulb2.horizontalCenter
        anchors.verticalCenter: lightBulb2.verticalCenter
        radius:10
        border.color:"black"

        Text{
            property int nodeNumber: 3
            id:blubNodeText
            anchors.top:parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            text:"node " + nodeNumber
            font.pixelSize: 15
        }

        Text{
            property int address: root.node3ID
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
            anchors.leftMargin:10
            anchors.right:parent.right
            anchors.rightMargin: 10
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
                font.pixelSize: 15
            }

            Text{
                property int address: root.node3ID
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
                anchors.leftMargin:10
                anchors.right:parent.right
                anchors.rightMargin: 10
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
                    font.pixelSize: 10
                }

                Text{
                    property int address: 1307
                    id:bulbModelAddressText
                    anchors.bottom:parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    text:"model id 0x" + address
                    font.pixelSize: 10
                }
            }
        }

    }

    MLightBulb{
        id:lightBulb2
        height:parent.height * .2
        anchors.right:parent.right
        anchors.rightMargin:parent.width*.05
        anchors.verticalCenter: parent.verticalCenter

        onBulbClicked: {
            platformInterface.demo_click.update("relay","bulb1","on")
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
                platformInterface.set_demo.update("relay")
                root.resetUI()
            }
    }

    function resetUI(){
        switchOutline.isOn = false
        relaySwitch.checked = false
    }
}
