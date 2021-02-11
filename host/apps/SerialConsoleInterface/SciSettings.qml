pragma Singleton

import QtQuick 2.12
import Qt.labs.settings 1.1 as QtLabsSettings


Item {
    id: root

    property int maxCommandsInScrollback: defaultMaxCommandsInScrollback
    property bool commandsInScrollbackUnlimited: defaultCommandsInScrollbackUnlimited
    property int maxCommandsInHistory: defaultMaxCommandsInHistory
    property string lastSelectedFirmware
    property bool commandsCondensedAtStartup: defaultcommandsCondensedAtStartup

    readonly property int defaultMaxCommandsInScrollback: 5000
    readonly property bool defaultCommandsInScrollbackUnlimited: false
    readonly property int defaultMaxCommandsInHistory: 20
    readonly property bool defaultcommandsCondensedAtStartup: false

    QtLabsSettings.Settings {
        category: "App"
        property alias maxCommandsInScrollback: root.maxCommandsInScrollback
        property alias commandsInScrollbackUnlimited: root.commandsInScrollbackUnlimited
        property alias maxCommandsInHistory: root.maxCommandsInHistory
        property alias lastSelectedFirmware: root.lastSelectedFirmware
        property alias commandsCondensedAtStartup: root.commandsCondensedAtStartup
    }

    function resetToDefaultValues() {
        maxCommandsInScrollback = defaultMaxCommandsInScrollback
        commandsInScrollbackUnlimited = defaultCommandsInScrollbackUnlimited
        maxCommandsInHistory = defaultMaxCommandsInHistory
        commandsCondensedAtStartup = defaultcommandsCondensedAtStartup
    }
}
