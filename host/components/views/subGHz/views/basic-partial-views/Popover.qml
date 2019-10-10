import QtQuick 2.10
import QtQuick.Controls 2.3

Rectangle{
    id:popoverRect
    height:200
    width:300
    color:"transparent"
    border.width: 0
    //border.color:"red"
    visible:true
    opacity:0
    radius:30

    property string arrowDirection: "left"  //or right, top or bottom
    property alias backgroundColor: arrowBackground.fillColor
    property alias closeButtonColor: closeButton.backgroundColor

    property bool show: false
    onShowChanged: {
        if (show){
            showAnimation.start()
        }
        else{

            hideAnimation.start()
        }
    }

    PropertyAnimation {
        id: showAnimation
        onStarted: popoverRect.visible = true
        target: popoverRect;
        properties: "opacity";
        from: popoverRect.opacity; to: 1;
        duration: 200
    }

    PropertyAnimation {
        id: hideAnimation
        onStopped: popoverRect.visible = false
        target: popoverRect;
        properties: "opacity";
        from: popoverRect.opacity;
        to: 0;
        duration: 100
    }

    Canvas{
        id: arrowBackground
        anchors.fill:parent
        contextType: "2d"

        property color fillColor:popoverRect.backgroundColor
        property int backgroundRadius: 20

        onPaint: {
            //console.log("painting arrow background canvas");
            var context = getContext("2d")
            context.reset();
            context.beginPath();

            var top, left, right, bottom;

            if (arrowDirection == "left") {
                top = arrowBackground.y + 10
                bottom = arrowBackground.y + arrowBackground.height - 10
                right = arrowBackground.x + arrowBackground.width - 10
                left =  arrowBackground.x + 10

                //console.log("top",top,"bottom",bottom,"left",left,"right",right, "radius",radius);
                //console.log("drawing arrow on left");

                context.moveTo(left+backgroundRadius, top);
                context.lineTo(right-backgroundRadius, top);
                context.arcTo(right,top, right, top+backgroundRadius, backgroundRadius);
                context.lineTo(right, bottom-backgroundRadius);
                context.arcTo(right,bottom, right-backgroundRadius,bottom, backgroundRadius);
                context.lineTo(left+backgroundRadius, bottom);
                context.arcTo(left,bottom, left,bottom-backgroundRadius, backgroundRadius);
                context.lineTo(left, (bottom-top)/2 +10);
                context.lineTo(left-10,(bottom-top)/2);
                context.lineTo(left,(bottom-top)/2 - 10)
                context.lineTo(left,top+radius);
                context.arcTo(left,top,left+backgroundRadius,top,backgroundRadius)


            } else if (arrowDirection == "right") {

                top = arrowBackground.y + 10
                bottom = arrowBackground.y + arrowBackground.height - 10
                right = arrowBackground.x + arrowBackground.width - 10
                left =  arrowBackground.x + 10

                context.moveTo(left+backgroundRadius, top);
                context.lineTo(right-backgroundRadius, top);
                context.arcTo(right,top, right, top+backgroundRadius, backgroundRadius);
                context.lineTo(right, (bottom-top)/2 -10);
                context.lineTo(right+10,(bottom-top)/2);
                context.lineTo(right,(bottom-top)/2 + 10)
                context.lineTo(right, bottom-backgroundRadius);
                context.arcTo(right,bottom, right-backgroundRadius,bottom, backgroundRadius);
                context.lineTo(left+backgroundRadius, bottom);
                context.arcTo(left,bottom, left,bottom-backgroundRadius, backgroundRadius);
                context.lineTo(left,top+radius);
                context.arcTo(left,top,left+backgroundRadius,top,backgroundRadius)
            }
            context.closePath();
            //context.lineWidth = 3
            //context.strokeStyle = "white"
            //context.stroke();
            context.fillStyle = fillColor;
            context.fill();
        }
    }

    Button{
        id:closeButton
        anchors.right: parent.right
        anchors.rightMargin:20
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 20
        height:30
        text:"close"

        property color backgroundColor: "red"

        contentItem: Text {
            text: closeButton.text
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            font.pixelSize: 24
            opacity: enabled ? 1.0 : 0.3
            color: closeButton.down ? "black" : "dimgrey"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 80
            color: closeButton.backgroundColor
            border.width: 1
            border.color:"darkgrey"
            radius: 10
        }

        onClicked:{
            show = false;
        }
    }

}
