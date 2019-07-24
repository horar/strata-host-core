import QtQuick 2.10
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 0.9

Rectangle {
    id: back
    width: 200
    height:200
    color:"dimgrey"
    opacity:1
    radius: 10

    Component.onCompleted:{
        platformInterface.get_bluetooth_devices.update();
       }

    property var deviceCount: platformInterface.bluetooth_devices.count;
    onDeviceCountChanged:{
        comboListModel.clear();
        for (var i=0; i<deviceCount; i++){
            comboListModel.append(platformInterface.bluetooth_devices.devices[i]);
        }
    }

    Text{
        id:deviceName
        text:"available devices:"
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
        id: deviceCombo
        anchors.top: deviceName.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        model:  comboListModel
        boxColor: "silver"

        onActivated:{
            //set the name of the selected device on the other side
            //actually, that will come from a notification
        }

    }


}
