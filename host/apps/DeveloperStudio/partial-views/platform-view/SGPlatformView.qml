import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12

import tech.strata.common 1.0
import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_notification.js" as PlatformNotification

import QtQuick.Controls 2.12
import tech.strata.notifications 1.0

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

    property var device_id: model.device_id // var type so Constants.DEVICE_IDs are not coerced to 32 bit signed ints
    property string class_id: model.class_id
    property string firmware_version: model.firmware_version
    property bool connected: model.connected
    property string name: model.name
    property alias controlViewContainer: controlViewContainer
    property string view: model.view

    property bool platformMetaDataInitialized: sdsModel.documentManager.getClassDocuments(model.class_id).metaDataInitialized;
    property bool platformStackInitialized: false
    property bool userSettingsInitialized: false
    property bool fullyInitialized: platformStackInitialized &&
                                    userSettingsInitialized &&
                                    platformMetaDataInitialized

    property bool documentsHistoryDisplayed: false

    onFullyInitializedChanged: {
        initialize()
    }

    onConnectedChanged: {
        initialize()
    }

    onViewChanged: {
        if (view == "collateral") {
            platformStack.documentsHistoryDisplayed = true
        }
    }

    Connections {
        target: PlatformNotification.signals

        onExecuteAction:{
            if(key === "Collateral"){
                switch(type){
                case "View": viewDocuments()
                    break;
                case "Close": closeNotification()
                    break;
                case "Disable": disableNotification()
                    break;
                }
            }
        }
    }


    function viewDocuments() {
        model.view = "collateral"
    }

    function closeNotification(){

    }

    function disableNotification() {
        NavigationControl.userSettings.notifyOnCollateralDocumentUpdate = false
        NavigationControl.userSettings.saveSettings()
    }


    Component.onCompleted: {
        platformStackInitialized = true
        PlatformNotification.createDynamicNotifications({key:"Collateral",data: [
                                                                {
                                                                    "text": "View documents",
                                                                    "action": "View"
                                                                },
                                                                {
                                                                    "text": "Ok",
                                                                    "action": "Close"
                                                                },
                                                                {
                                                                    "text": "Don't show this message again",
                                                                    "action": "Disable"
                                                                },
                                                            ]
                                                        })
    }

    Component.onDestruction: {
        controlViewContainer.removeControl()
        PlatformNotification.destroyNotifications("Collateral")
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

        function launchDocumentsHistoryNotification(unseenPdfItems, unseenDownloadItems) {
            if (NavigationControl.userSettings.notifyOnCollateralDocumentUpdate == false) {
                return
            }

            if (Object.keys(unseenPdfItems).length == 1 && Object.keys(unseenDownloadItems).length == 0) {
                var description = "A document has been updated:\n" + unseenPdfItems[0]
            } else if (Object.keys(unseenPdfItems).length == 0 && Object.keys(unseenDownloadItems).length == 1) {
                var description = "A document has been updated:\n" + unseenDownloadItems[0]
            } else {
                var numberDocumentsUpdated = Number(Object.keys(unseenPdfItems).length) + Number(Object.keys(unseenDownloadItems).length)
                var description = "Multiple documents have been updated (" + numberDocumentsUpdated + " total)"
            }

            if (platformStack.currentIndex == 0) { // check if control view is displayed
                PlatformNotification.createNotification(
                    "Document updates for this platform",
                    Notifications.Info,
                    "current",
                    {
                        "description": description,
                        "iconSource": "qrc:/sgimages/exclamation-circle.svg",
                        "actions": PlatformNotification.getNotificationActions("Collateral"),
                        "timeout": 0
                    },
                    "Collateral"
                )
            }
        }
    }

    Item {
        id: settingsContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        property int stackIndex: 2 // must be updated if platformStack order is modified
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
