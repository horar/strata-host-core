import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import "js/navigation_control.js" as NavigationControl
import "js/uuid_map.js" as UuidMap
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/login_utilities.js" as SessionUtils
import "qrc:/partial-views"
import "qrc:/partial-views/debug-bar"

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0

SGWidgets.SGMainWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    minimumHeight: 768-40 // -40 for Win10 taskbar height
    minimumWidth: 1024
    title: Qt.application.displayName

    signal initialized()

    Component.onCompleted: {
        console.log(Logger.devStudioCategory, "Initializing")
        NavigationControl.init(flipable, controlContainer, contentContainer, statusBarContainer)
        Help.registerWindow(mainWindow)
        if (!PlatformSelection.isInitialized) { PlatformSelection.initialize(coreInterface, documentManager) }
        initialized()
    }

    onClosing: {
        SessionUtils.close_session()

        // End session with HCS
        coreInterface.unregisterClient();

        // Destruct components dynamically created by NavigationControl
        NavigationControl.removeView(statusBarContainer)
        NavigationControl.removeView(controlContainer)
        NavigationControl.removeView(contentContainer)
    }

    Column {
        id: view
        spacing: 0
        anchors.fill: parent

        Rectangle {
            id: statusBarContainer
            height: visible ? 40 : 0
            width: parent.width

            property real windowHeight: mainWindow.height  // for centering popups spawned from the statusbar
            property bool showDebug: false;  // for linking debug in status bar to the debug bar
        }

        Flipable {
            id: flipable
            height: parent.height - statusBarContainer.height
            width: parent.width

            property bool flipped: false
            property real statusBarHeight: statusBarContainer.height // for spawning drawers in right position

            front: SGControlContainer { id: controlContainer }
            back: SGContentContainer { id: contentContainer }

            transform: Rotation {
                id: rotation
                origin {
                    x: flipable.width/2;
                    y: flipable.height/2
                }
                axis {
                    x: 0;
                    y: -1;
                    z: 0
                }    // set axis.y to 1 to rotate around y-axis

                angle: 0    // the default angle
            }

            states: State {
                name: "back"
                PropertyChanges { target: rotation; angle: 180 }
                when: flipable.flipped
            }

            transitions: Transition {
                NumberAnimation { target: rotation; property: "angle"; duration: 400 }
            }
        }
    }

    Connections {
        id: coreInterfaceConnection
        target: coreInterface

        onPlatformListChanged: {
//            console.log(Logger.devStudioCategory, "Main: PlatformListChanged: ", list)
            if (NavigationControl.context["is_logged_in"] === true) {
                PlatformSelection.populatePlatforms(list)
                PlatformSelection.platformListReceived = true
            }
        }

        onConnectedPlatformListChanged: {
//            console.log(Logger.devStudioCategory, "Main: ConnectedPlatformListChanged: ", list)
            if (NavigationControl.context["is_logged_in"] === true && PlatformSelection.platformListReceived) {
                Help.closeTour()
                PlatformSelection.parseConnectedPlatforms(list)
            }
        }
    }

    SGDebugBar {
        anchors {
            fill: parent
        }
    }
}
