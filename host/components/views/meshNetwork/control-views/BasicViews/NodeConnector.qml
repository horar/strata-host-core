import QtQuick 2.12
import QtQuick.Controls 2.5

Item {
    id:nodeConnector

    property var dragObjects:[]
    property alias canvas: nodeConnectorCanvas

//    Rectangle{
//        //test rectangle to see where the convas boundaries are
//        anchors.left: parent.left
//        anchors.leftMargin: 0
//        anchors.right:parent.right
//        anchors.rightMargin:0
//        anchors.top:parent.top
//        anchors.bottom:parent.bottom
//        border.color:"red"
//        border.width:3
//        color:"transparent"
//    }

    Canvas{
        id:nodeConnectorCanvas
        anchors.fill:parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.lineWidth= 5;
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 1);
            ctx.beginPath();

            //console.log("there are ",dragObjects.length,"objects")
            for (var i = 0; i < dragObjects.length; i++){
                var targetPair = dragObjects[i];
                var start = targetPair[0];
                var end = targetPair[1];
                var startX, startY, endX, endY;
                var deltaY = end.y - start.y;
                var deltaX = end.x - start.x;

                //calculate the offset from the center of the start circle
                var hypotenuse = Math.sqrt(Math.pow(deltaX,2) + Math.pow(deltaY,2));
                var sine = deltaY / hypotenuse;
                var cosine = deltaX / hypotenuse;
                startX = start.x + start.width/2 + cosine * start.width/2;
                startY = start.y + start.height/2 + sine * start.width/2;
                //console.log("center of object",i,"is at",start.x + start.width/2, start.y + start.height/2);
                //console.log("offset start location is",deltaX, deltaY,hypotenuse, cosine , sine );

                //calculate the offset from the center of the end circle
                endX = end.x + end.width/2 - (cosine * start.width/2);
                endY = end.y + end.height/2- (sine * start.width/2);

                //console.log("drawing a line from",startX,startY,"to",endX,endY);
                ctx.moveTo(startX, startY);
                ctx.lineTo(endX,endY);
                ctx.stroke();
            }


        }

    }

}
