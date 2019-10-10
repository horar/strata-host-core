import QtQuick 2.0

Rectangle{
    id: connnector
    color:"white"
    border.color: "black"
    border.width: 2
    radius: 10
    height: parent.height/2
    width: parent.width
    property int verticalOffset: 0
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: verticalOffset

    Text{
        text: "connector"
        font.family: "helvetica"
        font.pointSize: parent.width/10 > 0 ? parent.width/10 : 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}
