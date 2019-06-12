import QtQuick 2.10
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 1.0

Rectangle {
    id: front
    width: 200
    height:200
    color:"dimgray"
    opacity:1
    radius: 10

    property alias connectedDevice: connectedDeviceText.text

    Image {
        id: bluetoothIcon
        height:3*parent.height/4
        fillMode: Image.PreserveAspectFit
        //width:parent.height/4
        mipmap:true
        anchors.top:parent.top
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        source:"../images/icon-bluetooth.svg"

    }

    Text{
        id:connectedDeviceText
        text:"device"
        color:"white"
        font.pixelSize: 24
        anchors.top:bluetoothIcon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

