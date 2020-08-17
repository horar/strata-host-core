import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "js/navigation_control.js" as NavigationControl
import "js/uuid_map.js" as UuidMap
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/login_utilities.js" as SessionUtils
import "qrc:/partial-views"
import "qrc:/partial-views/debug-bar"
import "qrc:/partial-views/platform-view"
import "qrc:/js/platform_filters.js" as PlatformFilters

import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.ResourceLoader 1.0
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
        NavigationControl.init(statusBarContainer, stackContainer, sdsModel.resourceLoader)
        Help.registerWindow(mainWindow, stackContainer)
        if (!PlatformSelection.isInitialized) {
            PlatformSelection.initialize(sdsModel.coreInterface, sdsModel.documentManager)
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
            property alias platformViewModel: platformViewModel
            property alias platformViewRepeater: platformViewRepeater
            property alias loadingDialog: loadingDialog

            Item {
                id: mainContainer
                Layout.fillHeight: true
                Layout.fillWidth: true

                Popup {
                    id: loadingDialog
                    width: parent.width
                    height: parent.height
                    modal: true

                    background: Rectangle {
                        width: mainWindow.width
                        height: mainWindow.height
                        color: Qt.rgba(216, 216, 216, 0.75)
                    }

                    AnimatedImage {
                        id: indicator
                        x: parent.width / 2 - width / 2
                        y: parent.height / 2 - height / 2
                        source: "qrc:/images/loading.gif"
                        visible: parent.opened

                        onVisibleChanged: {
                            if (visible) {
                                indicator.playing = true
                            } else {
                                indicator.playing = false
                            }
                        }
                    }
                }
            }

            ListModel {
                id: platformViewModel
            }

            Repeater {
                id: platformViewRepeater
                model: platformViewModel
                delegate: SGPlatformView {}
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
            console.log(Logger.devStudioCategory, "Main: ConnectedPlatformListChanged: ", list)
            if (NavigationControl.navigation_state_ === NavigationControl.states.CONTROL_STATE && PlatformSelection.platformSelectorModel.platformListStatus === "loaded") {
                Help.closeTour()
                PlatformSelection.parseConnectedPlatforms(list)
            }
        }

//        onDownloadViewFinished: {
//            // hacky way to get the class_id from the request.
//            // e.g. "url":"226/control_views/1.1.3/views-hello-strata.rcc"
//            let class_id = payload.url.split("/")[0];
//            PlatformSelection.onControlViewDownloadFinished(class_id)
//        }
    }

    SGDebugBar {
        anchors {
            fill: parent
        }
    }

//    Connections {
//        target: sdsModel.documentManager

//        onPopulateModelsFinished: {
//            PlatformSelection.onControlViewListPopulated(classId)
//        }
//    }

    function getLatestVersion(controlViewModel) {
        let latestVersionTemp;

        if (controlViewCount > 0) {
            latestVersionTemp = copyControlViewObject(controlViewModel, 0);
        } else {
            return null;
        }

        for (let i = 1; i < controlViewModel.count(); i++) {
            let version = controlViewModel.version(i);
            if (isVersionGreater(latestVersionTemp.version, version)) {
                latestVersionTemp = copyControlViewObject(controlViewModel, i);
            }
        }

        return latestVersionTemp;
    }

    // checks if version 2 is greater than version 1
    function isVersionGreater(version1, version2) {
        let version1Arr = version1.split('.').map(num => parseInt(num, 10));
        let version2Arr = version2.split('.').map(num => parseInt(num, 10));

        // fill in 0s for each missing version (e.g) 1.5 -> 1.5.0
        while (version1Arr.length < 3) {
            version1Arr.push(0)
        }

        while (version2Arr.length < 3) {
            version2Arr.push(0)
        }

        for (let i = 0; i < 3; i++) {
            if (version1Arr[i] > version2Arr[i]) {
                return false;
            } else if (version1Arr[i] < version2Arr[i]) {
                return true;
            }
        }

        // else they are the same version
        return false;
    }

    function copyControlViewObject(controlViewList, index) {
        let obj = {};

        obj["uri"] = controlViewList.uri(index);
        obj["md5"] = controlViewList.md5(index);
        obj["name"] = controlViewList.name(index);
        obj["version"] = controlViewList.version(index);
        obj["timestamp"] = controlViewList.timestamp(index);
        obj["installed"] = controlViewList.installed(index);

        return obj;
    }
}
