import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/js/uuid_map.js" as UuidMap
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.ResourceLoader 1.0
import tech.strata.sgwidgets 1.0

Item {
    id: controlViewContainer

    property bool usingLocalView: true
    property string updateVersion: ""
    property string updateVersionPath: ""
    property string activeVersion: ""
    property string activeDownloadUri: ""
    property var versionsToRemoveFromUpdate: []
    property var controlViewList: sdsModel.documentManager.getClassDocuments(platformStack.class_id).controlViewListModel
    property int controlViewListCount: controlViewList.count
    property bool controlLoaded: false

    Rectangle {
        id: loadingBarContainer
        anchors {
            fill: parent
        }

        ProgressBar {
            id: loadingBar
            anchors {
                centerIn: parent
            }

            background: Rectangle {
                id: barContainer
                implicitWidth: controlViewContainer.width / 2
                implicitHeight: 15
                color: "#e6e6e6"
                radius: 5
            }

            contentItem: Rectangle {
                id: bar
                color: "#57d445"
                height: parent.height
                width: loadingBar.visualPosition * parent.width
                radius: 5
            }

            onValueChanged: {
                if (loadingBar.value === 1.0) {
                    loadControl()
                }
            }
        }

        SGText {
            anchors {
                left: loadingBar.left
                bottom: loadingBar.top
                bottomMargin: 10
            }
            text: "Loading..."
            fontSizeMultiplier: 2
            color: "#666"
        }
    }

    Item {
        id: controlContainer
        anchors {
            fill: parent
        }
    }

    DisconnectedOverlay {
        visible: platformStack.connected === false
    }

    function initialize() {
        // When we reconnect the board, the view has already been registered, so we can immediately load the control
        if (sdsModel.resourceLoader.isViewRegistered(platformStack.class_id)) {
            if (sdsModel.resourceLoader.getVersionRegistered(platformStack.class_id) !== "") {
                usingLocalView = false;
            }
            loadControl()
        } else {
            loadingBarContainer.visible = true;
            loadingBar.value = 0.01;
            checkForResources()
        }
    }

    function loadControl () {
        if (controlLoaded === false){

            let version = "";
            if (usingLocalView === false) {
                let idx = controlViewList.getInstalledVersion();
                if (idx >= 0) {
                    version = controlViewList.version(idx);
                } else {
                    console.error("No resource version found for", platformStack.class_id)
                }
            } else {
                version = "static"
            }

            let control_filepath = NavigationControl.getQMLFile("Control", platformStack.class_id, version)

            // Set up context for creation
            Help.setClassId(platformStack.device_id)
            NavigationControl.context.class_id = platformStack.class_id
            NavigationControl.context.device_id = platformStack.device_id

            let control_obj = sdsModel.resourceLoader.createViewObject(control_filepath, controlContainer);

            // Tear Down creation context
            delete NavigationControl.context.class_id
            delete NavigationControl.context.device_id

            if (control_obj === null) {
                createErrorScreen("Could not load file: " + control_filepath)
            } else {
                controlLoaded = true
            }
            loadingBarContainer.visible = false;
            loadingBar.value = 0.0;
        }
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
      Starts to update a control view to a new version
    */
    function startControlUpdate(newVersion, newVersionPath) {
        updateVersion = newVersion;
        updateVersionPath = newVersionPath;
        removeControl();
        updateControl();
    }

    /*
      This function should only be called after the previous view is completely destroyed
    */
    function updateControl() {
        if (updateVersion !== "") {
            for (let i = 0; i < controlViewListCount; i++) {
                if (controlViewList.version(i) === updateVersion) {
                    controlViewList.setInstalled(i, true);
                    controlViewList.setFilepath(i, updateVersionPath);
                } else if (controlViewList.version(i) !== updateVersion && controlViewList.installed(i) === true) {
                    controlViewList.setInstalled(i, false);
                    versionsToRemoveFromUpdate.push({
                                                        "version": controlViewList.version(i),
                                                        "filepath": controlViewList.filepath(i)
                                                    });
                }
            }
            usingLocalView = false;
            sdsModel.resourceLoader.registerControlViewResources(platformStack.class_id, updateVersionPath, updateVersion);
            deleteViewResources()
        }
    }

    /*
      This function deletes all registered controlViewResources
    */
    function deleteViewResources() {
        // Check to see if local view is registered
        if (UuidMap.uuid_map.hasOwnProperty(platformStack.class_id)) {
            let name = UuidMap.uuid_map[platformStack.class_id];
            sdsModel.resourceLoader.requestDeleteViewResource(ResourceLoader.LOCAL_VIEW, platformStack.class_id, name, "", controlContainer);
        }

        for (let i = 0; i < versionsToRemoveFromUpdate.length; i++) {
            sdsModel.resourceLoader.requestDeleteViewResource(ResourceLoader.OTA_VIEW, platformStack.class_id, versionsToRemoveFromUpdate[i].filepath, versionsToRemoveFromUpdate[i].version, controlContainer);
        }

        updateVersion = ""
        updateVersionPath = ""
        versionsToRemoveFromUpdate = []
    }

    /* The Order of Operations here is as follows:
        1. Call checkForResources()
        2. Check if static (local) control view exists, if so, register it
        3. else, call loadResource()
        4. If OTA versions are installed, register the installed version, else download latest version
    */
    function checkForResources() {
        if (controlLoaded === false) {
            /* First check if the view is already registered.
              If it is not, then try to first register a static (local) control view for this class_id.
              If that doesn't work then try to load an OTA control view
            */
            if (sdsModel.resourceLoader.isViewRegistered(platformStack.class_id)) {
                loadingBar.value = 1.0
                return;
            }

            let name = UuidMap.uuid_map[platformStack.class_id];
            if (sdsModel.resourceLoader.registerStaticControlViewResources(platformStack.class_id, name)) {
                usingLocalView = true;
                loadingBar.value = 1.0;
                return;
            } else {
                usingLocalView = false;
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
            console.info("No control view installed for", platformStack.class_id)
            index = controlViewList.getLatestVersion();

            if (controlViewList.uri(index) === "" || controlViewList.md5(index) === "") {
                let obj = sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, controlContainer, {"error_message": "Could not find view"});
                controlLoaded = true
            }

            let downloadCommand = {
                "hcs::cmd": "download_view",
                "payload": {
                    "url": controlViewList.uri(index),
                    "md5": controlViewList.md5(index),
                    "class_id": platformStack.class_id
                }
            };

            activeDownloadUri = controlViewList.uri(index)

            coreInterface.sendCommand(JSON.stringify(downloadCommand));
        } else {
            if (sdsModel.resourceLoader.isViewRegistered(platformStack.class_id)) {
                resourceRegistered();
            } else {
                sdsModel.resourceLoader.registerControlViewResources(platformStack.class_id,
                                                                     controlViewList.filepath(index),
                                                                     controlViewList.version(index));
            }
        }
    }

    function createErrorScreen(errorString) {
        let obj = sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, controlContainer, {"error_message": errorString});
        controlLoaded = true
    }

    /*
      Slot for the sdsModel.resourceLoader.resourceRegistered signal
    */
    function resourceRegistered () {
        loadingBar.value = 1.0;
    }

    /*
      Slot for the sdsModel.resourceLoader.resourceRegisteredFailed signal
    */
    function resourceRegisterFailed () {
        controlContainer.removeControl()
        createErrorScreen("Failed to find or load control view resource file")
    }


    Connections {
        target: sdsModel.resourceLoader

        Component.onCompleted: {
            platformStack.resourceLoaderConnectionInitialized = true
        }

        onResourceRegistered: {
            if (class_id === platformStack.class_id) {
                controlViewContainer.resourceRegistered()
            }
        }

        onResourceRegisterFailed: {
            if (class_id === platformStack.class_id) {
                controlViewContainer.resourceRegisterFailed()
            }
        }
    }


    Connections {
        id: coreInterfaceConnections
        target: sdsModel.coreInterface

        onDownloadViewFinished: {
            if (payload.url === activeDownloadUri) {
                activeDownloadUri = ""
                if (payload.error_string.length > 0) {
                    removeControl()
                    controlViewContainer.createErrorScreen(payload.error_string);
                    return
                }

                for (let i = 0; i < controlViewContainer.controlViewListCount; i++) {
                    if (controlViewContainer.controlViewList.uri(i) === payload.url) {
                        controlViewContainer.controlViewList.setInstalled(i, true);
                        controlViewContainer.controlViewList.setFilepath(i, payload.filepath);
                        for (let j = 0; j < controlViewContainer.controlViewListCount; j++) {
                            if (j !== i && controlViewContainer.controlViewList.installed(j) === true) {
                                controlViewContainer.controlViewListCount.setInstalled(j, false);
                            }
                        }
                        platformSettings.softwareManagement.matchVersion()
                        if (sdsModel.resourceLoader.isViewRegistered(platformStack.class_id)) {
                            controlViewContainer.resourceRegistered();
                        } else {
                            sdsModel.resourceLoader.registerControlViewResources(platformStack.class_id, payload.filepath, controlViewContainer.controlViewList.version(i));
                        }
                        break;
                    }
                }
            }
        }

        onDownloadControlViewProgress: {
            if (payload.url === activeDownloadUri) {
                let percent = payload.bytes_received / payload.bytes_total;
                if (percent !== 1.0) {
                    loadingBar.value = percent
                }
            }
        }
    }
}
