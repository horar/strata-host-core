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

    Text{
        id:networkName
        text:"available networks:"
        color:"white"
        font.pixelSize: 24
        anchors.top:parent.top
        anchors.topMargin:10
        anchors.horizontalCenter: parent.horizontalCenter
    }

    SGComboBox{
        id: networkCombo
        anchors.top: networkName.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        model:  ["Network One", "Network Two", "Network Three"]
        boxColor: "silver"

        onActivated:{
            //set the name of the selected device on the other side
            console.log("chose value",currentText)
            parent.activated(currentText);
        }

    }

}
