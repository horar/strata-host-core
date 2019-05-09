import QtQuick 2.12
import tech.strata.fonts 1.0 as StrataFonts

Text {
    id: text

    property bool hasAlternativeColor: false
    property color implicitColor: "black"
    property color alternativeColor: "white"
    property real fontSizeMultiplier: 1.0

    font.family: StrataFonts.Fonts.franklinGothicBook

    font.pixelSize: Qt.application.font.pixelSize * fontSizeMultiplier
    color: hasAlternativeColor ? alternativeColor : implicitColor
}
