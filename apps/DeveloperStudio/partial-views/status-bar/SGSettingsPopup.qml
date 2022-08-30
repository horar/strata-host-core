/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.logconf 1.0 as LcuPlugin
import "../"
import "../general/"

SGStrataPopup {
    id: root
    modal: true
    visible: true
    headerText: "General Settings"
    closePolicy: Popup.CloseOnEscape
    focus: true
    width: 400
    x: container.width/2 - root.width/2
    y: mainWindow.height/2 - root.height/2

    onClosed: {
        parent.active = false
    }

    contentItem: ColumnLayout {
        id: column
        width: parent.width - 40

        SGText {
            text: "Platform View Settings"
            fontSizeMultiplier: 1.3
        }

        Rectangle {
            // divider
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#666"
        }

        SGSettingsCheckbox {
            text: "Open/show platform tab when platform is connected"
            checked: userSettings.autoOpenView

            onCheckedChanged: {
                userSettings.autoOpenView = checked
                userSettings.saveSettings()
            }
        }

        SGSettingsCheckbox {
            text: "Close platform tab when platform is disconnected"
            checked: userSettings.closeOnDisconnect

            onCheckedChanged: {
                userSettings.closeOnDisconnect = checked
                userSettings.saveSettings()
            }
        }

        SGText {
            text: "Notification Settings"
            fontSizeMultiplier: 1.3
        }

        Rectangle {
            // divider
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#666"
        }

        SGSettingsCheckbox {
            text: "Notify me when newer versions of firmware or control views are available"
            checked: userSettings.notifyOnFirmwareUpdate

            onCheckedChanged: {
                userSettings.notifyOnFirmwareUpdate = checked
                userSettings.saveSettings()
            }
        }

        SGSettingsCheckbox {
            text: "Notify me when a collateral document is updated"
            checked: userSettings.notifyOnCollateralDocumentUpdate

            onCheckedChanged: {
                userSettings.notifyOnCollateralDocumentUpdate = checked
            }
        }

        SGSettingsCheckbox {
            text: "Notify me when a platform is connected/disconnected"
            checked: userSettings.notifyOnPlatformConnections

            onCheckedChanged: {
                userSettings.notifyOnPlatformConnections = checked
                userSettings.saveSettings()
            }
        }

        SGText {
            text: "Logging configuration"
            fontSizeMultiplier: 1.3
        }

        Rectangle {
            // divider
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#666"
        }

        LcuPlugin.LogLevel {
            id: logLevel
            Layout.fillWidth: true
            fileName: ""
        }
    }
}
