import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/login_utilities.js" as SessionUtils
import "qrc:/partial-views"
import "qrc:/partial-views/debug-bar"
import "qrc:/partial-views/platform-view"
import "qrc:/js/platform_filters.js" as PlatformFilters
import "qrc:/js/core_update.js" as CoreUpdate

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0
import tech.strata.theme 1.0

SGWidgets.SGMainWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    minimumHeight: 768-40 // -40 for Win10 taskbar height
    minimumWidth: 1024
    title: Qt.application.displayName

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
        if (!CoreUpdate.isInitialized) {
            CoreUpdate.initialize(sdsModel.coreInterface, updateContainer)
        }
        initialized()
    }

    onClosing: {
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

    Item {
        id: updateContainer
        anchors {
            centerIn: parent
        }
        width: 500
        height: 300
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

            ControlViewDevContainer {
                id: controlViewDevContainer
            }
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

        onUpdateInfoReceived: {
            if (NavigationControl.navigation_state_ === NavigationControl.states.CONTROL_STATE) {
                CoreUpdate.parseUpdateInfo(payload)
            }
        }
    }

    SGDebugBar {
        anchors {
            fill: parent
        }
    }
}
