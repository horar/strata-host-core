import QtQuick 2.0
import QtQuick.Controls 2.0

Button {
    id: middleButton
    property var tabName
    checkable: true
    text: "two"


    contentItem: Text {
        text: middleButton.text
        font.family:"helvetica"
        font.pointSize:16
        opacity: enabled ? 1.0 : 0.3
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Canvas{
        id:middleButtonCanvas
        anchors.fill:parent
        onPaint:{
            //console.log("repainting")
            var ctx = getContext("2d");
            var theFillColor = parent.checked ? "grey" :"lightgrey"
            var eighthWidth = parent.width/8
            var theLineWidth = 1
            var theLeft = 0
            var theTop = theLineWidth
            var theBottom = height - theLineWidth
            ctx.fillStyle = theFillColor

            ctx.beginPath();
            ctx.moveTo(theLeft, theTop)
            ctx.moveTo(width,theTop);
            ctx.lineTo(width,theBottom);
            ctx.lineTo(theLeft,theBottom);
            ctx.lineTo(theLeft,theTop);
            ctx.closePath();
            ctx.fill(); //fill the outline with grey
            ctx.stroke();   //stroke the outside with black
        }
    }

    onCheckedChanged: {
        middleButtonCanvas.requestPaint()
        if(checked)
            implementationInterfaceBinding.setRedriverLoss(9)
    }


}


