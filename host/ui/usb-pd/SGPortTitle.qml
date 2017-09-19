import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle {
    id: container
    width: container.width; height: container.height
    property alias text: portName.text   
    color: "transparent"

    Label {
        id: portName
         width: 17
        font {pointSize: parent.width/4.5 > 0 ? parent.width/4.5 : 1;bold: true}
        color: "green"
        anchors {verticalCenter: container.verticalCenter}
      }

    Rectangle {
        id: divider
        color: "black"
        opacity: 1.0
        width: container.width/15; height:container.height/1.4
        anchors{ right:parent.right; top:parent.top; topMargin: parent.width/4}
    }

}
