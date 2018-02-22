import QtQuick 2.0
import QtQuick.Controls 2.0

Button {
    id: middleButton
    checkable: true
    width:100
    height:40

    property color checkedColor: "grey"
    property color unCheckedColor: "lightgrey"

    property color checkedTextColor: "white"
    property color uncheckedTextColor: "grey"

    contentItem: Text {
        text: parent.text
        font: parent.font
        color: parent.checked ? checkedTextColor : uncheckedTextColor
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.Center
    }

    background: Canvas{
        id:middleButtonCanvas
        anchors.fill:parent
        onPaint:{
            //console.log("repainting")
            var ctx = getContext("2d");
            var theFillColor = parent.checked ? checkedColor : unCheckedColor
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
    }

}
