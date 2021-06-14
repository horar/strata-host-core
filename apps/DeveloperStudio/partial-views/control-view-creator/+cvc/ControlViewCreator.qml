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
import "Console"
import "PlatformInterfaceGenerator"

Rectangle {
    id: controlViewCreatorRoot

    property bool isConfirmCloseOpen: false
    property bool isConsoleLogOpen: false
    property bool recompileRequested: false
    property bool projectInitialization: false
    property string previousCompiledRccFilePath: ""
    property string previousCompiledRccFileUniquePrefix: ""
    property var debugPlatform: ({
                                     deviceId: Constants.NULL_DEVICE_ID,
                                     classId: ""
                                 })

    property alias openFilesModel: editor.openFilesModel
    property alias confirmClosePopup: confirmClosePopup
    property alias editor: editor

    onDebugPlatformChanged: {
        recompileControlViewQrc()
    }

    Component.onDestruction: {
        controlViewLoader.setSource("")
        if (controlViewCreatorRoot.previousCompiledRccFilePath !== "" && controlViewCreatorRoot.previousCompiledRccFileUniquePrefix !== "") {
            sdsModel.resourceLoader.requestUnregisterResource(controlViewCreatorRoot.previousCompiledRccFilePath, controlViewCreatorRoot.previousCompiledRccFileUniquePrefix, cvcLoader, false)
        }
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

                SGSplitView {
                    id: controlViewContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    onResizingChanged: {
                        if (!resizing) {
                            if (debugPanel.width >= debugPanel.minimumExpandWidth) {
                                debugPanel.expandWidth = debugPanel.width
                            } else {
                                debugPanel.expandWidth = debugPanel.minimumExpandWidth
                            }
                        }
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

                    DebugPanel {
                        id: debugPanel
                        Layout.fillHeight: true
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
                visible:  viewStack.currentIndex === 1 &&  isConsoleLogOpen === true
            }
        }
    }

    ConsoleContainer {
        id:consoleContainer
        parent: (viewStack.currentIndex === 1) ? editViewConsoleContainer : viewConsoleLog.consoleLogParent
        onClicked: {
            isConsoleLogOpen = false
        }
    }

    ViewConsoleContainer {
        id: viewConsoleLog
        width: parent.width - 71
        implicitHeight: parent.height
        visible: viewStack.currentIndex === 2 &&  isConsoleLogOpen === true
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
        property var closeCVC

        onPopupClosed: {
            if (closeReason === confirmClosePopup.closeFilesReason) {
                controlViewCreator.openFilesModel.closeAll()
                closeCVC()
            } else if (closeReason === confirmClosePopup.acceptCloseReason) {
                controlViewCreator.openFilesModel.saveAll(true)
                closeCVC()
            }

            isConfirmCloseOpen = false
        }
    }

    SGConfirmationPopup {
        id: confirmCleanFiles
        modal: true
        padding: 0
        closePolicy: Popup.NoAutoClose

        acceptButtonColor: Theme.palette.green
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
                confirmBuildClean.open();
            } else {
                requestRecompile()
            }
        }
    }

    function requestRecompile() {
        recompileRequested = true
        controlViewLoader.setSource("")
        Help.resetDeviceIdTour(debugPlatform.deviceId)
        sdsModel.resourceLoader.recompileControlViewQrc(SGUtilsCpp.urlToLocalFile(editor.fileTreeModel.url))
    }

    function registerAndSetRecompiledRccFile (compiledRccFile) {
        let uniquePrefix = new Date().getTime().valueOf()
        uniquePrefix = "/" + uniquePrefix

        // Unregister previous (cached) resource
        if (controlViewCreatorRoot.previousCompiledRccFilePath !== "" && controlViewCreatorRoot.previousCompiledRccFileUniquePrefix !== "") {
            sdsModel.resourceLoader.unregisterResource(controlViewCreatorRoot.previousCompiledRccFilePath, controlViewCreatorRoot.previousCompiledRccFileUniquePrefix, controlViewLoader, false)
        }

        // Register new control view resource
        if (!sdsModel.resourceLoader.registerResource(compiledRccFile, uniquePrefix)) {
            console.error("Failed to register resource")
            return
        }

        controlViewCreatorRoot.previousCompiledRccFilePath = compiledRccFile
        controlViewCreatorRoot.previousCompiledRccFileUniquePrefix = uniquePrefix

        Help.setDeviceId(debugPlatform.deviceId)
        NavigationControl.context.class_id = debugPlatform.classId
        NavigationControl.context.device_id = debugPlatform.deviceId

        const qml_control = "qrc:" + uniquePrefix + "/Control.qml"
        controlViewLoader.setSource(qml_control, Object.assign({}, NavigationControl.context))
    }

    function blockWindowClose(callback) {
        let unsavedCount = editor.openFilesModel.getUnsavedCount();
        if (unsavedCount > 0 && !controlViewCreatorRoot.isConfirmCloseOpen) {
            confirmClosePopup.unsavedFileCount = unsavedCount;
            confirmClosePopup.open();
            confirmClosePopup.closeCVC = callback
            controlViewCreatorRoot.isConfirmCloseOpen = true;
            return true
        }
        return false
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
}
