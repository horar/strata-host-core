import QtQuick 2.12
import QtQml 2.12

QtObject {
    id: main_palette_
    // BASE STRATA COLORS
    readonly property color green:          "#33b13b"
    readonly property color dark:           "#252627"
    readonly property color darkGray:       "#929393"
    readonly property color gray:           "#c2c2c2"
    readonly property color lightGray:      "#e1e1e1"
    readonly property color white:          "#ffffff"
    readonly property color black:          "#000000"

    // ADDITIONAL COLORS
    readonly property color orange:         "#f57900"
    readonly property color red:            "#cc0000"
    readonly property color blue:           "#1f5087"
    readonly property color error:          red
    readonly property color warning:        orange
    readonly property color success:        "#28a745"
}
