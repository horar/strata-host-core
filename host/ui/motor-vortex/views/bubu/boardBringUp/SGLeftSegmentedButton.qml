import QtQuick 2.0
import QtQuick.Controls 2.0
import "qrc:/views/bubu/Control.js" as BubuControl

Button {
    id:leftButton
    width:100
    height:40
    property var tabName: ""
    property int tabIndex: 0
    property var portName: ""
    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 10;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 20;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;

    checkable: true
    checked:true

    font.pixelSize: mediumFontSize
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
        leftButtonCanvas.requestPaint();

    }
    onClicked: {
        BubuControl.setPort(portName);
        BubuControl.printCommand();
        bitView.currentIndex = tabIndex;
    }


}
