import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id:provisionerObject
    width: 2*objectWidth; height: 2*objectHeight
    color:"transparent"

    property alias objectColor: provisionerCircle.color
    property alias nodeNumber: nodeNumber.text

    Text{
        id:nodeName
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:provisionerCircle.top
        anchors.bottomMargin: 5
        text:"provisioner"
        font.pixelSize: 24
        color:"black"
    }

    Rectangle{
        id:provisionerCircle
        x: parent.width/4;
        y: parent.height/4
        width: objectHeight; height: objectHeight
        radius:height/2
        color: "green"

        Behavior on opacity{
            NumberAnimation {duration: 1000}
        }

        Text{
            id:nodeNumber
            anchors.centerIn: parent
            text: "0"
            font.pixelSize: 24
            //color:"black"
        }

        Rectangle{
            id:dragObject
            //anchors.fill:parent
            height:parent.height
            width:parent.width
            color:parent.color
            opacity: Drag.active ? 1: 0
            radius: height/2

        }
    }



}
