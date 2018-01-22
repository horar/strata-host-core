import QtQuick 2.0

Rectangle{
    id:one
    opacity: 0
    anchors.fill:parent

    Text{
        anchors.centerIn: parent
        text:"one"
        font.pointSize: 100
        font.family: "helvetica"
    }
}
