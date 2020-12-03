pragma Singleton

import QtQuick 2.12
import tech.strata.fonts 1.0

QtObject {
    readonly property color StrataGreen:    "#33b13b"
    readonly property color Blue:           "#1f5087"
    readonly property color Orange:         "#f57900"
    readonly property color Plum:           "#ad7fa8"

    readonly property color Error:          "#cc0000"
    readonly property color Warning:        "#ffc107"
    readonly property color Success:        "#28a745"

    readonly property color Light:          "#f8f9fa"
    readonly property color Dark:           "#252627"
    readonly property color LightGray:       Qt.lighter(Gray, 1.2)
    readonly property color Gray:           "#adb5bd"
    readonly property color DarkGray:       Qt.darker(Gray, 1.4)
    readonly property color White:          "#fff000"
    readonly property color Black:          "#000000"

    readonly property int basePixelSize: 10
    readonly property int h1FontSize: Math.round(baseFontSize * 1.5)
    readonly property int h2FontSize: Math.round(baseFontSize * 1.4)
    readonly property int h3FontSize: Math.round(baseFontSize * 1.3)

    property Font BaseFont: Font {
        family: Fonts.franklinGothicBook
        pixelSize: basePixelSize
    }
}
