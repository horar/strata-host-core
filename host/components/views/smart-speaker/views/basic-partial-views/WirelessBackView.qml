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

    signal activated(string selectedNetwork)

    Component.onCompleted:{
        platformInterface.get_wifi_connections.update();
       }

    property var deviceCount: platformInterface.wifi_connections.count;
    onDeviceCountChanged:{
        comboListModel.clear();
        for (var i=0; i<deviceCount; i++){
            comboListModel.append(platformInterface.wifi_connections.devices[i]);
        }
    }

    Text{
        id:networkName
        text:"available networks:"
        color:"white"
        font.pixelSize: 24
        anchors.top:parent.top
        anchors.topMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ListModel{
        id:comboListModel
    }

    SGComboBox{
        id: networkCombo
        anchors.top: networkName.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        model:  comboListModel
        boxColor: "silver"

        onActivated:{
            //set the name of the selected device on the other side
            console.log("chose value",currentText)
            PlatformInterface.connect_wifi.update(currentText,"1234");      //sending 1234 in lieu of password for now
            parent.activated(currentText);
        }

    }

}
