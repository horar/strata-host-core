/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12
import Qt.labs.platform 1.1 as QtLabsPlatform

import "js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/login_utilities.js" as SessionUtils
import "qrc:/js/platform_filters.js" as PlatformFilters
import "qrc:/js/core_update.js" as CoreUpdate
import "qrc:/partial-views/platform-view"

// imports below must be qrc:/ due to qrc aliases for debug/release differences
import "qrc:/partial-views/control-view-creator"
import "qrc:/partial-views/debug-bar"

import "partial-views/notifications"

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0
import tech.strata.theme 1.0
import tech.strata.notifications 1.0

SGWidgets.SGMainWindow {
    id: mainWindow

    readonly property int defaultWidth: 1024
    readonly property int defaultHeight: 768-40 // -40 for Win10 taskbar height

    visible: true
    width: defaultWidth
    height: defaultHeight
    minimumHeight: defaultHeight
    minimumWidth: defaultWidth
    title: Qt.application.displayName

    property alias notificationsInbox: notificationsInbox

    signal initialized()
    property bool hcsReconnecting: false

    function resetWindowSize()
    {
        if (mainWindow.visibility === Window.FullScreen) {
            mainWindow.showNormal()
        }

        mainWindow.width = defaultWidth
        mainWindow.height = defaultHeight
    }

    QtLabsPlatform.MenuBar {
        QtLabsPlatform.Menu {
            visible: Qt.platform.os === "osx" // only for MacOS which will place it in its own About menu
            QtLabsPlatform.MenuItem {
                text: qsTr("&About")
                onTriggered:  {
                    showAboutWindow()
                }
            }
        }
    }

    Shortcut {
        id: enterFullScreenMode
        sequence: StandardKey.FullScreen
        onActivated: {
            if (mainWindow.visibility === Window.FullScreen) {
                mainWindow.showNormal()
            } else {
                mainWindow.showFullScreen()

                Notifications.createNotification(
                            qsTr("Press '%1' to exit full screen").arg(escapeFullScreenMode.sequence),
                            Notifications.Info,
                            "current",
                            {
                                "singleton": true,
                                "timeout": 4000
                            }
                            )
            }
        }
    }

    Shortcut {
        id: escapeFullScreenMode

        enabled: mainWindow.visibility === Window.FullScreen
        sequence: "Escape"
        onActivated: {
            mainWindow.showNormal()
        }
    }

    Component.onCompleted: {
        console.log(Logger.devStudioCategory, "Initializing")
        NavigationControl.init(statusBarLoader, stackContainer, sdsModel.resourceLoader, mainWindow)
        Help.registerWindow(mainWindow, stackContainer)
        if (!PlatformSelection.isInitialized) {
            PlatformSelection.initialize(sdsModel)
        }
        if (!CoreUpdate.isInitialized) {
            CoreUpdate.initialize(sdsModel, updateLoader)
        }
        initialized()
    }

    onClosing: {
        // QTBUG-45262 - 'close.accepted = false' is ignored on MacOS; fixed in further 5.14 releases
        if (controlViewCreatorLoader.active && controlViewCreatorLoader.item.blockWindowClose(function (){mainWindow.close()})) {
            close.accepted = false
            return
        } else {
            // Halts CVC logging which can cause issues on destruction
            controlViewCreatorLoader.visible = false
        }

        SessionUtils.close_session((sessionClosed) => {
                                       if (sessionClosed) {
                                           // block window close for 100ms to give time for asynchronous XHR to send
                                           close.accepted = false
                                           waitForSessionClose.start()
                                           return
                                       } else {
                                           // End session with HCS
                                           sdsModel.strataClient.sendRequest("unregister_client", {});
                                           if (SessionUtils.settings.rememberMe === false) {
                                               SessionUtils.settings.clear()
                                           }
                                       }
                                   })
    }

    Timer {
        id: waitForSessionClose
        interval: 100
        onTriggered: {
            mainWindow.close()
        }
    }

    Connections {
        target: sdsModel
        onHcsConnectedChanged: {
            if (sdsModel.hcsConnected) {
                NavigationControl.updateState(NavigationControl.events.CONNECTION_ESTABLISHED_EVENT)
                if (hcsReconnecting) {
                    Notifications.createNotification(`Host Controller Service reconnected`,
                                                     Notifications.Info,
                                                     "all",
                                                     {
                                                         "singleton": true,
                                                         "timeout": 0
                                                     })
                    hcsReconnecting = false
                }
            } else {
                Notifications.createNotification(`Host Controller Service disconnected`,
                                                 Notifications.Critical,
                                                 "all",
                                                 {
                                                     "description": "In most cases HCS will immediately reconnect automatically. If not, close all instances of Strata and re-open.",
                                                     "singleton": true
                                                 })
                hcsReconnecting = true
                PlatformFilters.clearActiveFilters()
                PlatformSelection.logout()
                SessionUtils.initialized = false
                NavigationControl.updateState(NavigationControl.events.CONNECTION_LOST_EVENT)
            }
        }
    }

    Connections {
        target: sdsModel.firmwareUpdater

        onJobStarted: {
            PlatformSelection.setPlatformSelectorModelPropertyRev(deviceId, "program_controller", true)
            PlatformSelection.setPlatformSelectorModelPropertyRev(deviceId, "program_controller_progress", 0.0)
            PlatformSelection.setPlatformSelectorModelPropertyRev(deviceId, "program_controller_error_string", "")
        }

        onJobProgressUpdate: {
            PlatformSelection.setPlatformSelectorModelPropertyRev(deviceId, "program_controller_progress", progress)
        }

        onJobFinished: {
            PlatformSelection.setPlatformSelectorModelPropertyRev(deviceId, "program_controller", false)
        }

        onJobError: {
            PlatformSelection.setPlatformSelectorModelPropertyRev(deviceId, "program_controller_error_string", errorString)
        }
    }

    Connections {
        target: (sdsModel.bleDeviceModel === undefined)?(null):(sdsModel.bleDeviceModel)
        onTryConnectFinished: {
            if (errorString.length > 0) {
                showBleNotification("BLE device connection atempt failed", errorString);
            }
        }

        onTryDisconnectFinished: {
            if (errorString.length > 0) {
                showBleNotification("BLE device disconnection atempt failed", errorString);
            }
        }

        function showBleNotification(title, description) {
            Notifications.createNotification(
                        title,
                        Notifications.Warning,
                        "current",
                        {
                            "description": description,
                            "iconSource": "qrc:/sgimages/exclamation-circle.svg",
                        }
                        )
        }
    }

    Loader {
        id: updateLoader
        active: false
        anchors {
            centerIn: parent
        }
        width: 450
        height: 400
        visible: active
    }

    ColumnLayout {
        spacing: 0
        anchors.fill: parent

        Loader {
            id: statusBarLoader
            active: false
            Layout.preferredHeight: 40
            Layout.fillWidth: true
            visible: active
        }

        StackLayout {
            id: stackContainer

            property alias mainContainer: mainContainer
            property alias platformViewModel: platformViewModel
            property alias platformViewRepeater: platformViewRepeater

            Loader {
                id: mainContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            ListModel {
                id: platformViewModel
            }

            Repeater {
                id: platformViewRepeater
                model: platformViewModel
                delegate: SGPlatformView {}
            }

            CVCLoader {
                id: controlViewCreatorLoader
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

    NotificationsInbox {
        id: notificationsInbox
        height: mainWindow.height - statusBarLoader.Layout.preferredHeight
        width: 400
        y: statusBarLoader.Layout.preferredHeight
    }

    NotificationsContainer {
        anchors {
            right: parent.right
            bottom: parent.bottom
            top: parent.top
            topMargin: statusBarLoader.Layout.preferredHeight
            bottomMargin: 25
            rightMargin: 20
        }
    }

    Connections {
        id: coreInterfaceConnection
        target: sdsModel.coreInterface

        onPlatformListChanged: {
            //            console.log(Logger.devStudioCategory, "Main: PlatformListChanged: ", platformList)
            if (NavigationControl.navigation_state_ === NavigationControl.states.CONTROL_STATE) {
                PlatformSelection.generatePlatformSelectorModel(platformList)
            }
        }

        onConnectedPlatformListChanged: {
            //            console.log(Logger.devStudioCategory, "Main: ConnectedPlatformListChanged: ", connectedPlatformList)
            if (NavigationControl.navigation_state_ === NavigationControl.states.CONTROL_STATE && PlatformSelection.platformSelectorModel.platformListStatus === "loaded") {
                Help.closeTour()
                PlatformSelection.parseConnectedPlatforms(connectedPlatformList)
            }
        }

        onUpdateInfoReceived: {
            if (NavigationControl.navigation_state_ === NavigationControl.states.CONTROL_STATE) {
                CoreUpdate.parseUpdateInfo(payload)
            }
        }
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(mainWindow, "qrc:partial-views/about-popup/DevStudioAboutWindow.qml")
    }

    SGDebugBar {
        id: debugBar
        anchors {
            fill: parent
        }
    }
}
