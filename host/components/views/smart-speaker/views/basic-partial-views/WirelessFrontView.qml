import QtQuick 2.9
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 0.9

Rectangle {
    id: root
    width: 200
    height:200
    color:"dimgray"
    opacity:1
    radius: 10

    property alias wirelessName: networkName.text
    property var deviceName: platformInterface.wifi_status.ssid
    property bool connectedDevice: (platformInterface.wifi_status.value === "connected") ? true : false


    Image {
        id: bluetoothIcon
        height:7*parent.height/16
        fillMode: Image.PreserveAspectFit
        mipmap:true
        anchors.centerIn: parent
        source:"../images/icon-wireless.svg"
    }

    Text{
        id:networkName
        text:connectedDevice ? deviceName : "not connected"
        color:"white"
        font.pixelSize: 24
        anchors.top:bluetoothIcon.bottom
        anchors.topMargin:20
        anchors.horizontalCenter: parent.horizontalCenter
    }

}
