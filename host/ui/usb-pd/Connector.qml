import QtQuick 2.0
import QtQuick.Controls 1.4

Rectangle {
    id: connector
    width: parent.width; height: (parent.width * .75)
    color:"transparent"
    border{ color: "transparent"; width: 2 }
    radius: 10
    property int anchorbottom: 0
    anchors.bottom: if(anchorbottom) { parent.bottom }
    property bool isConnected: false
    //Create a cable
    Canvas {
        id: cable
        x: leftUSBPlug.x + leftUSBPlug.width; y: leftUSBPlug.y
        width: connector.width/1.35; height: 100
        anchors{ left: leftUSBPlug.right; right: connector.right }
        property color strokeStyle:  "black"
        property color fillStyle: "#b40000" // red
        property int lineWidth: 2
        property bool fill: true
        property bool stroke: true
        property real alpha: 1.0
        property real halfWidth: width/2
        //antialiasing: true

        onWidthChanged: requestPaint()
        onHalfWidthChanged: requestPaint()

        onPaint: {
            var ctx = cable.getContext('2d');
            ctx.fillStyle = Qt.rgba(1, 0, 0, 1);    //red

            //clear the viewport. This seems to be key to animating a redraw of the line
            //not driven by a change in the frame size
            ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

            var halfConnectorHeight = leftUSBPlug.height/2
            var halfHeight = height/2
            var quarterWidth = halfWidth/2
            var eighthWidth = halfWidth/4
            var sixteenthWidth = halfWidth/8
            var thirtysecondWidth = halfWidth/16

            ctx.save();
            ctx.strokeStyle = cable.strokeStyle;
            ctx.fillStyle = cable.fillStyle;
            ctx.lineWidth = cable.lineWidth;

            //for debugging
            //ctx.fillRect(0, 0, width, height)
            //ctx.strokeRect(0,0, width, height)


            ctx.beginPath();
            ctx.moveTo(width/2, cable.top)
            ctx.lineTo(cable.width/2, cable.bottom)

            ctx.moveTo(0,halfConnectorHeight);
            //a bit of rigidity from the cable on the left
            ctx.quadraticCurveTo(sixteenthWidth,halfConnectorHeight,eighthWidth,halfConnectorHeight*1.5);

            //bottom middle of the span
            ctx.quadraticCurveTo(halfWidth, height, width - eighthWidth,halfConnectorHeight*1.5)

            //a bit of rigidity on the right
            ctx.quadraticCurveTo(width - sixteenthWidth,halfConnectorHeight,width,halfConnectorHeight);

            ctx.stroke();
            ctx.restore();
        }
    }
    Image {
        id: leftUSBPlug
        width: connector.width/5; height: connector.height/4
        x:  connector.x + connector.width/3
        anchors{ verticalCenter: connector.verticalCenter }/*; verticalCenterOffset: 9}*/
        source: "leftUSBPlug.svg"

        MouseArea {
            anchors { fill: parent }
            onClicked: {
                if (!isConnected){
                    isConnected = true;
                    connect.start()

                }
                else{
                    isConnected = false;
                    disconnect.start()
                }
            }
        }

        SequentialAnimation {
            running: false
            id: connect

            NumberAnimation {
                target: leftUSBPlug
                property: "x";
                from: leftUSBPlug.x
                to: connector.x - connector.width/12
                easing.type: Easing.InQuad;
                duration: 500
            }

            //swing left
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:cable.width/2;
                to: cable.width/4;
                easing.type: Easing.OutQuad;
                duration: 500
            }

            //swing right
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:cable.width/4;
                to: 3* cable.width/4;
                easing.type: Easing.OutQuad;
                duration: 750
            }

            //swing back to center
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:3* cable.width/4;
                to: cable.width/2;
                easing.type: Easing.OutQuad;
                duration: 1000
            }
        }

        SequentialAnimation {
            id: disconnect
            running: false

            NumberAnimation {
                target: leftUSBPlug
                property: "x";
                from: leftUSBPlug.x
                to: connector.x + connector.width/4
                easing.type: Easing.OutQuad;
                duration: 500
            }

            //swing right
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:cable.width/2;
                to: 5* cable.width/8;
                easing.type: Easing.OutQuad;
                duration: 500
            }

            //swing left
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:5*cable.width/8;
                to: 3*cable.width/8;
                easing.type: Easing.OutQuad;
                duration: 750
            }

            //swing back to center
            PropertyAnimation {
                target: cable;
                property: "halfWidth";
                from:3*cable.width/8;
                to: 5*cable.width/16;
                easing.type: Easing.OutQuad;
                duration: 1000
            }
        }
    }
}




