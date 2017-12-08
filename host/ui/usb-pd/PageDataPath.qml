import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import "framework"

Item {

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

        SGLeftSegmentedButton{width: 100; text:"3 dB" }
        SGMiddleSegmentedButton{width: 100; text:"6 dB" }
        SGRightSegmentedButton{width: 100; text:"9 dB"}
    }

    //data path button group
//    Text{
//        anchors.centerIn: parent
//        font.family: "helvetica"
//        font.pointSize: 72
//        text: "Data Path"
//    }
    ButtonGroup {
        id:dataPathGroup
        onClicked: {

        }
    }

    Image {
        source: "./images/DataPath/laptop.svg"
        anchors.verticalCenter: twoRedrivers.verticalCenter
        anchors.right: twoRedriversLeftArrows.left
        anchors.rightMargin: 10
    }

    Image {
        id: twoRedriversLeftArrows
        source: "./images/DataPath/arrows.svg"
        anchors.verticalCenter: twoRedrivers.verticalCenter
        anchors.right: twoRedrivers.left
        anchors.rightMargin: 10
    }

    Button{
        id:twoRedrivers
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: oneRedriver.top
        anchors.bottomMargin: 20
        width: parent.width/4
        height: parent.height/8
        ButtonGroup.group: dataPathGroup
        checkable:true

        Image{
            source: twoRedrivers.pressed ? "./images/DataPath/TwoRepeaterDataRouteActive.svg" : "./images/DataPath/TwoRepeaterDataRouteInactive.svg"
            height: twoRedrivers.height
            width: twoRedrivers.width
        }
    }

    Image {
        id: twoRedriversRightArrows
        source: "./images/DataPath/arrows.svg"
        anchors.verticalCenter: twoRedrivers.verticalCenter
        anchors.left: twoRedrivers.right
        anchors.leftMargin: 10
    }

    Image {
        source: "./images/DataPath/hardDrive.svg"
        anchors.verticalCenter: twoRedrivers.verticalCenter
        anchors.left: twoRedriversRightArrows.right
        anchors.leftMargin: 10
    }

    Image {
        source: "./images/DataPath/laptop.svg"
        anchors.verticalCenter: oneRedriver.verticalCenter
        anchors.right: oneRedriversLeftArrows.left
        anchors.rightMargin: 10
    }

    Image {
        id: oneRedriversLeftArrows
        source: "./images/DataPath/arrows.svg"
        anchors.verticalCenter: oneRedriver.verticalCenter
        anchors.right: oneRedriver.left
        anchors.rightMargin: 10
    }

    Button{
        id:oneRedriver
        anchors.centerIn: parent
        width: parent.width/4
        height: parent.height/8
        ButtonGroup.group: dataPathGroup
        checkable:true

        Image{
            source: oneRedriver.pressed ? "./images/DataPath/OneRepeaterRouteActive.svg" : "./images/DataPath/OneRepeaterRouteInactive.svg"
            height: oneRedriver.height
            width: oneRedriver.width
        }
    }

    Image {
        id: oneRedriverRightArrows
        source: "./images/DataPath/arrows.svg"
        anchors.verticalCenter: oneRedriver.verticalCenter
        anchors.left: oneRedriver.right
        anchors.leftMargin: 10
    }

    Image {
        source: "./images/DataPath/hardDrive.svg"
        anchors.verticalCenter: oneRedriver.verticalCenter
        anchors.left: oneRedriverRightArrows.right
        anchors.leftMargin: 10
    }

    Image {
        source: "./images/DataPath/laptop.svg"
        anchors.verticalCenter: passiveRoute.verticalCenter
        anchors.right: passiveLeftArrows.left
        anchors.rightMargin: 10
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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: oneRedriver.bottom
        anchors.topMargin: 20
        width: parent.width/4
        height: parent.height/8
        ButtonGroup.group: dataPathGroup
        checkable:true

        Image{
            source: passiveRoute.pressed ? "./images/DataPath/PassiveDataRouteActive.svg" : "./images/DataPath/PassiveDataRouteInactive.svg"
            height: passiveRoute.height
            width: passiveRoute.width
        }
    }

    Image {
        id: passiveRightArrows
        source: "./images/DataPath/arrows.svg"
        anchors.verticalCenter: passiveRoute.verticalCenter
        anchors.left: passiveRoute.right
        anchors.leftMargin: 10
    }

    Image {
        source: "./images/DataPath/hardDrive.svg"
        anchors.verticalCenter: passiveRoute.verticalCenter
        anchors.left: passiveRightArrows.right
        anchors.leftMargin: 10
    }


    //status and instructions
    Label{
        id: statusLabel
        anchors {verticalCenter:statusIndicator.verticalCenter
                  right: signalLossLabel.right
        }
        horizontalAlignment: Text.AlignRight
        font.family: "helvetica"
        font.pointSize: 24
        text:"Status:"
    }

    Rectangle{
        id:statusIndicator
        color:"red"
        height:70
        width:70
        radius: 35
        anchors{bottom:parent.bottom
                bottomMargin: parent.height/8
                left: buttonRow.left
        }
    }

    Label{
        id:statusMessage
        font.family: "helvetica"
        font.pointSize: 24
        color:"red"
        text:"Please flip the connection to port 1"
        anchors{verticalCenter: statusLabel.verticalCenter
                left: statusIndicator.right
                leftMargin: 15
        }
    }
}
