import QtQuick 2.0
import QtQuick.Controls 2.0

Rectangle{
    id: rectangle
    border.color: "black"
    color: "red"
    anchors.fill: parent

    Button{
        x: 32
        y: 128
        width: 176
        height: 64
        text: "front"
        opacity: 1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 72

    }
}
