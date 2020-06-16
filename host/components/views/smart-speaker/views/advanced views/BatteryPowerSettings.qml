import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"


    Text{
        id:audioPowerTitleText
        font.pixelSize: 24
        anchors.centerIn:parent
        text:"battery"
        color: "black"
    }
}
