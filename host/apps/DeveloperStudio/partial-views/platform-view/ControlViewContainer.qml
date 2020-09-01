import QtQuick 2.0

import "qrc:/js/uuid_map.js" as UuidMap

Item {
    id: root

    property int index
    property bool usingLocalView: true
    property string updateVersion: ""
    property string updateVersionPath: ""

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
            let versionsToRemove = [];

            for (let i = 0; i < platformStack.controlViewListCount; i++) {
                if (platformStack.controlViewList.version(i) === updateVersion) {
                    platformStack.controlViewList.setInstalled(i, true);
                    platformStack.controlViewList.setFilepath(i, updateVersionPath);
                } else if (platformStack.controlViewList.version(i) !== updateVersion && platformStack.controlViewList.installed(i) === true) {
                    platformStack.controlViewList.setInstalled(i, false);
                    versionsToRemove.push({
                                                "filepath": platformStack.controlViewList.filepath(i),
                                                "version": platformStack.controlViewList.version(i)
                                            });
                }
            }
            let success = sdsModel.resourceLoader.deleteStaticViewResource(model.class_id, model.name, root);

            if (versionsToRemove.length > 0) {
                for (let i = 0; i < versionsToRemove.length; i++) {
                    let success = sdsModel.resourceLoader.deleteViewResource(model.class_id, versionsToRemove[i].filepath, versionsToRemove[i].version, root);
                    if (success) {
                        console.info("Successfully deleted control view version", versionsToRemove[i].version, "for platform", model.class_id);
                    } else {
                        console.error("Could not delete control view version", versionsToRemove[i].version, "for platform", model.class_id);
                    }
                }
            }
            usingLocalView = false;
            sdsModel.resourceLoader.registerControlViewResources(model.class_id, updateVersionPath, updateVersion);
            updateVersion = ""
            updateVersionPath = ""
        }
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
            if (sdsModel.resourceLoader.isViewRegistered(model.class_id)) {
                platformStack.loadingBar.percentReady = 1.0
                return;
            }

            let name = UuidMap.uuid_map[model.class_id];

            if (!name) {
                name = model.name
            }

            if (sdsModel.resourceLoader.registerStaticControlViewResources(model.class_id, name)) {
                usingLocalView = true;
                platformStack.loadingBar.percentReady = 1.0;
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
            console.info("No control view installed for", model.class_id)
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

            coreInterface.sendCommand(JSON.stringify(downloadCommand));
        } else {
            sdsModel.resourceLoader.registerControlViewResources(model.class_id, platformStack.controlViewList.filepath(index), platformStack.controlViewList.version(index));
        }
    }


    Connections {
        id: coreInterfaceConnections
        target: sdsModel.coreInterface

        onDownloadViewFinished: {
            if (platformStack.currentIndex === index) {
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
                            if (j !== i && platformStack.controlViewListCount.installed(j) === true) {
                                platformStack.controlViewListCount.setInstalled(j, false);
                            }
                        }
                        sdsModel.resourceLoader.registerControlViewResources(model.class_id, payload.filepath, platformStack.controlViewListCount.version(i));
                        break;
                    }
                }
            }
        }

        onDownloadControlViewProgress: {
            if (currentIndex === index) {
                let percent = payload.bytes_received / payload.bytes_total;
                if (percent !== 1.0) {
                    platformStack.loadingBar.percentReady = percent
                }
            }
        }

    }
}
