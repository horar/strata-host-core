import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    property bool isConnected: false

    Rectangle {
        id: leftDevice
        x: 44
        y: 104
        width: 142
        height: 84
        color: "#dc0404"
    }

    Rectangle {
        id: rightDevice
        x: 452
        y: 104
        width: 162
        height: 84
        color: "#22c800"
    }

    Button {
        id: button
        x: 259
        y: 398
        text: qsTr("Connect")
        font.pointSize: 24
    }

    Rectangle {
        id: connector
        x: 220
        y: 134
        width: 58
        height: 31
        color: "#020d00"

        SequentialAnimation{
            running: false
            id: connect

            NumberAnimation {
                target: connector
                property: "x";
                from: connector.x;
                to: leftDevice.x + leftDevice.width;
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
            running: false
            id: disconnect

            NumberAnimation {
                target: connector
                property: "x";
                from: leftDevice.x + leftDevice.width;
                to: 220;
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

    Canvas {
        id: cable
        x: connector.x + connector.width
        y: connector.y
        anchors.left: connector.right
        anchors.right: rightDevice.left
        height: 100
        property color strokeStyle:  "black"
        property color fillStyle: "#b40000" // red
        property int lineWidth: 2
        property bool fill: true
        property bool stroke: true
        property real alpha: 1.0
        property real halfWidth: width/2
        //antialiasing: true

        onWidthChanged:requestPaint()
        onHalfWidthChanged: requestPaint()

        onPaint: {
            var ctx = cable.getContext('2d');
            ctx.fillStyle = Qt.rgba(1, 0, 0, 1);    //red

            //clear the viewport. This seems to be key to animating a redraw of the line
            //not driven by a change in the frame size
            ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);

            var halfConnectorHeight = connector.height/2
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

    Connections {
        target: button
        onClicked: {
            if (!isConnected){
                isConnected = true;
                connect.start()
                button.text = "Disconnect"
                }
            else{
                isConnected = false;
                button.text = "Connect"
                disconnect.start()
            }
        }
    }

}
