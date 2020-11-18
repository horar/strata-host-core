import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/js/uuid_map.js" as UuidMap
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.ResourceLoader 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

Item {
    id: controlViewContainer

    property bool usingStaticView: true
    property string activeDownloadUri: ""
    property var otaVersionsToRemove: []
    property var controlViewList: sdsModel.documentManager.getClassDocuments(platformStack.class_id).controlViewListModel
    property int controlViewListCount: controlViewList.count
    property bool controlLoaded: false

    readonly property string staticVersion: "static"

    SGText {
        anchors.centerIn: parent
        text: "Loading Control View..."
        fontSizeMultiplier: 2
        color: "#666"
        visible: controlLoader.status === Loader.Loading && loadingBarContainer.visible === false
    }

    Rectangle {
        id: loadingBarContainer
        anchors {
            fill: parent
        }
        visible: false

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
        }

        SGText {
            anchors {
                left: loadingBar.left
                bottom: loadingBar.top
                bottomMargin: 10
            }
            text: loadingBar.value === 1.0 ? "Loading Control View..." : "Downloading Control View..."
            fontSizeMultiplier: 2
            color: "#666"
        }
    }

    Item {
        id: controlContainer
        anchors.fill: parent

        Loader {
            id: controlLoader
            anchors.fill: parent
            asynchronous: true

            onStatusChanged: {
                if (status === Loader.Ready) {
                    // Tear Down creation context
                    delete NavigationControl.context.class_id
                    delete NavigationControl.context.device_id

                    controlLoaded = true
                    loadingBarContainer.visible = false;
                    loadingBar.value = 0.0;
                } else if (status === Loader.Error) {
                    // Tear Down creation context
                    delete NavigationControl.context.class_id
                    delete NavigationControl.context.device_id

                    createErrorScreen("Could not load file: " + source);
                }
            }
        }
    }

    DisconnectedOverlay {
        visible: platformStack.connected === false
    }

    function initialize() {
        if (controlLoaded === false){
            // When we reconnect the board, the view has already been registered, so we can immediately load the control
            let versionControl = versionSettings.readFile("versionControl.json");
            const versionInstalled = getInstalledVersion(NavigationControl.context.user_id, versionControl);

            if (sdsModel.resourceLoader.isViewRegistered(platformStack.class_id)
                    && (versionInstalled === null || versionInstalled.version === sdsModel.resourceLoader.getVersionRegistered(platformStack.class_id))) {
                if (sdsModel.resourceLoader.getVersionRegistered(platformStack.class_id) !== controlViewContainer.staticVersion) {
                    usingStaticView = false;
                }
                loadControl()
            } else {
                loadingBarContainer.visible = true;
                loadingBar.value = 0.01;

                // Try to load a previously installed OTA resource
                if (controlViewList.getInstalledVersion() > -1) {
                    usingStaticView = false;
                    getOTAResource();
                    return
                }

                // Try to load static resource, otherwise download/install a new OTA resource
                if (getStaticResource() === false) {
                    usingStaticView = false;
                    getOTAResource();
                }
            }
        }
    }

    /*
      Loads Control.qml from the installed resource file into controlContainer
    */
    function loadControl () {
        let version = controlViewContainer.staticVersion
        if (usingStaticView === false) {
            let installedVersion = getInstalledVersion(NavigationControl.context.user_id);
            version = installedVersion.version
        }

        let control_filepath = NavigationControl.getQMLFile("Control", platformStack.class_id, version)

        // Set up context for control object creation
        Help.setClassId(platformStack.device_id)
        NavigationControl.context.class_id = platformStack.class_id
        NavigationControl.context.device_id = platformStack.device_id

        controlLoader.setSource(control_filepath, Object.assign({}, NavigationControl.context))
    }

    /*
        Try to find/register a static resource file
        Todo: remove this when fully OTA
    */
    function getStaticResource() {
        if (UuidMap.uuid_map.hasOwnProperty(platformStack.class_id)){
            let name = UuidMap.uuid_map[platformStack.class_id];
            let RCCpath = sdsModel.resourceLoader.getStaticResourcesString() + "/views-" + name + ".rcc"

            usingStaticView = true
            if (registerResource(RCCpath, controlViewContainer.staticVersion)) {
                return true;
            } else {
                removeControl() // registerResource() failing creates an error screen, kill it to show OTA progress bar
                usingStaticView = false
            }
        }
        return false
    }

    /*
        Try to find an installed OTA resource file and load it, otherwise download newest version
    */
    function getOTAResource() {
        let versionControl = versionSettings.readFile("versionControl.json");
        const versionInstalled = getInstalledVersion(NavigationControl.context.user_id, versionControl);

        if (versionInstalled) {
            if (!SGUtilsCpp.isFile(versionInstalled.path)) {
                versionControl = saveInstalledVersion(null, null, versionControl);
            } else if (registerResource(versionInstalled.path, versionInstalled.version)) {
                return;
            }
        }

        // Find index of any installed version
        let installedVersionIndex = controlViewList.getInstalledVersion();

        if (installedVersionIndex >= 0) {
            saveInstalledVersion(controlViewList.version(installedVersionIndex), controlViewList.filepath(installedVersionIndex), versionControl);
            registerResource(controlViewList.filepath(installedVersionIndex), controlViewList.version(installedVersionIndex));
        } else {
            let latestVersionindex = controlViewList.getLatestVersion();

            if (controlViewList.uri(latestVersionindex) === "" || controlViewList.md5(latestVersionindex) === "") {
                createErrorScreen("Found no local control view and none for download.")
                return
            }

            let downloadCommand = {
                "hcs::cmd": "download_view",
                "payload": {
                    "url": controlViewList.uri(latestVersionindex),
                    "md5": controlViewList.md5(latestVersionindex),
                    "class_id": platformStack.class_id
                }
            };

            activeDownloadUri = controlViewList.uri(latestVersionindex)

            coreInterface.sendCommand(JSON.stringify(downloadCommand));
        }
    }

    /*
      Installs new resource file and loads it, cleans up old versions
    */
    function installResource(newVersion, newPath) {
        removeControl();

        if (newVersion !== "") {
            let versionControl = versionSettings.readFile("versionControl.json");
            saveInstalledVersion(newVersion, newPath, versionControl)

            for (let i = 0; i < controlViewListCount; i++) {
                if (controlViewList.version(i) === newVersion) {
                    controlViewList.setInstalled(i, true);
                    controlViewList.setFilepath(i, newPath);
                } else if (controlViewList.version(i) !== newVersion
                           && controlViewList.installed(i) === true
                           && !versionInUseOnSystem(controlViewList.version(i), versionControl)) {
                    controlViewList.setInstalled(i, false);
                    let versionToRemove = {
                        "version": controlViewList.version(i),
                        "filepath": controlViewList.filepath(i)
                    }
                    otaVersionsToRemove.push(versionToRemove);
                }
            }
            usingStaticView = false;

            if (platformStack.connected) {
                // Can update from software mgmt while not connected, but don't want to create control view
                registerResource(newPath, newVersion);
            }

            cleanUpResources()
        } else {
            createErrorScreen("No version number found for install")
        }
    }

    /*
      Unregister and delete all resources that are not the new installed one
    */
    function cleanUpResources() {
        // Remove any static resources if available

        if (UuidMap.uuid_map.hasOwnProperty(platformStack.class_id)) {
            let name = UuidMap.uuid_map[platformStack.class_id];
            let RCCpath = sdsModel.resourceLoader.getStaticResourcesString() + "/views-" + name + ".rcc"
            sdsModel.resourceLoader.requestUnregisterDeleteViewResource(platformStack.class_id, RCCpath, controlViewContainer.staticVersion, controlContainer);
        }

        for (let i = 0; i < otaVersionsToRemove.length; i++) {
            sdsModel.resourceLoader.requestUnregisterDeleteViewResource(platformStack.class_id, otaVersionsToRemove[i].filepath, otaVersionsToRemove[i].version, controlContainer);
        }

        otaVersionsToRemove = []
    }

    /*
      Checks if a version is still in user in versionControl.json
    */
    function versionInUseOnSystem(version, versionsInstalled) {
        for (const user of Object.keys(versionsInstalled)) {
            if (user !== NavigationControl.context.user_id) {
                if (SGVersionUtils.equalTo(versionsInstalled[user].version, version)) {
                    return true;
                }
            }
        }
        return false;
    }

    /*
      Update the versionControl.json
    */
    function saveInstalledVersion(version, pathToRcc, versionsInstalled) {
        let user_id = NavigationControl.context.user_id;
        if (!versionsInstalled.hasOwnProperty(user_id)) {
            versionsInstalled[user_id] = {};
        }

        // This signifies that we want to delete the installed version
        if (!version) {
            delete versionsInstalled[user_id];
            versionSettings.writeFile("versionControl.json", versionsInstalled);
            return versionsInstalled;
        }

        if (!versionsInstalled[user_id].hasOwnProperty("version") || !SGVersionUtils.equalTo(versionsInstalled[user_id].version, version)) {
            // Only write to file if the version doesn't exist or the versions are different
            versionsInstalled[user_id].version = version;
            versionsInstalled[user_id].path = pathToRcc;
            versionSettings.writeFile("versionControl.json", versionsInstalled)
            return versionsInstalled;
        }
    }

    /*
      Gets the installed version for the user
    */
    function getInstalledVersion(user_id, versionsInstalled = null) {
        if (!versionsInstalled) {
            versionsInstalled = versionSettings.readFile("versionControl.json");
        }

        if (!versionsInstalled.hasOwnProperty(user_id)) {
            return null;
        }

        return versionsInstalled[user_id];
    }

    /*
      Removes the control view from controlContainer
    */
    function registerResource (filepath, version) {
        let success = sdsModel.resourceLoader.registerControlViewResource(filepath, platformStack.class_id, version);
        if (success) {
            loadingBar.value = 1.0
            loadControl()
        } else {
            createErrorScreen("Failed to find or load control view resource file: " + filepath)
        }
        return success
    }

    /*
      Removes the control view from controlContainer
    */
    function removeControl () {
        if (controlLoaded) {
            controlLoader.setSource("");
            controlLoaded = false
        }
    }

    /*
      Populates controlContainer with an error string
    */
    function createErrorScreen(errorString) {
        removeControl();
        controlLoader.setSource(NavigationControl.screens.LOAD_ERROR, {"error_message": errorString});
    }

    Connections {
        id: coreInterfaceConnections
        target: sdsModel.coreInterface

        onDownloadViewFinished: {
            if (payload.url === activeDownloadUri) {
                activeDownloadUri = ""

                if (payload.error_string.length > 0) {
                    controlViewContainer.createErrorScreen(payload.error_string);
                    return
                }

                for (let i = 0; i < controlViewContainer.controlViewListCount; i++) {
                    if (controlViewContainer.controlViewList.uri(i) === payload.url) {
                        installResource(controlViewContainer.controlViewList.version(i), payload.filepath)
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
