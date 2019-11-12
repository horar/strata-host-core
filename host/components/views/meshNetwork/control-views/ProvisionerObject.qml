import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id:meshObject
    x: 10; y: 10
    width: objectHeight; height: objectHeight
    radius:height/2
    color: "green"
    border.color: "blue"
    border.width: 4

    property string objectNumber: ""

    Behavior on opacity{
        NumberAnimation {duration: 1000}
    }




    Text{
        id:objectNumber
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: - parent.height/3
        text:meshObject.objectNumber
        font.pixelSize: 24
    }

    InfoPopover{
        id:infoBox
        height:325
        width:300
        anchors.verticalCenter: meshObject.verticalCenter
        anchors.left: meshObject.right
        anchors.leftMargin: 10
        //title:"node" + objectNumber
        visible:false
    }






    Rectangle{
        id:dragObject
        //anchors.fill:parent
        height:parent.height
        width:parent.width
        color:parent.color
        opacity: Drag.active ? 1: 0
        radius: height/2

        Drag.active: dragArea.drag.active
        Drag.hotSpot.x: width/2
        Drag.hotSpot.y: height/2

//        MouseArea {
//            id: dragArea
//            //acceptedButtons: Qt.LeftButton | Qt.RightButton
//            anchors.fill: parent
//            //enabled: !provisionerNode

//            drag.target: parent

//            onPressed:{
//                console.log("drag object pressed")
//            }

//            onReleased:{
//                console.log("mouse area release called")
//                dragObject.Drag.drop()
//                //reset the dragged object's position
//                parent.x = 0;
//                parent.y = 0;
//            }


//        }
    }




}
