import QtQuick 2.0
import QtQuick.Controls 2.0
import "qrc:/views/bubu/Control.js" as BubuControl

Button {
    id: middleButton
    checkable: true
    width:100
    height:40
    property string pinFunction: ""
    property int tabIndex: 0
    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 10
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 20
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24
    property var portName: "a" //default port is set to "a"
    font.pixelSize: mediumFontSize
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
    }

}
