import QtQuick 2.12
import QtQuick.Controls 2.5

Rectangle {
    id:provisionerObject
    x: 10; y: 10
    width: objectHeight; height: objectHeight
    radius:height/2
    color: "green"


    Behavior on opacity{
        NumberAnimation {duration: 1000}
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
