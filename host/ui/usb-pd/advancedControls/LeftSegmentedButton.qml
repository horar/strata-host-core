import QtQuick 2.0
import QtQuick.Controls 2.0

Button {
    id:leftButton
    width:100
    height:40

    property color checkedColor: "grey"
    property color unCheckedColor: "lightgrey"

    property color checkedTextColor: "white"
    property color uncheckedTextColor: "grey"

    checkable: true
    checked:true

    contentItem: Text {
        text: parent.text
        font: parent.font
        color: parent.checked ? checkedTextColor : uncheckedTextColor
        verticalAlignment: Text.AlignVCenter
    }

    background: Canvas{
        id:leftButtonCanvas
        anchors.fill:parent
        onPaint:{
            var ctx = getContext("2d");
            var theFillColor = parent.checked ? checkedColor : unCheckedColor
            var eighthWidth = parent.width/8
            var theLineWidth = 1
            var theTop = theLineWidth
            var theBottom = height - theLineWidth
            ctx.fillStyle = theFillColor

            ctx.beginPath();
            ctx.moveTo(width,theTop);
            ctx.lineTo(width,theBottom);
            ctx.lineTo(eighthWidth,theBottom);
            ctx.bezierCurveTo(0,height,0,0,eighthWidth,theTop)
            ctx.lineTo(width,theTop);
            ctx.closePath();
            ctx.fill(); //fill the outline with grey
            ctx.stroke();   //stroke the outside with black
        }
    }

    onCheckedChanged: {
        leftButtonCanvas.requestPaint()
    }

}
