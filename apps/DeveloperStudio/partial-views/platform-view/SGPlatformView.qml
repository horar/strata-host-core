/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.common 1.0
import tech.strata.commoncpp 1.0
import tech.strata.notifications 1.0

import "qrc:/js/navigation_control.js" as NavigationControl

import QtQuick.Controls 2.12

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
    property string notificationUUID: ""

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

    Component.onCompleted: {
        platformStackInitialized = true
    }

    Component.onDestruction: {
        controlViewContainer.removeControl()
        if(notificationUUID !== ""){
            Notifications.destroyNotification(notificationUUID)
        }
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

        Action {
            id: documentsHistoryShowDocumentsView
            text: "View documents"
            onTriggered: {
                model.view = "collateral"
            }
        }

        Action {
            id: doNotNotifyOnCollateralDocumentUpdate
            text: "Don't show this message again"
            onTriggered: {
                NavigationControl.userSettings.notifyOnCollateralDocumentUpdate = false
                NavigationControl.userSettings.saveSettings()
            }
        }

        Action {
            id: ok
            text: "Ok"
            onTriggered: {}
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
              notificationUUID = Notifications.createNotification(
                    "Document updates for this platform",
                    Notifications.Info,
                    "current",
                    {
                        "description": description,
                        "iconSource": "qrc:/sgimages/exclamation-circle.svg",
                        "actions": [documentsHistoryShowDocumentsView, ok, doNotNotifyOnCollateralDocumentUpdate],
                        "timeout": 0
                    }
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
