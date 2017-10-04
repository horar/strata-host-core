import QtQuick 2.7

Rectangle {
    id: device
    height: parent.height*.4
    width: parent.width *.75 //allow a little space on the right of the screen
    color:"transparent"

    property int verticalOffset: 0
    anchors{ left:parent.left
        verticalCenter: parent.verticalCenter
        verticalCenterOffset: verticalOffset }

    Image {
        id:deviceOutline
        source: "deviceOutline.svg"
        anchors.fill:parent
        mipmap: true

    }

}
