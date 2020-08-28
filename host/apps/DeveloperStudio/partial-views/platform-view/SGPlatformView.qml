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
    property var controlViewList
    property int controlViewListCount
    property bool connected: model.connected
    property bool controlLoaded: false
    property bool platformDocumentsInitialized: false
    property bool usingLocalView: true
    property bool fullyInitialized: platformStack.initialized && sgUserSettings.initialized
    property bool initialized: false
    property string updateVersion: ""
    property string updateVersionPath: ""

    onConnectedChanged: {
        initialize()
    }

    Component.onCompleted: {
        initialized = true
        initialize()
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

    function initialize () {
        if (fullyInitialized) { // guarantee control view loads after platformStack & sgUserSettings
            if (connected && model.available.control) {
                // When we reconnect the board, the view has already been registered, so we can immediately load the control
                if (platformDocumentsInitialized) {
                    loadControl()
                } else {
                    // Connect signals to slots first. This is to remedy the issue where the Connections component was not yet completed
                    // when the signal was emitted
                    sdsModel.resourceLoader.resourceRegistered.connect(resourceRegistered);
                    sdsModel.resourceLoader.resourceRegisterFailed.connect(resourceRegisterFailed);
                    controlViewList = sdsModel.documentManager.getClassDocuments(model.class_id).controlViewListModel
                    controlViewListCount = controlViewList.count
                    loadingBarContainer.visible = true;
                    loadingBar.percentReady = 0.0;
                }
            } else {
                removeControl()
            }
        }
    }

    function loadControl () {
        if (controlLoaded === false){
            Help.setClassId(model.device_id)
            sgUserSettings.classId = model.class_id
            loadingBarContainer.visible = false;
            loadingBar.percentReady = 0.0;

            let version = "";

            if (!usingLocalView) {
                let idx = controlViewList.getInstalledVersion();

                if (idx >= 0) {
                    version = controlViewList.version(idx);
                }
            }

            let name = model.name;

            if (usingLocalView) {
                name = UuidMap.uuid_map[model.class_id];
            }

            let qml_control = NavigationControl.getQMLFile(model.class_id, name, "Control", usingLocalView, version)
            NavigationControl.context.class_id = model.class_id
            NavigationControl.context.device_id = model.device_id

            let obj = sdsModel.resourceLoader.createViewObject(qml_control, controlContainer);
            if (obj === null) {
                obj = sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, controlContainer, {"error_message": "Could not load view."});
            } else {
                controlLoaded = true
            }

            delete NavigationControl.context.class_id
            delete NavigationControl.context.device_id
        }
    }

    /*
      Updates a control view to a new version
    */
    function startControlUpdate(newVersion, newVersionPath) {
        platformStack.updateVersion = newVersion;
        platformStack.updateVersionPath = newVersionPath;
        removeControl();
        updateControlTimer.start()
    }

    /*
      Removes the control view from controlContainer
    */
    function removeControl () {
        if (controlLoaded) {
            for (let i = 0; i < controlContainer.children.length; i++) {
                controlContainer.children[i].destroy();
            }
            controlLoaded = false
        }
    }

    /*
      This function should only be called after the previous view is completely destroyed
    */
    function updateControl() {
        if (platformStack.updateVersion !== "") {
            let versionsToRemove = [];

            for (let i = 0; i < controlViewListCount; i++) {
                if (controlViewList.version(i) === platformStack.updateVersion) {
                    controlViewList.setInstalled(i, true);
                    controlViewList.setFilepath(i, platformStack.updateVersionPath);
                } else if (controlViewList.version(i) !== platformStack.updateVersion && controlViewList.installed(i) === true) {
                    controlViewList.setInstalled(i, false);
                    versionsToRemove.push({
                                                "filepath": controlViewList.filepath(i),
                                                "version": controlViewList.version(i)
                                            });
                }
            }
            let success = sdsModel.resourceLoader.deleteStaticViewResource(model.class_id, model.name, controlContainer);

            if (versionsToRemove.length > 0) {
                for (let i = 0; i < versionsToRemove.length; i++) {
                    let success = sdsModel.resourceLoader.deleteViewResource(model.class_id, versionsToRemove[i].filepath, versionsToRemove[i].version, controlContainer);
                    if (success) {
                        console.info("Successfully deleted control view version", versionsToRemove[i].version, "for platform", model.class_id);
                    } else {
                        console.error("Could not delete control view version", versionsToRemove[i].version, "for platform", model.class_id);
                    }
                }
            }
            usingLocalView = false;
            sdsModel.resourceLoader.registerControlViewResources(model.class_id, platformStack.updateVersionPath, platformStack.updateVersion);
            platformStack.updateVersion = ""
            platformStack.updateVersionPath = ""
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
            /* First check if the view is already registered.
              If it is not, then try to first register a static (local) control view for this class_id.
              If that doesn't work then try to load an OTA control view
            */
            if (sdsModel.resourceLoader.isViewRegistered(model.class_id)) {
                loadingBar.percentReady = 1.0
                return;
            }

            let name = UuidMap.uuid_map[model.class_id];

            if (!name) {
                name = model.name
            }

            if (sdsModel.resourceLoader.registerStaticControlViewResources(model.class_id, name)) {
                platformStack.usingLocalView = true;
                loadingBar.percentReady = 1.0;
                return;
            } else {
                platformStack.usingLocalView = false;
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

            let downloadCommand = {
                "hcs::cmd": "download_view",
                "payload": {
                    "url": controlViewList.uri(index),
                    "md5": controlViewList.md5(index),
                    "class_id": platformStack.class_id
                }
            };

            coreInterface.sendCommand(JSON.stringify(downloadCommand));
        } else {
            sdsModel.resourceLoader.registerControlViewResources(model.class_id, controlViewList.filepath(index), controlViewList.version(index));
        }
    }

    /*
      Slot for the sdsModel.resourceLoader.resourceRegistered signal
    */
    function resourceRegistered (class_id) {
        if (class_id === platformStack.class_id) {
            loadingBar.color = "#57d445"
            loadingBar.percentReady = 1.0;
        }
    }

    /*
      Slot for the sdsModel.resourceLoader.resourceRegisteredFailed signal
    */
    function resourceRegisterFailed (class_id) {
        if (class_id === platformStack.class_id) {
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

        Timer {
            id: updateControlTimer
            interval: 50
            repeat: false

            onTriggered: {
                updateControl()
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

    Item {
        id: settingsContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        PlatformSettings {
        }
    }

    SGUserSettings {
        id: sgUserSettings
        classId: model.class_id
        user: NavigationControl.context.user_id

        property bool initialized: false

        Component.onCompleted: {
            initialized = true
            platformStack.initialize()
        }
    }

    Connections {
        id: coreInterfaceConnections
        target: sdsModel.coreInterface

        onDownloadViewFinished: {
            if (currentIndex === 0) {
                if (payload.error_string.length > 0) {
                    loadingBar.color = "red"
                    loadingBar.percentReady = 1.0
                    removeControl();
                    let obj = sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, controlContainer, {"error_message": payload.error_string});
                    controlLoaded = true
                    return
                }

                for (let i = 0; i < controlViewListCount; i++) {
                    if (controlViewList.uri(i) === payload.url) {
                        controlViewList.setInstalled(i, true);
                        controlViewList.setFilepath(i, payload.filepath);
                        for (let j = 0; j < controlViewListCount; j++) {
                            if (j !== i && controlViewList.installed(j) === true) {
                                controlViewList.setInstalled(j, false);
                            }
                        }
                        sdsModel.resourceLoader.registerControlViewResources(model.class_id, payload.filepath, controlViewList.version(i));
                        break;
                    }
                }
            }
        }

        onDownloadControlViewProgress: {
            if (currentIndex === 0) {
                let percent = payload.bytes_received / payload.bytes_total;
                if (percent !== 1.0) {
                    loadingBar.percentReady = percent
                }
            }
        }

    }

    Connections {
        target: sdsModel.documentManager

        onPopulateModelsFinished: {
            if (classId === model.class_id) {
                platformDocumentsInitialized = true;
                controlViewList = sdsModel.documentManager.getClassDocuments(model.class_id).controlViewListModel
                controlViewListCount = controlViewList.count
                if (loadingBar.percentReady === 0.0) {
                    loadPlatformDocuments()
                }
            }
        }
    }
}
