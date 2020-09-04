import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

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
    property alias loadingBar: loadingBar

    property int device_id: model.device_id
    property string class_id: model.class_id
    property string firmware_version: model.firmware_version
    property var controlViewList: sdsModel.documentManager.getClassDocuments(model.class_id).controlViewListModel
    property int controlViewListCount: controlViewList.count
    property bool platformDocumentsInitialized: sdsModel.documentManager.getClassDocuments(model.class_id).initialized;
    property bool connected: model.connected
    property bool controlLoaded: false
    property bool fullyInitialized: platformStack.initialized && sgUserSettings.initialized
    property bool initialized: false

    onConnectedChanged: {
        initialize()
    }

    Component.onCompleted: {
        initialized = true
        initialize()
    }

    Component.onDestruction: {
        controlContainer.removeControl()
    }

    onCurrentIndexChanged: {
        if (index === 0) {
            if (controlLoaded === false && connected) {
                loadingBar.visible = true;
                if (sdsModel.resourceLoader.isViewRegistered(model.class_id)) {
                    loadingBar.value = 1.0
                }
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
                if (sdsModel.resourceLoader.isViewRegistered(model.class_id)) {
                    if (sdsModel.resourceLoader.getVersionRegistered(model.class_id) !== "") {
                        controlContainer.usingLocalView = false;
                    }
                    loadControl()
                } else {
                    // Connect signals to slots first. This is to remedy the issue where the Connections component was not yet completed
                    // when the signal was emitted
                    sdsModel.resourceLoader.resourceRegistered.connect(resourceRegistered);
                    sdsModel.resourceLoader.resourceRegisterFailed.connect(resourceRegisterFailed);
                    loadingBar.visible = true;
                    loadingBar.value = 0.0;
                    if (platformDocumentsInitialized === true) {
                        loadingBar.value = 0.01;
                        controlContainer.checkForResources()
                    }
                }
            } else {
                controlContainer.removeControl()
            }
        }
    }

    function loadControl () {
        if (controlLoaded === false){
            Help.setClassId(model.device_id)
            sgUserSettings.classId = model.class_id

            let version = "";
            let name = UuidMap.uuid_map[model.class_id];

            if (!name) {
                name = model.name
            }

            if (controlContainer.usingLocalView === false) {
                let idx = controlViewList.getInstalledVersion();

                if (idx >= 0) {
                    version = controlViewList.version(idx);
                }
            }

            let qml_control = NavigationControl.getQMLFile(model.class_id, name, "Control", controlContainer.usingLocalView, version)
            NavigationControl.context.class_id = model.class_id
            NavigationControl.context.device_id = model.device_id

            loadingBar.visible = false;
            loadingBar.value = 0.0;
            let obj = sdsModel.resourceLoader.createViewObject(qml_control, controlContainer);
            if (obj === null) {
                createErrorScreen("Could not load view.")
            } else {
                controlLoaded = true
            }

            delete NavigationControl.context.class_id
            delete NavigationControl.context.device_id
        }
    }

    /*
      Slot for the sdsModel.resourceLoader.resourceRegistered signal
    */
    function resourceRegistered (class_id) {
        if (class_id === platformStack.class_id) {
            loadingBar.color = "#57d445"
            loadingBar.value = 1.0;
        }
    }

    /*
      Slot for the sdsModel.resourceLoader.resourceRegisteredFailed signal
    */
    function resourceRegisterFailed (class_id) {
        if (class_id === platformStack.class_id) {
            controlContainer.removeControl()
            createErrorScreen("Failed to find resource.")
        }
    }

    function createErrorScreen(errorString) {
        let obj = sdsModel.resourceLoader.createViewObject(NavigationControl.screens.LOAD_ERROR, controlContainer, {"error_message": errorString});
        controlLoaded = true
    }

    Item {
        id: controlStackContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        ProgressBar {
            id: loadingBar

            x: platformStack.width / 2 - width / 2
            y: platformStack.height / 2 - height / 2

            property alias color: bar.color

            background: Rectangle {
                id: barContainer
                implicitWidth: platformStack.width / 2
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

        ControlViewContainer {
             id: controlContainer
             index: 0
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
        target: sdsModel.documentManager

        onPopulateModelsFinished: {
            if (classId === model.class_id && model.connected) {
                if (loadingBar.value === 0.0) {
                    loadingBar.value = 0.01
                    controlContainer.checkForResources()
                }
            }
        }
    }

    Connections {
        target: loadingBar

        onValueChanged: {
            if (loadingBar.value === 1.0) {
                loadControl()
            }
        }
    }
}
