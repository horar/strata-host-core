pragma Singleton

import QtQuick 2.12
import Qt.labs.settings 1.1 as QtLabsSettings

Item {
    id: root

    property int fontPixelSize: 13

    QtLabsSettings.Settings {
        category: "SGWidgetsSettings"
        property alias fontPixelSize: root.fontPixelSize
    }
}
