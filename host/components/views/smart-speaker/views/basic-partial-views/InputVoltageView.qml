import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    width: 200
    height:200
    color:"dimgray"
    opacity:1
    radius: 10

    property alias inputVoltage: inputVoltage.value

    Text{
        id:inputVoltageText
        text: "input voltage"
        color:"white"
        font.pixelSize: 24
        anchors.top:parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    PortStatBox{
        id:inputVoltage
        height:100
        anchors.verticalCenter: parent.verticalCenter
        label: ""
        color:"transparent"
        valueSize: 72
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
        underlineWidth: 0
        imageHeightPercentage: .5
        bottomMargin: 20
    }

}
