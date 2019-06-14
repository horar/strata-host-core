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

    signal activated(string selectedDevice)

    Text{
        id:deviceName
        text:"available devices:"
        color:"white"
        font.pixelSize: 24
        anchors.top:parent.top
        anchors.topMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
    }

    SGComboBox{
        id: deviceCombo
        anchors.top: deviceName.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        model:  ["Device One", "Device Two", "Device Three"]
        boxColor: "silver"

        onActivated:{
            //set the name of the selected device on the other side
            parent.activated(currentText);
        }

    }


}
