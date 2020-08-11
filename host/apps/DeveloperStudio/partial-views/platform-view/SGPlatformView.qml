import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.common 1.0
import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/help_layout_manager.js" as Help

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
    property bool connected: model.connected
    property bool controlLoaded: false

    onConnectedChanged: {
        if (connected && model.available.control) {
            loadPlatformDocuments()
//            loadControl()
        } else {
            removeControl()
        }
    }

    Component.onCompleted: {
        if (model.connected && model.available.control) {
            loadPlatformDocuments()
//            loadControl()  // load control
        }
    }

    Component.onDestruction: {
        removeControl()
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

            if (sdsModel.resourceLoader.registerControlViewResources(model.class_id) === false) {
                console.error("Failed to load resource")
            }

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

    function removeControl () {
        if (controlLoaded) {
            NavigationControl.removeView(controlContainer)
            controlLoaded = false
        }
    }

    /* The Order of Operations here is as follows:
        1. Call loadPlatformDocuments()
        2. If controlViewListModel is not populated yet, then follow substeps, otherwise go to step 3.
            2.1. Start the population of controlViewListModel
            2.2. When finished populating, main.qml will catch documentManager.onPopulateModelsFinished and will call PlatformSelection.onControlViewListPopulated
            2.3. onControlViewListPopulated will then call loadPlatformDocuments() again, but the model will be populated this time. So go back to step 1.
        3. Call downloadControlView(). If already downloaded, then go to step 4 otherwise follow substeps
            3.1. Send the download command to hcs
            3.2. Main.qml will catch the onControlViewDownloadFinished signal and will call PlatformSelection.onControlViewDownloadFinished()
        4. Call openPlatformView()
    */
    function loadPlatformDocuments() {
        if (NavigationControl.isViewRegistered(model.class_id)) {
            controlContainer.percentReady = 1.0
            return;
        }

        let controlViewList = sdsModel.documentManager.getClassDocuments(model.class_id).controlViewListModel;

        if (controlViewList.count > 0) {
            downloadControlView()
        }
    }

    /*
        Helper function for downloading a control view
        Returns false if unable to run download_view cmd, otherwise true
    */
    function downloadControlView() {
        // this line below will start the process for downloading metadata about the control views
        // so the first time it runs, it will return 0 for count, and asynchronously populate
        let controlViewList = sdsModel.documentManager.getClassDocuments(model.class_id).controlViewListModel;

        // get installed index instead of latest version
        let index = controlViewList.getLatestVersion();

        if (index < 0) {
            console.error("Unable to load control view list for", model.class_id)
            return
        }

        if (controlViewList.installed(index) === false) {
            console.info("Downloading control view for ", model.class_id)
            let command = {
                "hcs::cmd": "download_view",
                "payload": {
                    "url": controlViewList.uri(index),
                    "md5": controlViewList.md5(index)
                }
            }

            coreInterface.sendCommand(JSON.stringify(command))
        } else {
            sdsModel.resourceLoader.registerControlViewResources(model.class_id);
        }
    }

    Item {
        id: controlStackContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        Item {
            id: controlContainer

            property double percentReady: 0.0

            anchors {
                fill: parent
            }

            onPercentReadyChanged: {
                console.info("test -- percent ready", percentReady)
                if (percentReady === 1.0) {
                    loadingTimer.start()
                }
            }

            Timer {
                id: loadingTimer
                repeat: false
                interval: 2000

                onTriggered: {
                    loadingText.visible = false
                    loadControl();
                }
            }

            Text {
                id: loadingText
                x: parent.width / 2 - width / 2
                y: parent.height / 2 - height / 2

                text: "Loading: " + parent.percentReady + "%"
                font: {
                    minimumPixelSize: 56
                }
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
        target: sdsModel.documentManager

        onPopulateModelsFinished: {
            if (classId === model.class_id) {
                console.info("test -- populateModelsFinished")
                if (controlContainer.percentReady < 0.25) {
                    controlContainer.percentReady = 0.25;
                }
                loadPlatformDocuments();
            }
        }
    }

    Connections {
        target: sdsModel.coreInterface

        onDownloadViewFinished: {
            // hacky way to get the class_id from the request.
            // e.g. "url":"226/control_views/1.1.3/views-hello-strata.rcc"
            let class_id = payload.url.split("/")[0];
            if (class_id === model.class_id) {
                console.info("test -- viewDownloaded")
                if (controlContainer.percentReady < 0.5) {
                    controlContainer.percentReady = 0.50;
                }
                sdsModel.resourceLoader.registerControlViewResources(model.class_id)
            }
        }
    }

    Connections {
        target: sdsModel.resourceLoader

        onResourceRegistered: {
            if (class_id === model.class_id) {
                console.info("test -- resourceRegistered")
                controlContainer.percentReady = 1.0;
            }
        }

        onResourceRegisterFailed: {
            if (class_id === model.class_id) {
                console.info("test -- resourceFailed")
                controlContainer.percentReady = 1.0;
            }
        }

    }
}
