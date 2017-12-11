import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import "framework"

Item {

    property var verticalButtonDelta: 40    //distance betwen the routing buttons

    //set the hidden elements of the UI correctly based on the two redriver
    //button being set on startup
    Component.onCompleted: {
        showTwoRedriverSourceAndSink(true);
        showOneRedriverSourceAndSink(false);
        showPassiveSourceAndSink(false);
    }


    Text{
        font.family: "helvetica"
        font.pointSize: 36
        text:"Data Path Configuration"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
    }

    //segmented buttons for signal loss
    Label{
        id: signalLossLabel
        anchors {verticalCenter:buttonRow.verticalCenter
                  right: buttonRow.left
                  rightMargin: 10
        }
        horizontalAlignment: Text.AlignRight
        font.family: "helvetica"
        font.pointSize: 24
        text:"Signal Loss:"
    }

    ButtonGroup {
        buttons: buttonRow.children
        onClicked: {

        }
    }

    Row {
        id:buttonRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height/8

        SGLeftSegmentedButton{width: 200; text:"3 dB" }
        SGMiddleSegmentedButton{width: 200; text:"6 dB" }
        SGRightSegmentedButton{width: 200; text:"9 dB"}
    }


    function showTwoRedriverSourceAndSink(inShow){
        twoRedriverLaptop.visible = inShow;
        twoRedriversLeftArrows.visible = inShow;
        twoRedriversRightArrows.visible = inShow;
        twoRedriverHD.visible = inShow;
        twoRedriverSourceText.visible = inShow
        twoRedriverButtonLabel.visible = inShow
        twoRedriversSinkText.visible = inShow
    }

    function showOneRedriverSourceAndSink(inShow){
        oneRedriverLaptop.visible = inShow;
        oneRedriverLeftArrows.visible = inShow;
        oneRedriverRightArrows.visible = inShow;
        oneRedriverHD.visible = inShow;
        oneRedriverSourceText.visible = inShow
        oneRedriverButtonLabel.visible = inShow
        oneRedriverSinkText.visible = inShow
    }

    function showPassiveSourceAndSink(inShow){
        passiveLaptop.visible = inShow;
        passiveLeftArrows.visible = inShow;
        passiveRightArrows.visible = inShow;
        passiveHD.visible = inShow;
        passiveSourceText.visible = inShow
        passiveButtonLabel.visible = inShow
        passiveSinkText.visible = inShow
    }

    ButtonGroup {
        id:dataPathGroup
        onClicked: {
            if (button.objectName == "twoRedrivers"){
                showTwoRedriverSourceAndSink(true);
                showOneRedriverSourceAndSink(false);
                showPassiveSourceAndSink(false);
            }
            else if (button.objectName == "oneRedriver"){
                showTwoRedriverSourceAndSink(false);
                showOneRedriverSourceAndSink(true);
                showPassiveSourceAndSink(false);
            }
            else if (button.objectName == "passiveRoute"){
                showTwoRedriverSourceAndSink(false);
                showOneRedriverSourceAndSink(false);
                showPassiveSourceAndSink(true);
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
        font.pointSize: 24
        anchors.horizontalCenter: twoRedriverLaptop.horizontalCenter
        anchors.top:twoRedriverLaptop.bottom
        anchors.topMargin: 5
    }

    Image {
        id: twoRedriversLeftArrows
        source: "./images/DataPath/arrows.png"
        anchors.verticalCenter: twoRedrivers.verticalCenter
        anchors.right: twoRedrivers.left
        anchors.rightMargin: 10
    }

    Button{
        id:twoRedrivers
        objectName: "twoRedrivers"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: oneRedriver.top
        anchors.bottomMargin: verticalButtonDelta
        width: parent.width/4
        height: parent.height/8
        ButtonGroup.group: dataPathGroup
        checkable:true
        checked:true
        background: Rectangle{color:"transparent"}

        Image{
            source: twoRedrivers.checked ? "./images/DataPath/TwoRepeaterRouteActive.svg" : "./images/DataPath/TwoRepeaterDataRouteInactive.svg"
            height: twoRedrivers.height
            width: twoRedrivers.width

            Text{
                text:"Flex Cable"
                color: twoRedrivers.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: 14
                anchors.centerIn:parent
            }

            Text{
                text:"Redriver"
                color: twoRedrivers.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: 14
                anchors{top:parent.top; left: parent.left; leftMargin: parent.width/8}
            }
            Text{
                text:"Redriver"
                color: twoRedrivers.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: 14
                anchors{top:parent.top; right: parent.right; rightMargin: parent.width/8}
            }
            Text{
                text:"Redriver"
                color: twoRedrivers.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: 14
                anchors{bottom:parent.bottom; left: parent.left; leftMargin: parent.width/8}
            }
            Text{
                text:"Redriver"
                color: twoRedrivers.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: 14
                anchors{bottom:parent.bottom; right: parent.right; rightMargin: parent.width/8}
            }
        }
    }

    Text{
        id:twoRedriverButtonLabel
        text:"Two Redrivers"
        font.family: "helvetica"
        font.pointSize: 24
        anchors.horizontalCenter: twoRedrivers.horizontalCenter
        anchors.top:twoRedrivers.bottom
        anchors.topMargin: 5
    }

    Image {
        id: twoRedriversRightArrows
        source: "./images/DataPath/arrows.png"
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
        font.pointSize: 24
        anchors.horizontalCenter: twoRedriverHD.horizontalCenter
        anchors.top:twoRedriverHD.bottom
        anchors.topMargin: 5
    }

    //--------------------------------------------------------------
    //  One Redriver group
    //--------------------------------------------------------------
    Image {
        id:oneRedriverLaptop
        source: "./images/DataPath/laptop.svg"
        anchors.verticalCenter: oneRedriver.verticalCenter
        anchors.right: oneRedriverLeftArrows.left
        anchors.rightMargin: 10
    }

    Text{
        id:oneRedriverSourceText
        text:"Source"
        font.family: "helvetica"
        font.pointSize: 24
        anchors.horizontalCenter: oneRedriverLaptop.horizontalCenter
        anchors.top:oneRedriverLaptop.bottom
        anchors.topMargin: 5
    }

    Image {
        id: oneRedriverLeftArrows
        source: "./images/DataPath/arrows.png"
        anchors.verticalCenter: oneRedriver.verticalCenter
        anchors.right: oneRedriver.left
        anchors.rightMargin: 10
    }

    Button{
        id:oneRedriver
        objectName: "oneRedriver"
        anchors.centerIn: parent
        width: parent.width/4
        height: parent.height/8
        ButtonGroup.group: dataPathGroup
        checkable:true
        background: Rectangle{color:"transparent"}

        Image{
            source: oneRedriver.checked ? "./images/DataPath/OneRepeaterRouteActive.svg" : "./images/DataPath/OneRepeaterRouteInactive.svg"
            height: oneRedriver.height
            width: oneRedriver.width

            Text{
                text:"Flex Cable"
                color: oneRedriver.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: 14
                anchors.centerIn:parent
            }
            Text{
                text:"Redriver"
                color: oneRedriver.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: 14
                anchors{top:parent.top; right: parent.right; rightMargin: parent.width/8}
            }
            Text{
                text:"Redriver"
                color: oneRedriver.checked ? "white" : "transparent"
                font.family: "helvetica"
                font.pointSize: 14
                anchors{bottom:parent.bottom; left: parent.left; leftMargin: parent.width/8}
            }

        }
    }

    Text{
        id:oneRedriverButtonLabel
        text:"One Redriver"
        font.family: "helvetica"
        font.pointSize: 24
        anchors.horizontalCenter: oneRedriver.horizontalCenter
        anchors.top:oneRedriver.bottom
        anchors.topMargin: 5
    }

    Image {
        id: oneRedriverRightArrows
        source: "./images/DataPath/arrows.png"
        anchors.verticalCenter: oneRedriver.verticalCenter
        anchors.left: oneRedriver.right
        anchors.leftMargin: 10
    }

    Image {
        id:oneRedriverHD
        source: "./images/DataPath/hardDrive.svg"
        anchors.verticalCenter: oneRedriver.verticalCenter
        anchors.left: oneRedriverRightArrows.right
        anchors.leftMargin: 10
    }

    Text{
        id:oneRedriverSinkText
        text:"Sink"
        font.family: "helvetica"
        font.pointSize: 24
        anchors.horizontalCenter: oneRedriverHD.horizontalCenter
        anchors.top:oneRedriverHD.bottom
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
        font.pointSize: 24
        anchors.horizontalCenter: passiveLaptop.horizontalCenter
        anchors.top:passiveLaptop.bottom
        anchors.topMargin: 5
    }

    Image {
        id: passiveLeftArrows
        source: "./images/DataPath/arrows.png"
        anchors.verticalCenter: passiveRoute.verticalCenter
        anchors.right: passiveRoute.left
        anchors.rightMargin: 10
    }

    Button{
        id:passiveRoute
        objectName: "passiveRoute"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: oneRedriver.bottom
        anchors.topMargin: verticalButtonDelta
        width: parent.width/4
        height: parent.height/8
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
                font.pointSize: 14
                anchors.centerIn:parent
            }
        }
    }

    Text{
        id:passiveButtonLabel
        text:"Passive"
        font.family: "helvetica"
        font.pointSize: 24
        anchors.horizontalCenter: passiveRoute.horizontalCenter
        anchors.top:passiveRoute.bottom
        anchors.topMargin: 5
    }

    Image {
        id: passiveRightArrows
        source: "./images/DataPath/arrows.png"
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
        font.pointSize: 24
        anchors.horizontalCenter: passiveHD.horizontalCenter
        anchors.top:passiveHD.bottom
        anchors.topMargin: 5
    }


    //status and instructions
    Label{
        id:statusMessage
        font.family: "helvetica"
        font.pointSize: 24
        color:passiveRoute.checked ? "red" : "transparent"
        text:"Please flip the connection to port 1"
        anchors{horizontalCenter: parent.horizontalCenter
                bottom:parent.bottom
                bottomMargin: parent.height/8
        }
    }
}
