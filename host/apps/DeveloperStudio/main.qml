import QtQuick 2.12
import QtQuick.Controls 2.12
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

SGWidgets.SGMainWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    minimumHeight: 768-40 // -40 for Win10 taskbar height
    minimumWidth: 1024
    title: Qt.application.displayName

    property alias notificationsInbox: notificationsInbox

    signal initialized()

    function resetWindowSize()
    {
        mainWindow.width = 1200
        mainWindow.height = 900
    }

    Component.onCompleted: {
        console.log(Logger.devStudioCategory, "Initializing")
        NavigationControl.init(statusBarContainer, stackContainer, sdsModel.resourceLoader, mainWindow)
        Help.registerWindow(mainWindow, stackContainer)
        if (!PlatformSelection.isInitialized) {
            PlatformSelection.initialize(sdsModel.coreInterface)
        }
        initialized()
    }

    onClosing: {
        if (controlViewCreator.blockWindowClose()) {
            close.accepted = false
            return
        }

        SessionUtils.close_session()

        // End session with HCS
        sdsModel.coreInterface.unregisterClient();

        // Destruct components dynamically created by NavigationControl
        NavigationControl.removeView(statusBarContainer)
        NavigationControl.removeView(mainContainer)
        platformViewModel.clear()

        if (SessionUtils.settings.rememberMe === false) {
            SessionUtils.settings.clear()
        }
    }

    Connections {
        target: sdsModel
        onHcsConnectedChanged: {
            if (sdsModel.hcsConnected) {
                NavigationControl.updateState(NavigationControl.events.CONNECTION_ESTABLISHED_EVENT)
            } else {
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

        Item {
            id: statusBarContainer
            Layout.preferredHeight: 40
            Layout.fillWidth: true

            property real windowHeight: mainWindow.height  // for centering popups spawned from the statusbar
        }

        StackLayout {
            id: stackContainer

            property alias mainContainer: mainContainer
            property alias controlViewDevContainer: controlViewDevContainer
            property alias platformViewModel: platformViewModel
            property alias platformViewRepeater: platformViewRepeater

            Item {
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

            ControlViewCreator {
                id: controlViewCreator
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            
            ControlViewDevContainer {
                id: controlViewDevContainer
            }
        }
    }

    NotificationsInbox {
        id: notificationsInbox
        height: mainWindow.height - statusBarContainer.height
        width: 400
        y: statusBarContainer.height
    }

    NotificationsContainer {
        anchors {
            right: parent.right
            bottom: parent.bottom
            top: parent.top
            topMargin: statusBarContainer.height
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

    SGDebugBar {
        id: debugBar
        anchors {
            fill: parent
        }
    }
}
