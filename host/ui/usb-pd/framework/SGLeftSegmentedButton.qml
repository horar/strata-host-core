import QtQuick 2.0
import QtQuick.Controls 2.0

Button {
    id:leftButton

    property var tabName

    checkable: true
    checked:true

    contentItem: Text {
        text: leftButton.text
        font.family:"helvetica"
        font.pointSize:16
        opacity: enabled ? 1.0 : 0.3
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Canvas{
        id:leftButtonCanvas
        anchors.fill:parent
        onPaint:{
            var ctx = getContext("2d");
            var theFillColor = parent.checked ? "grey" :"lightgrey"
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
