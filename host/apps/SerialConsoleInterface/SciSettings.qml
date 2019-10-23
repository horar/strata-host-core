pragma Singleton

import QtQuick 2.12
import Qt.labs.settings 1.1 as QtLabsSettings


Item {
    id: root

    property int maxCommandsInScrollback: defaultMaxCommandsInScrollback
    property int maxCommandsInHistory: defaultMaxCommandsInHistory

    readonly property int defaultMaxCommandsInScrollback: 200
    readonly property int defaultMaxCommandsInHistory: 20

    QtLabsSettings.Settings {
        category: "App"
        property alias maxCommandsInScrollback: root.maxCommandsInScrollback
        property alias maxCommandsInHistory: root.maxCommandsInHistory
    }

    function resetToDefaultValues() {
        maxCommandsInScrollback = defaultMaxCommandsInScrollback
        maxCommandsInHistory = defaultMaxCommandsInHistory
    }
}
