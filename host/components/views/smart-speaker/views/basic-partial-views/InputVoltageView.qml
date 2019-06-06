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

    PortStatBox{
        id:inputVoltage
        height:100
        anchors.verticalCenter: parent.verticalCenter
        label: "INPUT VOLTAGE"
        color:"transparent"
        valueSize: 72
        textColor: "white"
        portColor: "#2eb457"
        labelColor:"white"
    }

}
