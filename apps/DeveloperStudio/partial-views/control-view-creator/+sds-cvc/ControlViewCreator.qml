/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.signals 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "navigation"
import "../"
import "qrc:/js/constants.js" as Constants
import "qrc:/js/help_layout_manager.js" as Help
import "console"
import "platform-interface-generator"

Rectangle {
    id: controlViewCreatorRoot

    property string projectName
    property bool isConfirmCloseOpen: false
    property bool isConsoleLogOpen: false
    property bool isDebugMenuOpen: false
    property bool popupWindow: false
    property bool debugMenuWindow: false
    property bool recompileRequested: false
    property bool projectInitialization: false
    property bool visualEditorOpen: viewStack.currentIndex === 1
    property string previousCompiledRccFilePath: ""
    property string previousCompiledRccFileUniquePrefix: ""
    property var debugPlatform: ({
                                     device_id: Constants.NULL_DEVICE_ID,
                                     class_id: ""
                                 })

    property alias openFilesModel: editor.openFilesModel
    property alias confirmClosePopup: confirmClosePopup
    property alias editor: editor
    property int consoleLogWarningCount: 0
    property int consoleLogErrorCount: 0

    onDebugPlatformChanged: {
        recompileControlViewQrc()
    }

    Component.onDestruction: {
        controlViewLoader.setSource("")
        if (controlViewCreatorRoot.previousCompiledRccFilePath !== "" && controlViewCreatorRoot.previousCompiledRccFileUniquePrefix !== "") {
            sdsModel.resourceLoader.requestUnregisterResource(controlViewCreatorRoot.previousCompiledRccFilePath, controlViewCreatorRoot.previousCompiledRccFileUniquePrefix, cvcLoader, false)
        }
    }

    Component.onCompleted: {
        cvcUserSettings.loadSettings()
    }

    RowLayout {
        anchors {
            fill: parent
        }
        spacing:  0

        NavigationBar {
            id: navigationBar
        }

        SGSplitView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            orientation: Qt.Vertical

            StackLayout {
                id: viewStack
                Layout.fillHeight: true
                Layout.fillWidth: true
                currentIndex: 0

                Start {
                    id: startContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Editor {
                    id: editor
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Loader {
                    id: controlViewLoader
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.minimumWidth: 600

                    asynchronous: true

                    onStatusChanged: {
                        if (status === Loader.Ready) {
                            // Tear Down creation context
                            delete NavigationControl.context.class_id
                            delete NavigationControl.context.device_id

                            recompileRequested = false
                        } else if (status === Loader.Error) {
                            // Tear Down creation context
                            delete NavigationControl.context.class_id
                            delete NavigationControl.context.device_id

                            recompileRequested = false
                            console.error("Error while loading control view")
                            setSource(NavigationControl.screens.LOAD_ERROR,
                                      { "error_message": "Failed to load control view: " + sourceComponent.errorString() }
                                      );
                        }
                    }
                }

                PlatformInterfaceGenerator {
                    id: platformInterfaceGenerator
                }
            }

            Item {
                id: editViewConsoleContainer
                Layout.minimumHeight: 30
                implicitHeight: 200
                Layout.fillWidth: true
                visible: viewStack.currentIndex === 1 && isConsoleLogOpen === true && popupWindow === false
            }
        }
    }

    Item {
        id: debugMenuContainer
        width: parent.width - navigationBar.width
        height: parent.height
        anchors.top: parent.top
        anchors.right: parent.right
        visible: viewStack.currentIndex === 2 && isDebugMenuOpen === true && debugMenuWindow === false
    }

    DebugPanel {
        id: debugPanel
        parent: {
            if (debugMenuWindow) {
                return newWindowDebugMenuLoader.item.consoleLogParent
            } else {
                return debugMenuContainer
            }
        }
    }

    ConsoleContainer {
        id: consoleContainer
        parent: {
            if (popupWindow) {
                return newWindowLoader.item.consoleLogParent
            } else if (viewStack.currentIndex === 1) {
                return editViewConsoleContainer
            } else {
                return viewConsoleLog.consoleLogParent
            }
        }

        onClicked: {
            isConsoleLogOpen = false
        }
    }

    ViewConsoleContainer {
        id: viewConsoleLog
        width: parent.width - 71
        implicitHeight: parent.height
        visible: viewStack.currentIndex === 2 && isConsoleLogOpen === true && popupWindow === false
    }

    Loader {
        id: newWindowLoader
        active: popupWindow
        source: "console/NewWindowConsoleLog.qml"
    }

    Loader {
        id: newWindowDebugMenuLoader
        active: debugMenuWindow
        source: "NewWindowDebugMenu.qml"
    }

    ConfirmClosePopup {
        id: confirmBuildClean
        parent: mainWindow.contentItem

        titleText: "Stopping build due to unsaved changes in the project"
        popupText: "Some files have unsaved changes, would you like to save all changes before build or build without saving?"

        acceptButtonText: "Save All and Build"
        closeButtonText: "Build Without Saving"

        onPopupClosed: {
            if (closeReason === cancelCloseReason) {
                return
            }

            if (closeReason === acceptCloseReason) {
                editor.openFilesModel.saveAll(false)
            }

            if (cvcUserSettings.openViewOnBuild) {
                viewStack.currentIndex = 2
            }

            requestRecompile()
        }
    }

    ConfirmClosePopup {
        id: confirmClosePopup
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        parent: mainWindow.contentItem

        titleText: "You have unsaved changes in " + unsavedFileCount + " files."
        acceptButtonText: "Save all"

        property int unsavedFileCount
        property var callbackFunc

        onPopupClosed: {
            if (closeReason === confirmClosePopup.closeFilesReason) {
                if (platformInterfaceGenerator.unsavedChanges) {
                    pigConfirmClosePopup.callbackFunc = callbackFunc
                    pigConfirmClosePopup.open()
                } else {
                    controlViewCreator.openFilesModel.closeAll()
                    callbackFunc()
                }
            } else if (closeReason === confirmClosePopup.acceptCloseReason) {
                controlViewCreator.openFilesModel.saveAll(true)

                if (platformInterfaceGenerator.unsavedChanges) {
                    pigConfirmClosePopup.callbackFunc = callbackFunc
                    pigConfirmClosePopup.open()
                } else {
                    controlViewCreator.openFilesModel.closeAll()
                    callbackFunc()
                }
            }

            isConfirmCloseOpen = false
        }
    }

    SGConfirmationPopup {
        id: pigConfirmClosePopup
        modal: true
        padding: 0
        closePolicy: Popup.NoAutoClose

        titleText: "You have unsaved changes in the Platform Interface Generator"
        popupText: "Platform Interface Generator:\nYour changes will be lost if you choose to not save them."
        acceptButtonColor: Theme.palette.error
        acceptButtonHoverColor: Qt.darker(acceptButtonColor, 1.25)
        acceptButtonText: "Continue without Saving"
        cancelButtonText: "Cancel"

        property var callbackFunc

        onPopupClosed: {
            if (closeReason === confirmClosePopup.acceptCloseReason) {
                callbackFunc()
            }

            isConfirmCloseOpen = false
        }
    }

    SGConfirmationPopup {
        id: confirmCleanFiles
        modal: true
        padding: 0
        closePolicy: Popup.NoAutoClose

        acceptButtonColor: Theme.palette.onsemiCyan
        acceptButtonHoverColor: Qt.darker(acceptButtonColor, 1.25)
        acceptButtonText: "Clean"
        cancelButtonText: "Cancel"
        titleText: "Remove missing files"
        popupText: {
            let text = "Are you sure you want to remove the following files from this project's QRC?<br><ul type=\"bullet\">";
            for (let i = 0; i < missingFiles.length; i++) {
                text += "<li>" + missingFiles[i] + "</li>"
            }
            text += "</ul>"
            return text
        }

        property var missingFiles: []

        onOpened: {
            missingFiles = editor.fileTreeModel.getMissingFiles()
        }

        onPopupClosed: {
            if (closeReason === acceptCloseReason) {
                editor.fileTreeModel.removeDeletedFilesFromQrc()
            }
        }
    }

    SGConfirmationPopup {
        id: missingControlQml
        modal: true
        padding: 0
        closePolicy: Popup.NoAutoClose

        buttons: [okButtonObject]

        property var okButtonObject: ({
                                          buttonText: "Ok",
                                          buttonColor: acceptButtonColor,
                                          buttonHoverColor: acceptButtonHoverColor,
                                          closeReason: acceptCloseReason
                                      });

        titleText: "Missing Control.qml"
        popupText: "You are missing a Control.qml file at the root of your project. This will cause errors when trying to build the project."
    }

    SGUserSettings {
        id: sgUserSettings
        classId: "controlViewCreator"
        user: NavigationControl.context.user_id
    }

    function recompileControlViewQrc() {
        if (editor.fileTreeModel.url.toString() !== '') {
            if (editor.openFilesModel.getUnsavedCount() > 0) {
                confirmBuildClean.open()
            } else {
                requestRecompile()
            }
        }
    }

    function requestRecompile() {
        recompileRequested = true
        controlViewLoader.setSource("")
        Help.resetDeviceIdTour(debugPlatform.device_id)
        sdsModel.resourceLoader.recompileControlViewQrc(SGUtilsCpp.urlToLocalFile(editor.fileTreeModel.url))
    }

    function registerAndSetRecompiledRccFile(compiledRccFile) {
        // Unregister previous (cached) resource
        if (controlViewCreatorRoot.previousCompiledRccFilePath !== "" && controlViewCreatorRoot.previousCompiledRccFileUniquePrefix !== "") {
            sdsModel.resourceLoader.unregisterResource(controlViewCreatorRoot.previousCompiledRccFilePath, controlViewCreatorRoot.previousCompiledRccFileUniquePrefix, controlViewLoader, false)
        }

        // Register new control view resource
        const uniquePrefix = "/" + new Date().getTime().valueOf()
        if (!sdsModel.resourceLoader.registerResource(compiledRccFile, uniquePrefix)) {
            console.error("Failed to register resource")
            return
        }

        controlViewCreatorRoot.previousCompiledRccFilePath = compiledRccFile
        controlViewCreatorRoot.previousCompiledRccFileUniquePrefix = uniquePrefix

        Help.setDeviceId(debugPlatform.device_id)
        NavigationControl.context.class_id = debugPlatform.class_id
        NavigationControl.context.device_id = debugPlatform.device_id

        const controlPath = "qrc:" + uniquePrefix + "/Control.qml"
        controlViewLoader.setSource(controlPath, Object.assign({}, NavigationControl.context))
    }

    function blockWindowClose(callback) {
        let unsavedCount = editor.openFilesModel.getUnsavedCount()
        if (unsavedCount > 0 && !controlViewCreatorRoot.isConfirmCloseOpen) {
            confirmClosePopup.unsavedFileCount = unsavedCount
            confirmClosePopup.callbackFunc = callback
            confirmClosePopup.open()
            controlViewCreatorRoot.isConfirmCloseOpen = true
            return true
        }
        if (platformInterfaceGenerator.unsavedChanges && !controlViewCreatorRoot.isConfirmCloseOpen) {
            pigConfirmClosePopup.callbackFunc = callback
            pigConfirmClosePopup.open()
            controlViewCreatorRoot.isConfirmCloseOpen = true
            return true
        }

        return false
    }

    function getProjectNameFromCmake() {
        controlViewCreatorRoot.projectName = sdsModel.resourceLoader.getProjectNameFromCmake(SGUtilsCpp.urlToLocalFile(editor.fileTreeModel.url))
    }

    Connections {
        target: sdsModel.resourceLoader

        onFinishedRecompiling: {
            if (recompileRequested) { // enforce that CVC requested this recompile
                if (filepath === '') {
                    let error_str = sdsModel.resourceLoader.getLastLoggedError()
                    controlViewLoader.setSource(NavigationControl.screens.LOAD_ERROR,
                                                { "error_message": error_str });
                    recompileRequested = false
                    return
                }

                registerAndSetRecompiledRccFile(filepath)

                if (projectInitialization) {
                    projectInitialization = false
                    controlViewCreatorRoot.editor.sideBar.openControlQML()
                }
            }
        }
    }

    SGUserSettings {
        id: cvcUserSettings
        classId: "cvc-settings"
        user: NavigationControl.context.user_id

        property bool openViewOnBuild: false
        property bool reloadViewExternalChanges: true

        function loadSettings() {
            const settings = readFile("cvc-settings.json")

            if (settings.hasOwnProperty("openViewOnBuild")) {
                openViewOnBuild = settings.openViewOnBuild
            }
            if (settings.hasOwnProperty("reloadViewExternalChanges")) {
                reloadViewExternalChanges = settings.reloadViewExternalChanges
            }
        }

        function saveSettings() {
            const settings = {
                openViewOnBuild: openViewOnBuild,
                reloadViewExternalChanges: reloadViewExternalChanges
            }

            writeFile("cvc-settings.json", settings)
        }
    }
}
