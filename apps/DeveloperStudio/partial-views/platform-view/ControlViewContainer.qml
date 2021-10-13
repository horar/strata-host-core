/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.logger 1.0

Item {
    id: controlViewContainer

    property string activeDownloadUri: ""
    property var otaVersionsToRemove: []
    property var controlViewList: sdsModel.documentManager.getClassDocuments(platformStack.class_id).controlViewListModel
    property int controlViewListCount: controlViewList.count
    property bool controlLoaded: false
    property real loadTime

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
                loadingStatusContainer.state = "loaded"
                if (source.toString() !== NavigationControl.screens.LOAD_ERROR) {
                    console.log(Logger.devStudioCategory, "Loaded control view in " + (Date.now() - loadTime)/1000 + " seconds")
                }
            } else if (status === Loader.Error) {
                // Tear Down creation context
                delete NavigationControl.context.class_id
                delete NavigationControl.context.device_id

                createErrorScreen("Failed to load file: " + source + "\nError: " + sourceComponent.errorString())
            }
        }
    }

    Rectangle {
        id: loadingStatusContainer
        anchors {
            fill: parent
        }
        visible: state !== "loaded"
        state: "loaded"

        RowLayout {
            anchors {
                centerIn: parent
            }
            spacing: 20

            AnimatedImage {
                playing: visible
                source: "qrc:/images/loading.gif"
            }

            ColumnLayout {

                SGText {
                    id: loadingText
                    fontSizeMultiplier: 2
                    color: "#666"
                    text: {
                        switch (loadingStatusContainer.state) {
                        case "downloading":
                            return "Downloading Control View..."
                        case "loading":
                            return "Loading Control View..."
                        default:
                            return ""
                        }
                    }
                }

                ProgressBar {
                    id: loadingBar
                    visible: loadingStatusContainer.state === "downloading"

                    background: Rectangle {
                        id: barContainer
                        implicitWidth: controlViewContainer.width / 2
                        implicitHeight: 15
                        color: "#e6e6e6"
                        radius: 5
                    }

                    contentItem: Item {
                        implicitWidth: loadingBar.background.implicitWidth
                        implicitHeight: loadingBar.background.implicitHeight

                        Rectangle {
                            id: bar
                            color: "#57d445"
                            height: parent.height
                            width: loadingBar.visualPosition * loadingBar.width
                            radius: 5
                        }
                    }
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
            let versionControl = versionSettings.readFile("versionControl.json")
            const versionInstalled = getInstalledVersion(NavigationControl.context.user_id, versionControl)

            if (sdsModel.resourceLoader.isViewRegistered(platformStack.class_id)
                    && (versionInstalled === null || versionInstalled.version === sdsModel.resourceLoader.getVersionRegistered(platformStack.class_id))) {
                loadControl()
            } else {
                getOTAResource()
            }
        }
    }

    /*
      Loads Control.qml from the installed resource file into controlLoader
    */
    function loadControl() {
        loadingStatusContainer.state = "loading"

        let installedVersion = getInstalledVersion(NavigationControl.context.user_id)
        let version = installedVersion.version

        let control_filepath = NavigationControl.getQMLFile("Control", platformStack.class_id, version)

        // Set up context for control object creation
        Help.setDeviceId(platformStack.device_id)
        NavigationControl.context.class_id = platformStack.class_id
        NavigationControl.context.device_id = platformStack.device_id
        loadTime = Date.now()
        controlLoader.setSource(control_filepath, Object.assign({}, NavigationControl.context))
    }

    /*
        Try to find an installed OTA resource file and load it, otherwise download newest version
    */
    function getOTAResource() {
        let versionControl = versionSettings.readFile("versionControl.json")
        const versionInstalled = getInstalledVersion(NavigationControl.context.user_id, versionControl)

        if (versionInstalled) {
            if (!SGUtilsCpp.isFile(versionInstalled.path)) {
                versionControl = saveInstalledVersion(null, null, versionControl)
            } else if (registerResource(versionInstalled.path, versionInstalled.version)) {
                return
            }
        }

        // Find index of any installed version
        let installedVersionIndex = controlViewList.getInstalledVersionIndex()

        if (installedVersionIndex >= 0) {
            loadingStatusContainer.state = "loading"
            saveInstalledVersion(controlViewList.version(installedVersionIndex), controlViewList.filepath(installedVersionIndex), versionControl)
            registerResource(controlViewList.filepath(installedVersionIndex), controlViewList.version(installedVersionIndex))
        } else {
            let latestVersionIndex = controlViewList.getLatestVersionIndex()

            if (controlViewList.uri(latestVersionIndex) === "" || controlViewList.md5(latestVersionIndex) === "") {
                createErrorScreen("Found no local control view and none for download.")
                return
            }

            loadingBar.value = 0
            loadingStatusContainer.state = "downloading"

            let downloadCommand = {
                "url": controlViewList.uri(latestVersionIndex),
                "md5": controlViewList.md5(latestVersionIndex),
                "class_id": platformStack.class_id
            }

            activeDownloadUri = controlViewList.uri(latestVersionIndex)

            sdsModel.strataClient.sendRequest("download_view", downloadCommand)
        }
    }

    /*
      Installs new resource file and loads it, cleans up old versions
    */
    function installResource(newVersion, newPath) {
        removeControl()

        if (newVersion !== "") {
            let versionControl = versionSettings.readFile("versionControl.json")
            saveInstalledVersion(newVersion, newPath, versionControl)

            for (let i = 0; i < controlViewListCount; i++) {
                if (controlViewList.version(i) === newVersion) {
                    controlViewList.setInstalled(i, true)
                    controlViewList.setFilepath(i, newPath)
                } else if (controlViewList.version(i) !== newVersion
                           && controlViewList.installed(i) === true
                           && !versionInUseOnSystem(controlViewList.version(i), versionControl)) {
                    controlViewList.setInstalled(i, false)
                    let versionToRemove = {
                        "version": controlViewList.version(i),
                        "filepath": controlViewList.filepath(i)
                    }
                    otaVersionsToRemove.push(versionToRemove)
                }
            }

            if (platformStack.connected) {
                // Can update from software mgmt while not connected, but don't want to create control view
                registerResource(newPath, newVersion)
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
        for (let i = 0; i < otaVersionsToRemove.length; i++) {
            sdsModel.resourceLoader.requestUnregisterDeleteViewResource(platformStack.class_id, otaVersionsToRemove[i].filepath, otaVersionsToRemove[i].version, controlLoader)
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
                    return true
                }
            }
        }
        return false
    }

    /*
      Update the versionControl.json
    */
    function saveInstalledVersion(version, pathToRcc, versionsInstalled) {
        let user_id = NavigationControl.context.user_id
        if (!versionsInstalled.hasOwnProperty(user_id)) {
            versionsInstalled[user_id] = {}
        }

        // This signifies that we want to delete the installed version
        if (!version) {
            delete versionsInstalled[user_id]
            versionSettings.writeFile("versionControl.json", versionsInstalled)
            return versionsInstalled
        }

        if (!versionsInstalled[user_id].hasOwnProperty("version") || !SGVersionUtils.equalTo(versionsInstalled[user_id].version, version)) {
            // Only write to file if the version doesn't exist or the versions are different
            versionsInstalled[user_id].version = version
            versionsInstalled[user_id].path = pathToRcc
            versionSettings.writeFile("versionControl.json", versionsInstalled)
            return versionsInstalled
        }
    }

    /*
      Gets the installed version for the user
    */
    function getInstalledVersion(user_id, versionsInstalled = null) {
        if (!versionsInstalled) {
            versionsInstalled = versionSettings.readFile("versionControl.json")
        }

        if (!versionsInstalled.hasOwnProperty(user_id)) {
            return null
        }

        return versionsInstalled[user_id]
    }

    /*
      Registers a resource file by path and version
    */
    function registerResource (filepath, version) {
        let success = sdsModel.resourceLoader.registerControlViewResource(filepath, platformStack.class_id, version)
        if (success) {
            loadingBar.value = 1.0
            loadControl()
        } else {
            createErrorScreen("Failed to find or load control view resource file: " + filepath)
        }
        return success
    }

    /*
      Removes the control view from controlLoader
    */
    function removeControl () {
        if (controlLoaded) {
            controlLoader.setSource("")
            controlLoaded = false
        }
    }

    /*
      Populates controlLoader with an error string
    */
    function createErrorScreen(errorString) {
        removeControl()
        controlLoader.setSource(NavigationControl.screens.LOAD_ERROR, {"error_message": errorString})
    }

    Connections {
        id: coreInterfaceConnections
        target: sdsModel.coreInterface

        onDownloadViewFinished: {
            if (payload.url === activeDownloadUri) {
                activeDownloadUri = ""

                if (payload.error_string.length > 0) {
                    controlViewContainer.createErrorScreen(payload.error_string)
                    return
                }

                for (let i = 0; i < controlViewContainer.controlViewListCount; i++) {
                    if (controlViewContainer.controlViewList.uri(i) === payload.url) {
                        installResource(controlViewContainer.controlViewList.version(i), payload.filepath)
                        break
                    }
                }
            }
        }

        onDownloadControlViewProgress: {
            if (payload.url === activeDownloadUri) {
                let percent = payload.bytes_received / payload.bytes_total
                loadingBar.value = percent
            }
        }
    }
}
