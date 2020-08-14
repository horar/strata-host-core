import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.common 1.0
import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/help_layout_manager.js" as Help
import "qrc:/js/uuid_map.js" as UuidMap

StackLayout {
    id: platformStack

    currentIndex: {
        switch (model.view) {
        case "collateral":
            return 1
        case "settings":
            return 2
        default: // case "control":
            return 0
        }
    }

    property alias controlContainer: controlContainer
    property alias collateralContainer: collateralContainer

    property int device_id: model.device_id
    property string class_id: model.class_id
    property string firmware_version: model.firmware_version
    property var controlViewList: sdsModel.documentManager.getClassDocuments(model.class_id).controlViewListModel
    property int controlViewListCount: controlViewList.count
    property bool connected: model.connected
    property bool controlLoaded: false
    property bool platformDocumentsInitialized: false

    onControlViewListCountChanged: {
        platformDocumentsInitialized = true;
        if (loadingBar.percentReady === 0.0) {
            loadPlatformDocuments()
        }
    }

    onConnectedChanged: {
        if (connected && model.available.control) {
            // When we reconnect the board, the view has already been registered, so we can immediately load the control
            if (platformDocumentsInitialized) {                
                loadControl()
            } else {
                // Connect signals to slots first. This is to remedy the issue where the Connections component was not yet completed
                // when the signal was emitted
                sdsModel.resourceLoader.resourceRegistered.connect(resourceRegistered);
                sdsModel.resourceLoader.resourceRegisterFailed.connect(resourceRegisterFailed);
                loadingBarContainer.visible = true;
                loadingBar.percentReady = 0.0;
            }
        } else {
            removeControl();
        }
    }

    Component.onDestruction: {
        removeControl()
    }

    onCurrentIndexChanged: {
        if (index === 0) {
            if (controlLoaded === false) {
                loadingBarContainer.visible = true;
                loadingBar.percentReady = 1.0;
            }
        }
    }

    function setArray(index, value) {
        if (myArray[index]!== value) {
            myArray[index] = value
            myArrayChanged() //emit signal
        }
    }

    function loadControl () {
        if (controlLoaded === false){
            Help.setClassId(model.device_id)
            sgUserSettings.classId = model.class_id
            loadingBarContainer.visible = false;
            loadingBar.percentReady = 0.0;

            let qml_control = NavigationControl.getQMLFile(model.class_id, "Control")
            NavigationControl.context.class_id = model.class_id
            NavigationControl.context.device_id = model.device_id
            NavigationControl.context.sgUserSettings = sgUserSettings

            let control = NavigationControl.createView(qml_control, controlContainer)
            delete NavigationControl.context.class_id
            delete NavigationControl.context.device_id
            delete NavigationControl.context.sgUserSettings
            if (control === null) {
                NavigationControl.createView(NavigationControl.screens.LOAD_ERROR, controlContainer)
            }

            controlLoaded = true
        }
    }

    function updateControl(version, oldVersion) {
        removeControl();

        if (oldVersion !== "") {
            let success = sdsModel.resourceLoader.deleteViewResource(model.class_id, oldVersion);
            console.info("Successfully deleted control view version", oldVersion, "for platform", model.class_id);
        }
        sdsModel.resourceLoader.registerControlViewResources(model.class_id, version);
    }

    function removeControl () {
        if (controlLoaded) {
            NavigationControl.removeView(controlContainer)
            controlLoaded = false
        }
    }

    /* The Order of Operations here is as follows:
        1. Call loadPlatformDocuments()
        2. Check if static (local) control view exists, if so, register it
        3. else, call loadResource()
        4. If OTA versions are installed, register the installed version, else download latest version
    */
    function loadPlatformDocuments() {
        if (controlLoaded === false) {
            if (sdsModel.resourceLoader.isViewRegistered(model.class_id)) {
                loadingBar.percentReady = 1.0
                return;
            }

            if (sdsModel.resourceLoader.registerStaticControlViewResources(model.class_id, model.name)) {
                loadingBar.percentReady = 1.0;
                return;
            } else {
                loadResource();
            }
        }
    }

    /*
        Helper function for downloading/registering a control view
    */
    function loadResource() {
        // get installed index instead of latest version
        let index = controlViewList.getInstalledVersion();

        if (index < 0) {
            console.info("No control view installed for", model.class_id)
            index = controlViewList.getLatestVersion();

            let updateCommand = {
                "hcs::cmd": "download_view",
                "payload": {
                    "url": controlViewList.uri(index),
                    "md5": controlViewList.md5(index)
                }
            };

            coreInterface.sendCommand(JSON.stringify(updateCommand));
        } else {
            sdsModel.resourceLoader.registerControlViewResources(model.class_id, controlViewList.version(index));
        }
    }

    /*
      Slot for the sdsModel.resourceLoader.resourceRegistered signal
    */
    function resourceRegistered (class_id) {
        if (class_id === model.class_id) {
            loadingBar.color = "#57d445"
            loadingBar.percentReady = 1.0;
        }
    }

    /*
      Slot for the sdsModel.resourceLoader.resourceRegisteredFailed signal
    */
    function resourceRegisterFailed (class_id) {
        if (class_id === model.class_id) {
            loadingBar.color = "red";
            loadingBar.percentReady = 1.0;
        }
    }

    Item {
        id: controlStackContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        Timer {
            id: waitToLoadTimer
            interval: 100
            repeat: false

            onTriggered: {
                loadControl()
            }
        }

        Rectangle {
            id: loadingBarContainer
            x: platformStack.width / 2 - width / 2
            y: platformStack.height / 2 - height / 2

            width: platformStack.width * .5
            height: 15

            color: "grey"
            visible: true

            Rectangle {
                id: loadingBar

                property double percentReady: 0.0

                z: 100

                height: parent.height
                width: 0
                color: "#57d445"

                onPercentReadyChanged: {
                    width = loadingBarContainer.width * percentReady;
                    if (percentReady === 1.0) {
                        waitToLoadTimer.start()
                    }
                }
            }
        }

        Item {
            id: controlContainer

            anchors {
                fill: parent
            }

        }

        DisconnectedOverlay {
            visible: model.connected === false
        }
    }

    Item {
        id: collateralContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        ContentView {
            class_id: model.class_id
        }
    }

    SGUserSettings {
        id: sgUserSettings
        classId: model.class_id
    }

    Item {
        id: settingsContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        PlatformSettings {
        }
    }

    Connections {
        target: sdsModel.coreInterface

        onDownloadViewFinished: {
            // hacky way to get the class_id from the request.
            // e.g. "url":"226/control_views/1.1.3/views-hello-strata.rcc"
            let urlSplit = payload.url.split("/");
            let class_id = urlSplit[0];
            let version = urlSplit[2];

            if (class_id === model.class_id && controlLoaded === false) {
                sdsModel.resourceLoader.registerControlViewResources(model.class_id, version)
            }
        }

        onDownloadControlViewProgress: {
            let percent = payload.bytes_received / payload.bytes_total;
            if (percent !== 1.0) {
                loadingBar.percentReady = percent
            }
        }

    }
}
