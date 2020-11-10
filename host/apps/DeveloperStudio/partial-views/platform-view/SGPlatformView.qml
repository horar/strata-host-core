import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.common 1.0
import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl

StackLayout {
    id: platformStack

    currentIndex:  {
        switch (model.view) {
            case "collateral":
                return 1
            case "settings":
                return 2
            default: // case "control":
                return 0
       }

    }

    property var device_id: model.device_id // var type so Constants.DEVICE_IDs are not coerced to 32 bit signed ints
    property string class_id: model.class_id
    property string firmware_version: model.firmware_version
    property bool connected: model.connected
    property string name: model.name
    property alias controlViewContainer: controlViewContainer

    property bool platformIsOutOfDate: false
    property bool firmwareIsOutOfDate: false
    property bool platformDocumentsInitialized: sdsModel.documentManager.getClassDocuments(model.class_id).initialized;
    property bool platformStackInitialized: false
    property bool userSettingsInitialized: false
    property bool fullyInitialized: platformStackInitialized &&
                                    userSettingsInitialized &&
                                    platformDocumentsInitialized

    onFullyInitializedChanged: {
        initialize()
    }

    onConnectedChanged: {
        initialize()
    }

    Component.onCompleted: {
        platformStackInitialized = true
    }

    Component.onDestruction: {
        controlViewContainer.removeControl()
    }

    function initialize () {
        // guarantee control view loads after platformStack & sgUserSettings etc
        if (fullyInitialized) {
            if (connected && model.available.control) {
                controlViewContainer.initialize()
            } else {
                controlViewContainer.removeControl()
            }
        }
    }

    function navigateToPlatform() {
        model.view = "settings"
    }

    ControlViewContainer {
         id: controlViewContainer
         Layout.fillHeight: true
         Layout.fillWidth: true
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

        property int stackIndex: 2 // must be updated if platformStack order is modified
        property alias platformSettings: platformSettings

        PlatformSettings {
            id: platformSettings
        }
    }

    SGUserSettings {
        id: sgUserSettings
        classId: platformStack.class_id
        user: NavigationControl.context.user_id

        Component.onCompleted: {
            platformStack.userSettingsInitialized = true
        }
    }

    SGUserSettings {
        id: versionSettings
        classId: platformStack.class_id
        user: "strata"
    }
}
