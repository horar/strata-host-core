import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Text {
    id: text

    property bool alternativeColorEnabled: false
    property color implicitColor: "black"
    property color alternativeColor: "white"
    property real fontSizeMultiplier: 1.0

    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * fontSizeMultiplier
    color: alternativeColorEnabled ? alternativeColor : implicitColor
}
