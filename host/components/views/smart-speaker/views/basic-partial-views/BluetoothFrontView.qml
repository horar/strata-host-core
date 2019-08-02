import QtQuick 2.10
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    width: 200
    height:200
    color:"dimgray"
    opacity:1
    radius: 10

    property var connectedDevice: platformInterface.bluetooth_pairing.id
    property bool pairedDevice: (platformInterface.bluetooth_pairing.value === "paired") ? true : false

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
        text: front.pairedDevice ? connectedDevice : "not paired"
        color:"white"
        font.pixelSize: 24
        anchors.top:bluetoothIcon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

