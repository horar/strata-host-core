import QtQuick 2.0

Rectangle{
    id:pwmTab
    objectName: "pwmTab"
    opacity:0
    anchors.fill:parent
    //color:"transparent"

    Text{
        anchors.centerIn: parent
        text:"pwm"
        font.pointSize: 100
        font.family: "helvetica"
    }
}
