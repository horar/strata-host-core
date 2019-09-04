import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: node

    implicitWidth: 40
    implicitHeight: implicitWidth

    property bool highlight: false
    property int delta: 8
    property color color: "black"
    property color iconColor: "#303030"
    property color highlightCircleColor: "#0b55ff"
    property color highlightIconColor: "black"

    property int circleBorderWidth: highlight ? 2 : 1
    property alias source: image.source

    Rectangle {
        anchors {
            fill: parent
            margins: highlight ? 0 : 4
        }

        radius: Math.round(width/2)
        border.width: circleBorderWidth
        border.color: highlight ? highlightCircleColor : node.color

        SGWidgets.SGIcon {
            id: image
            anchors.centerIn: parent
            width: parent.width - 10
            height: width

            iconColor: highlight ? highlightIconColor : node.iconColor
        }
    }
}
