pragma Singleton

import QtQuick 2.12
import Qt.labs.settings 1.1 as QtLabsSettings

Item {
    id: root

    property int fontPixelSize: defaultFontPixelSize

    readonly property int defaultFontPixelSize: 13

    QtLabsSettings.Settings {
        category: "SGWidgets"
        property alias fontPixelSize: root.fontPixelSize
    }

    function resetToDefaultValues() {
        fontPixelSize = defaultFontPixelSize
    }
}
