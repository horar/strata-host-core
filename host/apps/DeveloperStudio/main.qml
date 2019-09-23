import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import "js/navigation_control.js" as NavigationControl
import "js/uuid_map.js" as UuidMap
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/statusbar-partial-views"

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
    property variant versionNumberList: Qt.application.version.split(".") // For About Strata Popup
    property string versionNumber: "Strata %1.%2.%3 Build %4".arg(versionNumberList[0]).arg(versionNumberList[1]).arg(versionNumberList[2]).arg(versionNumberList[3])  // For About Strata Popup

    // Debug option(s)
    property bool is_remote_connected: false

    Component.onCompleted: {
        console.log(Logger.devStudioCategory, "Initializing")
        NavigationControl.init(flipable,controlContainer, contentContainer, statusBarContainer)
        Help.registerWindow(mainWindow)
    }

    onClosing: {    // @disable-check M16
        if(is_remote_connected) {
            // sending remote disconnect message to hcs
            var remote_disconnect_json = {
                "hcs::cmd":"remote_disconnect",
                "payload": {}
            }
            coreInterface.sendCommand(JSON.stringify(remote_disconnect_json))

            console.log(Logger.devStudioCategory, "UI -> HCS ", JSON.stringify(remote_disconnect_json))
        }

        var remote_json = {
            "hcs::cmd":"advertise",
            "payload": {
                "advertise_platforms":false
            }
        }
        console.log(Logger.devStudioCategory, "asking hcs to advertise the platforms",JSON.stringify(remote_json))
        coreInterface.sendCommand(JSON.stringify(remote_json))
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
            property alias versionNumber: mainWindow.versionNumber
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

    ListModel {
        id: platformListModel

        // These properties are here (not in platform_selection.js) so they generate their built in signals
        property int currentIndex: 0
        property string selectedClass_id: ""
        property string selectedName: ""
        property string selectedConnection: ""

        Component.onCompleted: {
            //            console.log(Logger.devStudioCategory, "platformListModel component completed");
            if (!PlatformSelection.isInitialized) { PlatformSelection.initialize(this, coreInterface, documentManager) }
        }
    }

    Connections {
        id: coreInterfaceConnection
        target: coreInterface

        onPlatformIDChanged: {
            console.log(Logger.devStudioCategory, "Main: PlatformIDChanged to ", id)

            // Send update to NavigationControl
//            if (UuidMap.uuid_map.hasOwnProperty(id)){
//                console.log(Logger.devStudioCategory, "identified new platform as ", UuidMap.uuid_map[id])
//                var data = { class_id : id }
//                NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
//            }
        }

        onPlatformStateChanged: {
            console.log(Logger.devStudioCategory, "Main: PlatformStateChanged: ", platform_connected_state)
        }

        onRemoteConnectionChanged:{
            // Successful remote connection
            if (result === true){
                is_remote_connected = true
            }
            else {
                is_remote_connected = false
            }
        }

        onPlatformListChanged: {
//            console.log(Logger.devStudioCategory, "Main: PlatformListChanged: ", list)
            if (NavigationControl.context["is_logged_in"] === true) {
                PlatformSelection.populatePlatforms(list)
            }
        }

        onConnectedPlatformListChanged: {
//            console.log(Logger.devStudioCategory, "Main: ConnectedPlatformListChanged: ", list)
            if (NavigationControl.context["is_logged_in"] === true) {
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
