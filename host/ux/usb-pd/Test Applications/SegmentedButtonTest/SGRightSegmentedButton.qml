import QtQuick 2.0
import QtQuick.Controls 2.0

Button {
    property var tabName: Four{}
    width:100
    height:40
    checkable:true
    text: "four"

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
        tabName = createTab("Four.qml",contentRectangle);
    }
}




