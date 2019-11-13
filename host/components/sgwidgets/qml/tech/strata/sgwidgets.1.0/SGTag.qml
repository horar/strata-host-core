import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: control

    width: tagBackground.width
    height: tagBackground.height

    property alias text: tagText.text
    property alias radius: tagBackground.radius
    property alias color: tagBackground.color

    Rectangle {
        id: tagBackground
        anchors.fill: tagText
        anchors.margins: -4
        radius: 2
        color: SGWidgets.SGColorsJS.TANGO_BUTTER1
    }

    SGWidgets.SGText {
        id: tagText
        anchors.centerIn: parent
    }
}
