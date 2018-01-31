import QtQuick 2.0
import QtQuick.Controls 2.0

Button {
    property var tabName
    width:100
    height:40
    checkable:true
    text: "three"
    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 10;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 20;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;
    font.pixelSize: mediumFontSize


    background: Canvas{
        id:rightButtonCanvas
        anchors.fill:parent
        onPaint:{
            //console.log("repainting")
            var ctx = getContext("2d");
            var theFillColor = parent.checked ? "grey" :"lightgrey"
            var sevenEighthsWidth = (parent.width*7)/8
            var theLineWidth = 1
            var theTop = theLineWidth
            var theLeft = 0
            var theWidth = parent.width
            var theBottom = height - theLineWidth
            ctx.fillStyle = theFillColor

            ctx.beginPath();
            ctx.moveTo(theLeft,theTop);
            ctx.lineTo(sevenEighthsWidth,theTop)
            ctx.bezierCurveTo(theWidth,theTop,theWidth,theBottom,sevenEighthsWidth,theBottom)
            ctx.lineTo(theLeft,theBottom);
            ctx.lineTo(theLeft,theTop);
            ctx.closePath();
            ctx.fill(); //fill the outline with grey
            ctx.stroke();   //stroke the outside with black
        }
    }

    onCheckedChanged: {
        rightButtonCanvas.requestPaint()
        //console.log("marking canvas as dirty")
    }

    function createTab(inTabName, inParent){
        var component  = Qt.createComponent(inTabName);
        var object = component.createObject(inParent);
        return object
    }

    Component.onCompleted: {
        tabName = createTab(tabName,contentRectangle);
    }
}




