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
        removeControl()
    }

    function initialize () {
        if (fullyInitialized) { // guarantee control view loads after platformStack & sgUserSettings
            if (connected && model.available.control) {
                loadControl()
            } else {
                removeControl()
            }
        }
    }

    function loadControl () {
        if (controlLoaded === false){
            Help.setClassId(model.device_id)
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

    Item {
        id: controlStackContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

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
}
