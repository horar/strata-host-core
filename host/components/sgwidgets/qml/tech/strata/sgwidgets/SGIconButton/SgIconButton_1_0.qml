import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGButton {
    id: control

    padding: 2
    backgroundOnlyOnHovered: true
    scaleToFit: true

    iconColor: alternativeColorEnabled ? alternativeIconColor : implicitIconColor
    color: alternativeColorEnabled ? "#555555" : implicitColor

    property color implicitIconColor: "black"
    property color alternativeIconColor: "white"
    property bool alternativeColorEnabled: false
}
