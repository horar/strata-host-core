import QtQuick 2.0

import "qrc:/js/uuid_map.js" as UuidMap
import "qrc:/js/navigation_control.js" as NavigationControl
import tech.strata.ResourceLoader 1.0

Item {
    id: root

    property int index
    property bool usingLocalView: true
    property string updateVersion: ""
    property string updateVersionPath: ""
    property string activeVersion: ""
    property string activeDownloadUri: ""
    property var versionsToRemoveFromUpdate: []

    anchors {
        fill: parent
    }

    onChildrenChanged: {
        // Only update the control view version if we are requesting an update.
        if (children.length === 0 && updateVersion !== "" && updateVersionPath !== "") {
            updateControl()
        }
    }

    /*
      Removes the control view from controlContainer
    */
    function removeControl () {
        if (platformStack.controlLoaded) {
            for (let i = 0; i < children.length; i++) {
                children[i].destroy();
            }
            platformStack.controlLoaded = false
        }
    }

    /*
      Starts to update a control view to a new version
    */
    function startControlUpdate(newVersion, newVersionPath) {
        updateVersion = newVersion;
        updateVersionPath = newVersionPath;
        removeControl();
    }

    /*
      This function should only be called after the previous view is completely destroyed
    */
    function updateControl() {
        if (updateVersion !== "") {
            for (let i = 0; i < platformStack.controlViewListCount; i++) {
                if (platformStack.controlViewList.version(i) === updateVersion) {
                    platformStack.controlViewList.setInstalled(i, true);
                    platformStack.controlViewList.setFilepath(i, updateVersionPath);
                } else if (platformStack.controlViewList.version(i) !== updateVersion && platformStack.controlViewList.installed(i) === true) {
                    platformStack.controlViewList.setInstalled(i, false);
                    versionsToRemoveFromUpdate.push({
                                                        "version": platformStack.controlViewList.version(i),
                                                        "filepath": platformStack.controlViewList.filepath(i)
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
        let name = UuidMap.uuid_map[platformStack.class_id];
        sdsModel.resourceLoader.requestDeleteViewResource(ResourceLoader.LOCAL_VIEW, platformStack.class_id, name, "", root);

        for (let i = 0; i < versionsToRemoveFromUpdate.length; i++) {
            sdsModel.resourceLoader.requestDeleteViewResource(ResourceLoader.OTA_VIEW, platformStack.class_id, versionsToRemoveFromUpdate[i].filepath, versionsToRemoveFromUpdate[i].version, root);
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
        if (platformStack.controlLoaded === false) {
            /* First check if the view is already registered.
              If it is not, then try to first register a static (local) control view for this class_id.
              If that doesn't work then try to load an OTA control view
            */
            if (sdsModel.resourceLoader.isViewRegistered(platformStack.class_id)) {
                platformStack.loadingBar.value = 1.0
                return;
            }

            let name = UuidMap.uuid_map[platformStack.class_id];
            if (sdsModel.resourceLoader.registerStaticControlViewResources(platformStack.class_id, name)) {
                usingLocalView = true;
                platformStack.loadingBar.value = 1.0;
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
        let index = platformStack.controlViewList.getInstalledVersion();

        if (index < 0) {
            console.info("No control view installed for", platformStack.class_id)
            index = platformStack.controlViewList.getLatestVersion();

            if (platformStack.controlViewList.uri(index) === "" || platformStack.controlViewList.md5(index) === "") {
                let obj = sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, controlContainer, {"error_message": "Could not find view"});
                platformStack.controlLoaded = true
            }

            let downloadCommand = {
                "hcs::cmd": "download_view",
                "payload": {
                    "url": platformStack.controlViewList.uri(index),
                    "md5": platformStack.controlViewList.md5(index),
                    "class_id": platformStack.class_id
                }
            };

            activeDownloadUri = platformStack.controlViewList.uri(index)

            coreInterface.sendCommand(JSON.stringify(downloadCommand));
        } else {
            if (sdsModel.resourceLoader.isViewRegistered(platformStack.class_id)) {
                platformStack.resourceRegistered(platformStack.class_id);
            } else {
                sdsModel.resourceLoader.registerControlViewResources(platformStack.class_id,
                                                                     platformStack.controlViewList.filepath(index),
                                                                     platformStack.controlViewList.version(index));
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
                    platformStack.createErrorScreen(payload.error_string);
                    return
                }

                for (let i = 0; i < platformStack.controlViewListCount; i++) {
                    if (platformStack.controlViewList.uri(i) === payload.url) {
                        platformStack.controlViewList.setInstalled(i, true);
                        platformStack.controlViewList.setFilepath(i, payload.filepath);
                        for (let j = 0; j < platformStack.controlViewListCount; j++) {
                            if (j !== i && platformStack.controlViewList.installed(j) === true) {
                                platformStack.controlViewListCount.setInstalled(j, false);
                            }
                        }
                        if (sdsModel.resourceLoader.isViewRegistered(platformStack.class_id)) {
                            platformStack.resourceRegistered(platformStack.class_id);
                        } else {
                            sdsModel.resourceLoader.registerControlViewResources(platformStack.class_id, payload.filepath, platformStack.controlViewList.version(i));
                        }
                        break;
                    }
                }
            }
        }

        onDownloadControlViewProgress: {
            if (platformStack.currentIndex === index && payload.url === activeDownloadUri) {
                let percent = payload.bytes_received / payload.bytes_total;
                if (percent !== 1.0) {
                    platformStack.loadingBar.value = percent
                }
            }
        }

    }
}
