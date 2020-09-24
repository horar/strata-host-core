import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3


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

    Image{
        id:onLogo
        source:"../images/ON-logo.svg"
        height:parent.height*.15
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.top:parent.top
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:1
    }
    Text{
        id:titleText
        anchors.top:parent.top
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        text:"NCS36510 Zigbee Smart Home"
        font.pixelSize: 36
    }

    Image{
        id:zigbeeLogo
        source:"../images/zigbee-logo.png"
        height:parent.height*.15

        anchors.right: parent.right
        anchors.rightMargin: 50
        anchors.top:parent.top
        anchors.topMargin:20
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:1
    }

    Image{
        id:officeImage
        source:"../images/room_lightsOn.jpg"
        height:parent.height*.65
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:1

        property var lightToggled: platformInterface.toggle_light_notification
        onLightToggledChanged: {
            console.log("light toggled=",platformInterface.toggle_light_notification.value)
            if (platformInterface.toggle_light_notification.value === "on"){
                if (platformInterface.toggle_door_notification.value === "open"){
                    officeImage.source = "../images/room_doorOpen.jpg"          //lights on, door open
                    }
                  else{
                    officeImage.source = "../images/room_lightsOn.jpg"          //lights on, door closed
                    }
            }
            else{
                if (platformInterface.toggle_door_notification.value === "open"){
                    officeImage.source = "../images/room_doorOpenLightsOff.jpg" //lights off, door open
                    }
                  else{
                    officeImage.source = "../images/room_lightsOff.jpg"          //lights off, door closed
                    }
            }
        }

        property var doorToggled: platformInterface.toggle_door_notification
        onDoorToggledChanged: {
            if (platformInterface.toggle_door_notification.value === "open"){
                if (platformInterface.toggle_light_notification.value === "on"){
                    officeImage.source = "../images/room_doorOpen.jpg"              //lights on, door open
                    }
                  else{
                    officeImage.source = "../images/room_doorOpenLightsOff.jpg"     //lights off, door open
                }
            }
            else{
                if (platformInterface.toggle_light_notification.value === "on"){
                    officeImage.source = "../images/room_lightsOn.jpg"              //lights on, door closed
                    }
                  else{
                    officeImage.source = "../images/room_lightsOff.jpg"             //lights off, door closed
                }
            }
        }

        property var color: platformInterface.room_color_notification
        onColorChanged: {
            if (platformInterface.room_color_notification.color === "blue"){
                officeImage.source = "../images/room_blue.jpg"
            }
            else if (platformInterface.room_color_notification.color === "green"){
                officeImage.source = "../images/room_green.jpg"
            }
            else if (platformInterface.room_color_notification.color === "purple"){
                officeImage.source = "../images/room_purple.jpg"
            }
            else if (platformInterface.room_color_notification.color === "red"){
                officeImage.source = "../images/room_red.jpg"
            }

        }
        Rectangle{
            id:doorImageDot
            color:"lightblue"
            anchors.left: parent.left
            anchors.leftMargin:  parent.width*.4
            anchors.top:parent.top
            anchors.topMargin: parent.height*.35
            height:50
            width:50
            radius:width/2

            Text{
                id:doorDot
                anchors.centerIn: parent
                text:"2"
                font.pixelSize: 24
            }
        }
        Rectangle{
            id:lightImageDot
            color:"green"
            anchors.right: parent.right
            anchors.rightMargin:  parent.width*.2
            anchors.top:parent.top
            anchors.topMargin: parent.height*.1
            height:50
            width:50
            radius:width/2

            Text{
                id:lightDot
                anchors.centerIn: parent
                text:"1"
                font.pixelSize: 24
            }
        }



    }

    Rectangle{
        id:lightKey
        color:"green"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -200
        anchors.bottom:parent.bottom
        anchors.bottomMargin: parent.height*.1
        height:50
        width:50
        radius:width/2

        Text{
            id:lightNumber
            anchors.centerIn: parent
            text:"1"
            font.pixelSize: 24
        }
    }
    Text{
        id:bulbText
        anchors.left: lightKey.right
        anchors.leftMargin: 10
        anchors.verticalCenter: lightKey.verticalCenter
        text:"Smart LED Bulbs"
        font.pixelSize: 24
    }

    Rectangle{
        id:doorKey
        color:"lightblue"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 200
        anchors.bottom:parent.bottom
        anchors.bottomMargin: parent.height*.1
        height:50
        width:50
        radius:width/2

        Text{
            id:doorNumber
            anchors.centerIn: parent
            text:"2"
            font.pixelSize: 24
        }
    }
    Text{
        id:doorSensorText
        anchors.left: doorKey.right
        anchors.leftMargin: 10
        anchors.verticalCenter: doorKey.verticalCenter
        text:"Battery-free Door sensor"
        font.pixelSize: 24
    }


}



