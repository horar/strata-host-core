import QtQuick 2.12
import QtQml 2.12

QtObject {
    id: tango_palette_
    // BASE COLORS
    readonly property color green:          "#33b13b"
    readonly property color dark:           "#252627"
    readonly property color blue:           "#1f5087"

    // ADDITIONAL COLORS
    readonly property color chocolate:      "#e9b96e"
    readonly property color plum:           "#ad7fa8"
    readonly property color scarlet_red1:   "#ef2920"
    readonly property color scarlet_red2:   "#cc0000"
    readonly property color orange:         "#f57900"
    readonly property color butter:         "#fce94f"
    readonly property color error:          scarlet_red2
    readonly property color warning:        orange
}
