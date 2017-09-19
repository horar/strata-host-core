import QtQuick 2.0

Rectangle {
    id: device
    width: parent.width * 0.80; height: parent.height/3
    color:"transparent"
    border{ color: "transparent";width: 2 }
    radius: 10
    property int verticalOffset: 0
    anchors{ horizontalCenter: parent.horizontalCenter
        horizontalCenterOffset: -parent.width * 0.10
        verticalCenter: parent.verticalCenter
        verticalCenterOffset: verticalOffset }

    Image {
        id:deviceOutline
        width:device.width/1.5; height:device.height
        source: "deviceOutline.svg"
        anchors{ left:device.left; verticalCenter: parent.verticalCenter }

    }

}
