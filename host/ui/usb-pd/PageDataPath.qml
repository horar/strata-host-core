import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import tech.spyglass.ImplementationInterfaceBinding 1.0

import "framework"

Item {
    Rectangle {
        id: headerLogo
        anchors { top: parent.top }
        width: parent.width; height: 40
        color: "#235A92"
    }

    Image {
        anchors { top: parent.top; right: parent.right }
        height: 40
        fillMode: Image.PreserveAspectFit
        source: "./images/icons/onLogoGreenWithText.png"
    }
    property var verticalButtonDelta: 40    //distance betwen the routing buttons

    //set the hidden elements of the UI correctly based on the two redriver
    //button being set on startup
    Component.onCompleted: {
        showTwoRedriverSourceAndSink(false);
        showPassiveSourceAndSink(false);
        showChargeOnlySourceAndSink(false);
    }

    // Values are being Signalled from ImplementationInterfaceBinding.cpp
    Connections {
        target: implementationInterfaceBinding

        //  swap cable status
        onSwapCableStatusChanged: {
            if(cableStatus == "Good") {
                statusMessage.color = "green";
                statusMessage.text = "Ready";
            }
            else {
                statusMessage.color = "red";
                if(cableStatus == "USB_C_port_1")
                    statusMessage.text = "Please Flip the Connection on Port 1";
                if(cableStatus == "USB_C_port_2")
                    statusMessage.text = "Please Flip the Connection on Port 2";
                if(cableStatus == "Both")
                    statusMessage.text = "Please Flip the Connection on Both Ports";
            }
        }

        onPlatformResetDetected: {
            console.log("in reset");
            if(reset_status) {
                twoRedrivers.checked = false;
                oneRedriver.checked = true;
                passiveRoute.checked = false;
                showTwoRedriverSourceAndSink(false);
                showPassiveSourceAndSink(false);
                showChargeOnlySourceAndSink(false);
                statusMessage.color = "green";
                statusMessage.text = "Ready";
                console.log("reset detected with ",oneRedriver.checked);
            }
        }
    }

    Text{
        id: pageTitle
        font.family: "helvetica"
        font.pointSize: 32
        text:"SuperSpeed Data Path"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50
    }

    Label{
        id: redriverConfigurationLabel
        anchors {bottom:twoRedrivers.top
                bottomMargin: 20
                right: twoRedrivers.left
                rightMargin: 20
                }
        horizontalAlignment: Text.AlignRight
        font.family: "helvetica"
        font.pointSize: (Qt.platform.os == "osx") ? 25 : 20
        text:"Redriver configuration:"
    }

    function showTwoRedriverSourceAndSink(inShow){
        twoRedriverLaptop.visible = inShow;
        twoRedriversLeftArrows.visible = inShow;
        twoRedriversRightArrows.visible = inShow;
        twoRedriverHD.visible = inShow;
        twoRedriverSourceText.visible = inShow
        //twoRedriverButtonLabel.visible = inShow
        twoRedriversSinkText.visible = inShow
    }

    function showPassiveSourceAndSink(inShow){
        passiveLaptop.visible = inShow;
        passiveLeftArrows.visible = inShow;
        passiveRightArrows.visible = inShow;
        passiveHD.visible = inShow;
        passiveSourceText.visible = inShow
        //passiveButtonLabel.visible = inShow
        passiveSinkText.visible = inShow
    }

    function showChargeOnlySourceAndSink(inShow){

    }

    ButtonGroup {
        id:dataPathGroup
        onClicked: {
            if (button.objectName == "twoRedrivers"){
                showTwoRedriverSourceAndSink(true);
                showPassiveSourceAndSink(false);
                showChargeOnlySourceAndSink(false);
                implementationInterfaceBinding.setRedriverCount(2);

            }
            else if (button.objectName == "passiveRoute"){
                showTwoRedriverSourceAndSink(false);
                showPassiveSourceAndSink(true);
                showChargeOnlySourceAndSink(false);
                implementationInterfaceBinding.setRedriverCount(1);
            }
            else if (button.objectName == "chargeOnlyRoute"){
                showTwoRedriverSourceAndSink(false);
                showPassiveSourceAndSink(false);
                showChargeOnlySourceAndSink(true);
                implementationInterfaceBinding.setRedriverCount(0);
            }
        }
    }

    //--------------------------------------------------------------
    //  Two Redriver group
    //--------------------------------------------------------------
    Image {
        id:twoRedriverLaptop
        source: "./images/DataPath/laptop.svg"
        anchors.verticalCenter: twoRedrivers.verticalCenter
        anchors.right: twoRedriversLeftArrows.left
        anchors.rightMargin: 10

    }

    Text{
        id: twoRedriverSourceText
        text:"Source"
        font.family: "helvetica"
        font.pointSize: (Qt.platform.os == "osx") ? 18 : 18
        color: "grey"
        anchors.horizontalCenter: twoRedriverLaptop.horizontalCenter
        anchors.top:twoRedriverLaptop.bottom
        anchors.topMargin: 5
    }

    Image {
        id: twoRedriversLeftArrows
        source: "./images/DataPath/arrows.svg"
        anchors.verticalCenter: twoRedrivers.verticalCenter
        anchors.right: twoRedrivers.left
        anchors.rightMargin: 10
        anchors.topMargin: 20
    }

    Button{
        id:twoRedrivers
        objectName: "twoRedrivers"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: passiveRoute.top
        anchors.bottomMargin: verticalButtonDelta
        width: parent.width/3
        height: parent.height/6
        ButtonGroup.group: dataPathGroup
        checkable:true
        checked:false
        background: Rectangle{color:"transparent"}

        Image{
            source: twoRedrivers.checked ? "./images/DataPath/TwoRepeaterRouteActive.svg" : "./images/DataPath/TwoRepeaterDataRouteInactive.svg"
            height: twoRedrivers.height
            width: twoRedrivers.width

            Text{
                text:"Flex Cable"
                color: twoRedrivers.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: (Qt.platform.os == "osx") ? 18 : 10
                anchors.centerIn:parent
            }

            Text{
                text:"Redriver"
                color: twoRedrivers.checked ? "darkslategrey" : "transparent"
                font.family: "helvetica"
                font.pointSize: (Qt.platform.os == "osx") ? 15 : 10
                anchors{top:parent.top; topMargin:parent.height/16; left: parent.left; leftMargin: 3*parent.width/16}
            }
            Text{
                text:"Redriver"
                color: twoRedrivers.checked ? "darkslategrey" : "transparent"
                font.family: "helvetica"
                font.pointSize: (Qt.platform.os == "osx") ? 15 : 10
                anchors{top:parent.top; topMargin:parent.height/16; right: parent.right; rightMargin: parent.width/8}
            }
            Text{
                text:"Redriver"
                color: twoRedrivers.checked ? "darkslategrey" : "transparent"
                font.family: "helvetica"
                font.pointSize: (Qt.platform.os == "osx") ? 15 : 10
                anchors{bottom:parent.bottom; bottomMargin:parent.height/16; left: parent.left; leftMargin: 3*parent.width/16}
            }
            Text{
                text:"Redriver"
                color: twoRedrivers.checked ? "darkslategrey" : "transparent"
                font.family: "helvetica"
                font.pointSize: (Qt.platform.os == "osx") ? 15 : 10
                anchors{bottom:parent.bottom; bottomMargin:parent.height/16; right: parent.right; rightMargin: parent.width/8}
            }
        }
    }

    Text{
        id:twoRedriverButtonLabel
        text:"With Redrivers"
        font.family: "helvetica"
        font.pointSize: (Qt.platform.os == "osx") ? 18 : 12
        color: twoRedrivers.checked ? "black" : "grey"
        anchors.horizontalCenter: twoRedrivers.horizontalCenter
        anchors.top:twoRedrivers.bottom
        anchors.topMargin: 5
    }

    Image {
        id: twoRedriversRightArrows
        source: "./images/DataPath/arrows.svg"
        anchors.verticalCenter: twoRedrivers.verticalCenter
        anchors.left: twoRedrivers.right
        anchors.leftMargin: 10
    }

    Image {
        id:twoRedriverHD
        source: "./images/DataPath/hardDrive.svg"
        anchors.verticalCenter: twoRedrivers.verticalCenter
        anchors.left: twoRedriversRightArrows.right
        anchors.leftMargin: 10
    }

    Text{
        id:twoRedriversSinkText
        text:"Sink"
        font.family: "helvetica"
        font.pointSize: (Qt.platform.os == "osx") ? 18 : 18
        color:"grey"
        anchors.horizontalCenter: twoRedriverHD.horizontalCenter
        anchors.top:twoRedriverHD.bottom
        anchors.topMargin: 5
    }



    //--------------------------------------------------------------
    //  Passive group
    //--------------------------------------------------------------
    Image {
        id:passiveLaptop
        source: "./images/DataPath/laptop.svg"
        anchors.verticalCenter: passiveRoute.verticalCenter
        anchors.right: passiveLeftArrows.left
        anchors.rightMargin: 10
    }

    Text{
        id:passiveSourceText
        text:"Source"
        font.family: "helvetica"
        font.pointSize: 18
        color:"grey"
        anchors.horizontalCenter: passiveLaptop.horizontalCenter
        anchors.top:passiveLaptop.bottom
        anchors.topMargin: 5
    }

    Image {
        id: passiveLeftArrows
        source: "./images/DataPath/arrows.svg"
        anchors.verticalCenter: passiveRoute.verticalCenter
        anchors.right: passiveRoute.left
        anchors.rightMargin: 10
    }

    Button{
        id:passiveRoute
        objectName: "passiveRoute"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter:parent.verticalCenter
        anchors.verticalCenterOffset: parent.height/20
        width: parent.width/3
        height: parent.height/6
        ButtonGroup.group: dataPathGroup
        checkable:true
        background: Rectangle{color:"transparent"}

        Image{
            source: passiveRoute.checked ? "./images/DataPath/PassiveDataRouteActive.svg" : "./images/DataPath/PassiveDataRouteInactive.svg"
            height: passiveRoute.height
            width: passiveRoute.width

            Text{
                text:"Flex Cable"
                color: passiveRoute.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: (Qt.platform.os == "osx") ? 18 : 10
                anchors.centerIn:parent
            }
        }
    }

    Text{
        id:passiveButtonLabel
        text:"Passive"
        font.family: "helvetica"
        font.pointSize: (Qt.platform.os == "osx") ? 18 : 12
        color: passiveRoute.checked ? "black" : "grey"
        anchors.horizontalCenter: passiveRoute.horizontalCenter
        anchors.top:passiveRoute.bottom
        anchors.topMargin: 5
    }

    Image {
        id: passiveRightArrows
        source: "./images/DataPath/arrows.svg"
        anchors.verticalCenter: passiveRoute.verticalCenter
        anchors.left: passiveRoute.right
        anchors.leftMargin: 10
    }

    Image {
        id:passiveHD
        source: "./images/DataPath/hardDrive.svg"
        anchors.verticalCenter: passiveRoute.verticalCenter
        anchors.left: passiveRightArrows.right
        anchors.leftMargin: 10
    }

    Text{
        id:passiveSinkText
        text:"Sink"
        font.family: "helvetica"
        font.pointSize: 18
        color:"grey"
        anchors.horizontalCenter: passiveHD.horizontalCenter
        anchors.top:passiveHD.bottom
        anchors.topMargin: 5
    }

    //--------------------------------------------------------------
    //  Charge Only group
    //--------------------------------------------------------------


    Button{
        id:chargeOnly
        objectName: "chargeOnlyRoute"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: passiveRoute.bottom
        anchors.topMargin: verticalButtonDelta
        width: parent.width/3
        height: parent.height/6
        ButtonGroup.group: dataPathGroup
        checkable:true
        checked: true
        background: Rectangle{
                border.color: chargeOnly.checked? "black" : "lightgrey"
                border.width: 2
                color: chargeOnly.checked? "lightgreen" : "lightgrey"
            }


        Image{
            id:chargeOnlyIcon
            source: chargeOnly.checked ? "./images/powerSymbolGreen.svg": "./images/powerSymbolGrey.svg"
            anchors.centerIn: parent
        }
    }

    Text{
        id:chargeOnlyButtonLabel
        text:"Charge only (no data)"
        font.family: "helvetica"
        font.pointSize: (Qt.platform.os == "osx") ? 18 : 12
        color: chargeOnly.checked ? "black" : "grey"
        anchors.horizontalCenter: chargeOnly.horizontalCenter
        anchors.top:chargeOnly.bottom
        anchors.topMargin: 5
    }


    //status and instructions
    Label{
        id:statusMessage
        font.family: "helvetica"
        font.pointSize: (Qt.platform.os == "osx") ? 24 : 24
        color:"red"
        text:""
        anchors{horizontalCenter: parent.horizontalCenter
                bottom:parent.bottom
                bottomMargin: parent.height/10
        }
    }
}
