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
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import tech.strata.sgwidgets 1.0
import tech.strata.logconf 1.0
import tech.strata.theme 1.0
import tech.strata.fonts 1.0
import "../"
import "../general/"

SGStrataPopup {
    id: root

    property color dividerColor: "#666"

    modal: true
    visible: true
    headerText: "Settings"
    closePolicy: Popup.CloseOnEscape
    focus: true
    height: 400
    width: 400
    x: container.width/2 - root.width/2
    y: mainWindow.height/2 - root.height/2

    onClosed: {
        parent.active = false
    }

    contentItem: TabView {
        id: settingsTabView

        style: TabViewStyle {
                tab: Rectangle {
                    id: tabSelector
                    implicitHeight:40
                    implicitWidth: 120
                    color: tabSelectorMouse.containsMouse ? Qt.darker(Theme.palette.onsemiOrange, 1.15) : styleData.selected ? Theme.palette.onsemiOrange : Theme.palette.darkGray

                    SGText {
                        color: Theme.palette.white
                        text: styleData.title
                        anchors {
                            centerIn: parent
                            verticalCenterOffset: 2
                        }
                    }

                    MouseArea {
                        id: tabSelectorMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            settingsTabView.currentIndex = styleData.index
                        }
                    }
                }
                frame: Rectangle {
                    color: "#f2f2f2"
                    border.color: Theme.palette.lightGray
                }
            }

        Tab {
            id: generalTab
            title: "General"

            ColumnLayout{
                id: column
                anchors.fill: parent
                anchors.margins: 10

                SGText {
                    text: "Platform View Settings"
                    fontSizeMultiplier: 1.3
                }

                Rectangle {
                    // divider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: dividerColor
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
                    color: dividerColor
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
            }
        }

        Tab {
            id: loggingTab
            title: "Loggingg"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10

                SGText {
                    text: "Logging configuration"
                    fontSizeMultiplier: 1.3
                }

                Rectangle {
                    // divider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: dividerColor
                }

                SGText {
                    text: "Strata Developer Studio"
                    fontSizeMultiplier: 1.1
                }

                /*LogLevel {
                    id: logLevelSDS
                    Layout.fillWidth: true
                    fileName: Qt.application.name
                }*/

                SGText {
                    text: "Host Controller Service"
                    fontSizeMultiplier: 1.1
                }

                /*LogLevel {
                    id: logLevelHCS
                    Layout.fillWidth: true
                    fileName: "Host Controller Service"
                }*/

                SGText {
                    text: "Export log files"
                    fontSizeMultiplier: 1.3
                }

                Rectangle {
                    // divider
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: dividerColor
                }

                /*LogExport {
                    id: logExportPane
                    Layout.fillWidth: true
                    appName: Qt.application.name
                }*/
            }
        }
    }
}

