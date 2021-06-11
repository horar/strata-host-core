import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import "js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/login_utilities.js" as SessionUtils
import "qrc:/js/platform_filters.js" as PlatformFilters
import "qrc:/partial-views/platform-view"

// imports below must be qrc:/ due to qrc aliases for debug/release differences
import "qrc:/partial-views/control-view-creator"
import "qrc:/partial-views/debug-bar"

import "partial-views/notifications"

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0
import tech.strata.theme 1.0
import tech.strata.notifications 1.0
import tech.strata.signals 1.0

SGWidgets.SGMainWindow {
    id: mainWindow

    visible: true
    x: Screen.width / 2 - mainWindow.width / 2
    y: Screen.height / 2 - mainWindow.height / 2
    width: 1200
    height: 900
    minimumHeight: 768-40 // -40 for Win10 taskbar height
    minimumWidth: 1024
    title: Qt.application.displayName

    property alias notificationsInbox: notificationsInbox

    signal initialized()
    property bool hcsReconnecting: false

    function resetWindowSize()
    {
        mainWindow.width = 1200
        mainWindow.height = 900
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
            PlatformSelection.initialize(sdsModel.coreInterface)
        }
        initialized()
    }

    onClosing: {
        if (controlViewCreatorLoader.active && controlViewCreatorLoader.item.blockWindowClose()) {
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
                                           sdsModel.coreInterface.unregisterClient();
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
                                                         "timeout":0
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
            //            console.log(Logger.devStudioCategory, "Main: PlatformListChanged: ", list)
            if (NavigationControl.navigation_state_ === NavigationControl.states.CONTROL_STATE) {
                PlatformSelection.generatePlatformSelectorModel(list)
            }
        }

        onConnectedPlatformListChanged: {
            //            console.log(Logger.devStudioCategory, "Main: ConnectedPlatformListChanged: ", list)
            if (NavigationControl.navigation_state_ === NavigationControl.states.CONTROL_STATE && PlatformSelection.platformSelectorModel.platformListStatus === "loaded") {
                Help.closeTour()
                PlatformSelection.parseConnectedPlatforms(list)
            }
        }
    }

    /*
      This Connections is for
      a) the cvc blocking a logout state due to unsaved changes
      b) the cvc executing a logout after the unsaved changes are resolved
    */
    Connections {
        target: Signals

        onRequestClose: {
            if (controlViewCreatorLoader.active) {
                controlViewCreatorLoader.cvcCloseRequested = true
                controlViewCreatorLoader.cvcLoggingOut = isLoggingOut
                if (controlViewCreatorLoader.item.blockWindowClose() === false) {
                    Signals.closeFinished(isLoggingOut)
                }
            } else {
               Signals.closeFinished(isLoggingOut)
            }
        }

        onCloseFinished: {
            if (controlViewCreatorLoader.active) {
                controlViewCreatorLoader.cvcCloseRequested = false
                controlViewCreatorLoader.active = false
                let data = {"index": NavigationControl.stack_container_.count-2}
                NavigationControl.updateState(NavigationControl.events.SWITCH_VIEW_EVENT, data)
            }
            if (isLoggingOut) {
                Signals.logout()
                PlatformFilters.clearActiveFilters()
                NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT)
                SessionUtils.logout()
                PlatformSelection.logout()
                sdsModel.coreInterface.unregisterClient()
            }
        }
    }

    SGDebugBar {
        id: debugBar
        anchors {
            fill: parent
        }
    }
}
