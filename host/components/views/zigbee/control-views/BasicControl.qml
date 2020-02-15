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
        source:"../images/interiorDark.png"
        //anchors.left:parent.left
        height:parent.height*.65
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        mipmap:true
        opacity:1

        property var triggered: platformInterface.alarm_triggered
        onTriggeredChanged: {
            console.log("alarm triggered=",platformInterface.alarm_triggered.triggered)
            if (platformInterface.alarm_triggered.triggered === "true"){
                alarmTimer.start()
            }
            else{
                alarmTimer.stop()
                officeImage.source = "../images/interiorDark.png"
            }
        }

        Timer{
            //this should cause the images to alternate between the view with the
            //back door open, and the view with the back door open and the red light on
            id:alarmTimer
            interval:1000
            triggeredOnStart: true
            repeat:true

            property var redLightOn: true

            onTriggered:{
                if (redLightOn){
                    officeImage.source = "../images/interiorDark.png"
                }
                else{
                    officeImage.source = "../images/interiorLight.png"
                }
                redLightOn = !redLightOn;
            }

            onRunningChanged:{
                if (!running){
                    redLightOn = true;
                }
            }
        }



        DragTarget{
            //lightswitch
            id:target1
            objectName:"target1"
            anchors.left:parent.left
            anchors.leftMargin: parent.width * 0.05
            anchors.top:parent.top
            anchors.topMargin: parent.height * .32
            nodeType:"light"
            nodeNumber:"1"
            color:"transparent"
        }

        DragTarget{
            //left of the back door
            id:target2
            objectName:"target2"
            anchors.left:parent.left
            anchors.leftMargin: parent.width * .19
            anchors.top:parent.top
            anchors.topMargin: parent.height * .67
            nodeType: "doorbell"
            nodeNumber:"2"
            color:"transparent"
        }


    }



}
