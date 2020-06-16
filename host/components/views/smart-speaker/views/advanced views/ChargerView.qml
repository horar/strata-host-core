import QtQuick 2.10
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"



    Text{
        id:telemetryText
        font.pixelSize: 24

        anchors.centerIn: parent
        text:"charger"
        color: "black"
    }
}
