import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle{
    border.color: "red"
    color: "yellow"
    anchors.fill: parent

    Button{
        x: 32
        y: 128
        width: 176
        height: 64
        text: "back"
        opacity: 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 72

    }
}
