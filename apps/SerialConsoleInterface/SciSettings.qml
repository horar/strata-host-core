/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
pragma Singleton

import QtQuick 2.12
import Qt.labs.settings 1.1 as QtLabsSettings


Item {
    id: root

    property int maxCommandsInScrollback: defaultMaxCommandsInScrollback
    property bool commandsInScrollbackUnlimited: defaultCommandsInScrollbackUnlimited
    property int maxCommandsInHistory: defaultMaxCommandsInHistory
    property bool commandsCondensedAtStartup: defaultcommandsCondensedAtStartup
    property bool backupFirmware: defaultBackupFirmware
    property bool relasePortOfUnrecongizedDevice: defaultRelasePortOfUnrecongizedDevice
    property int maxInputLines: 500
    property var firmwarePathList: []
    property int maxFirmwarePathList: 10
    property string lastSavedFirmwarePath

    readonly property int defaultMaxCommandsInScrollback: 5000
    readonly property bool defaultCommandsInScrollbackUnlimited: false
    readonly property int defaultMaxCommandsInHistory: 20
    readonly property bool defaultcommandsCondensedAtStartup: false
    readonly property bool defaultBackupFirmware: true
    readonly property bool defaultRelasePortOfUnrecongizedDevice: false

    QtLabsSettings.Settings {
        category: "App"
        property alias maxCommandsInScrollback: root.maxCommandsInScrollback
        property alias commandsInScrollbackUnlimited: root.commandsInScrollbackUnlimited
        property alias maxCommandsInHistory: root.maxCommandsInHistory
        property alias commandsCondensedAtStartup: root.commandsCondensedAtStartup
        property alias backupFirmware: root.backupFirmware
        property alias firmwarePathList: root.firmwarePathList
        property alias lastSavedFirmwarePath: root.lastSavedFirmwarePath
        property alias relasePortOfUnrecongizedDevice: root.relasePortOfUnrecongizedDevice
    }

    function resetToDefaultValues() {
        maxCommandsInScrollback = defaultMaxCommandsInScrollback
        commandsInScrollbackUnlimited = defaultCommandsInScrollbackUnlimited
        maxCommandsInHistory = defaultMaxCommandsInHistory
        commandsCondensedAtStartup = defaultcommandsCondensedAtStartup
        relasePortOfUnrecongizedDevice = defaultRelasePortOfUnrecongizedDevice
    }
}
