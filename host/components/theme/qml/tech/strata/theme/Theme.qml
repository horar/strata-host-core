pragma Singleton

import QtQuick 2.12
import tech.strata.fonts 1.0

QtObject {
    readonly property color strataGreen:    "#33b13b"
    readonly property color blue:           "#1f5087"
    readonly property color orange:         "#f57900"
    readonly property color plum:           "#ad7fa8"
    readonly property color red:            "#cc0000"
    readonly property color yellow:         "#edd400"

    readonly property color error:          red
    readonly property color warning:        "#ffc107"
    readonly property color success:        "#28a745"
    readonly property color highlight:      "#accef7" // Default Chrome Highlight

    readonly property color light:          "#f8f9fa"
    readonly property color dark:           "#252627"
    readonly property color lightGray:      Qt.lighter(gray, 1.2)
    readonly property color gray:           "#adb5bd"
    readonly property color darkGray:       Qt.darker(gray, 1.4)
    readonly property color white:          "#ffffff"
    readonly property color black:          "#000000"

    readonly property int basePixelSize: 10
    readonly property int h1FontSize: Math.round(basePixelSize * 1.5)
    readonly property int h2FontSize: Math.round(basePixelSize * 1.4)
    readonly property int h3FontSize: Math.round(basePixelSize * 1.3)
}
