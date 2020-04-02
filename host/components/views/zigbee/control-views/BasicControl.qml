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
                //switch to image with light on
                officeImage.source = "../images/room_lightsOn.jpg"
            }
            else{
                officeImage.source = "../images/room_lightsOff.jpg"
            }
        }

        property var doorToggled: platformInterface.toggle_door_notification
        onDoorToggledChanged: {
            if (platformInterface.toggle_door_notification.value === "open"){
                //switch to image with light on
                officeImage.source = "../images/room_doorOpen.jpg"
            }
            else{
                officeImage.source = "../images/room_lightsOn.jpg"
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



    }


}



