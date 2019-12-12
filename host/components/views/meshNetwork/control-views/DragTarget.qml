import QtQuick 2.0

DropArea{
    id:targetDropArea
    x: 10; y: 10
    width: nodeWidth; height: nodeHeight

    property string nodeType: "light"
    property color savedColor: "transparent"
    property alias radius: dropAreaRectangle.radius
    property alias color: dropAreaRectangle.color
    property bool acceptsDrops: true

    signal clearTargetsOfColor(color inColor, string name)

    onEntered:{
        console.log("entered drop area")
        savedColor = dropAreaRectangle.color
        if (acceptsDrops){
            dropAreaRectangle.color = drag.source.color;
        }
        infoTextRect.visible = true;
    }

    onExited: {
        console.log("exited drop area")
        dropAreaRectangle.color = savedColor
        infoTextRect.visible = false;
    }

    onDropped: {
        console.log("item dropped with color",drag.source.color)
        if (acceptsDrops){
            dropAreaRectangle.color = drag.source.color;
            drag.source.model = nodeType;
            savedColor = dropAreaRectangle.color
        }
        infoTextRect.visible = false;

        //signal to tell other drop targets using the same color to clearConnectionsButton
        clearTargetsOfColor(dropAreaRectangle.color, objectName);
    }

    Rectangle {
        id:dropAreaRectangle
        anchors.fill:parent
        radius:height/2
        color: "transparent"
        border.color:{
            return "white"
        }
        border.width: 5

    }




    Rectangle{
        id: infoTextRect
//        height: 50
//        width:175
//        anchors.top: dropAreaRectangle.top
//        anchors.left: dropAreaRectangle.right
//        anchors.leftMargin: 10
        anchors.left: infoText.left
        anchors.leftMargin: -10
        anchors.right:infoText.right
        anchors.rightMargin:-10
        anchors.top: infoText.top
        anchors.topMargin: -5
        anchors.bottom:infoText.bottom
        anchors.bottomMargin: -10
        color:"white"
        opacity:.4
        radius:7
        visible: false
    }

    Text{
        id:infoText
        height:50
        //width:100
        text: targetDropArea.nodeType
        font.pixelSize: 48
        //fontSizeMode: Text.Fit
        //anchors.centerIn: infoTextRect
        anchors.top: dropAreaRectangle.top
        anchors.left: dropAreaRectangle.right
        anchors.leftMargin: 10
        visible: infoTextRect.visible
    }


}

