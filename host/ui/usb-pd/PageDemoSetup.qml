import QtQuick 2.0

Item {
    Text{
        font.family: "helvetica"
        font.pointSize: 36
        text:"Demo Setup"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
    }
    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
        source: "./images/CES_Demo_Setup.PNG"
    }

}
