import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    id: container
    width: container.width; height: container.height
    property alias text: portName.text
    color: "transparent"

    Label {
        id: portName
        width: container.width/2
        font { family: "Helvetica"; bold: true }
        horizontalAlignment: Text.AlignRight
        color: "Grey"
        anchors { verticalCenter: container.verticalCenter; right: parent.right; rightMargin: 10 }
    }

    Component.onCompleted: {
        //adjust font size based on platform
        if (Qt.platform.os === "osx"){
            portName.font.pointSize = parent.width/10 > 0 ? parent.width/10 : 1;
            }
          else{
            fontSizeMode : Label.Fit
            }
    }

    Rectangle {
        id: divider
        color: "black"
        width: container.width*.025; height:container.height*.75
        anchors{right:parent.right; top:parent.top; topMargin: parent.height/8 }
    }
}
