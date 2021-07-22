import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.3
import QtWebEngine 1.8
import QtWebChannel 1.0

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.commoncpp 1.0

import "../../general"
import "../"
import "qrc:/js/navigation_control.js" as NavigationControl

Item {
    id: fileContainerRoot
    Layout.fillHeight: true
    Layout.fillWidth: true

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus()
        }
    }

    property int modelIndex: index
    property string file: model.filename
    property int savedVersionId
    property int currentVersionId
    property bool externalChanges: false

    function openFile() {
        let fileText = SGUtilsCpp.readTextFileContent(SGUtilsCpp.urlToLocalFile(model.filepath))

        // Before returning the fileText, replace tabs with 4 spaces
        return fileText.replace(/\t/g, '    ')
    }

    function saveFile(closeFile = false, forceOverwrite = false) {
        if (alertToast.visible) {
            alertToast.hide()
        }

        if (!forceOverwrite) {
            // If the file doesn't exist anymore, we need to notify the user with a confirmation dialog
            if (!model.exists) {
                controlViewCreatorRoot.isConfirmCloseOpen = true
                deletedFileSavedConfirmation.open()
                return
            }

            // If the file has been modified externally, notify the user with a confirmation dialog
            if (externalChanges) {
                controlViewCreatorRoot.isConfirmCloseOpen = true
                externalChangesConfirmation.closeOnSave = closeFile
                externalChangesConfirmation.open()
                return
            }
        }

        if (!model.unsavedChanges) {
            return
        }

        let path
        if (SGUtilsCpp.isFile(model.filepath)) {
            path = model.filepath
        } else {
            path = SGUtilsCpp.urlToLocalFile(model.filepath)
        }

        if (!SGUtilsCpp.isValidFile(path)) {
            console.error("File path is not valid: ", path)
            return
        }

        treeModel.stopWatchingPath(path)
        const success = SGUtilsCpp.atomicWrite(path, channelObject.fileText)
        treeModel.startWatchingPath(path)

        if (success) {
            savedVersionId = currentVersionId
            model.unsavedChanges = false
            externalChanges = false
            if (closeFile) {
                openFilesModel.closeTabAt(modelIndex)
            }
        } else {
            alertToast.text = "Could not save file. Make sure the file has write permissions or try again."
            alertToast.show()
            console.error("Unable to save file", model.filepath)
        }
    }

    Keys.onReleased: {
        if (event.matches(StandardKey.Close)) {
            closeFileTab(index, model)
        }
    }

    Keys.onPressed: {
        if (event.matches(StandardKey.Save)) {
            saveFile()
        }
    }

    Connections {
        target: treeModel

        onFileAdded: {
            // Here we handle the situation where a file that was previously deleted is now recreated.
            // We want to check to see if the files have different contents
            if (model.filepath === path) {
                let newFileText = SGUtilsCpp.readTextFileContent(SGUtilsCpp.urlToLocalFile(model.filepath))
                if (newFileText !== channelObject.fileText) {
                    externalChanges = true
                    if (!model.unsavedChanges) {
                        channelObject.refreshEditorWithExternalChanges()
                    }
                }
            }
        }

        onFileChanged: {
            if (model.filepath === path) {
                externalChanges = true
                if (!model.unsavedChanges) {
                    channelObject.refreshEditorWithExternalChanges()
                }
            }
        }
    }

    Connections {
        target: editor.editorToolBar

        onSaveClicked: {
            if (modelIndex === openFilesModel.currentIndex) {
                saveFile()
            }
        }

        onUndoClicked: {
            if (modelIndex === openFilesModel.currentIndex) {
                channelObject.undo()
            }
        }

        onRedoClicked: {
            if (modelIndex === openFilesModel.currentIndex) {
                channelObject.redo()
            }
        }
    }

    Connections {
        target: openFilesModel

        onSaveRequested: {
            if (index === fileContainerRoot.modelIndex) {
                if (!model.exists) {
                    model.exists = true
                }
                saveFile(close)
            }
        }

        onSaveAllRequested: {
            if (model.unsavedChanges) {
                if (!model.exists) {
                    model.exists = true
                }
                saveFile(close, true)
            }
        }
    }

    ConfirmClosePopup {
        id: deletedFileSavedConfirmation
        titleText: "File no longer exists"
        popupText: "This file has been deleted from disk. Are you sure you want to save this file?"

        onPopupClosed: {
            if (closeReason === acceptCloseReason) {
                model.exists = true
                saveFile()
            } else if (closeReason === closeFilesReason) {
                openFilesModel.closeTabAt(modelIndex)
            }

            controlViewCreatorRoot.isConfirmCloseOpen = false
        }
    }

    ConfirmClosePopup {
        id: externalChangesConfirmation
        titleText: "Newer version of this file is available!"
        popupText: "This file has been modified externally. Would you like to overwrite the external changes or abandon your changes?"

        acceptButtonText: "Overwrite"
        closeButtonText: "Abandon my changes"

        property bool closeOnSave

        onPopupClosed: {
            controlViewCreatorRoot.isConfirmCloseOpen = false
            if (closeReason === acceptCloseReason) {
                // User chose to overwrite the external changes
                externalChanges = false
                model.unsavedChanges = true
                saveFile(closeOnSave)
            } else if (closeReason === closeFilesReason) {
                // User chose to abandon their changes
                channelObject.refreshEditorWithExternalChanges()
                if (closeOnSave) {
                    openFilesModel.closeTabAt(modelIndex)
                }
            }

        }
    }

    RowLayout {
        id: alertRow
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.7
        SGNotificationToast {
            id: alertToast
            Layout.fillWidth: true
            interval: 0
            z: 100
            color: "red"
        }
    }

    WebChannel {
        id: channel
        Component.onCompleted: registerObjects({valueLink: channelObject})
    }

    QtObject {
        id: channelObject
        objectName: "fileChannel"
        WebChannel.id: "valueLink"

        property string fileText: ""
        property bool reset: false

        signal setValue(string value)
        signal setContainerHeight(string height)
        signal setContainerWidth(string width)
        signal resetContainer(string height, string width)
        signal undo()
        signal redo()

        function setFinished(isFinished) {
            indicator.playing = !isFinished
        }

        function setHtml(value) {
            setValue(value)
        }

        function refreshEditorWithExternalChanges() {
            reset = true
            fileText = openFile()
            setHtml(channelObject.fileText)
            externalChanges = false
        }

        function setVersionId(version) {
            // If this is the first change, then we have just initialized the editor
            if (!savedVersionId || reset) {
                savedVersionId = version

                if (reset) {
                    reset = false
                }
            }

            currentVersionId = version
            model.unsavedChanges = (savedVersionId !== version)
        }
    }

    WebEngineView {
        id: webEngine
        webChannel: channel
        url: "qrc:///tech/strata/monaco/minified/editor.html"

        settings.localContentCanAccessRemoteUrls: false
        settings.localContentCanAccessFileUrls: true
        settings.localStorageEnabled: true

        settings.errorPageEnabled: false
        settings.javascriptCanOpenWindows: false
        settings.javascriptEnabled: true
        settings.javascriptCanAccessClipboard: true
        settings.pluginsEnabled: true
        settings.showScrollBars: false

        anchors {
            top: alertRow.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        onJavaScriptConsoleMessage: {
            switch (level) {
                case WebEngineView.InfoMessageLevel:
                    console.log(message)
                    break
                case WebEngineView.WarningMessageLevel:
                    console.warn(`In ${sourceID} on ${lineNumber}: ${message}`)
                    break
                case WebEngineView.ErrorMessageLevel:
                    console.error(`In ${sourceID} on ${lineNumber}: ${message}`)
                    break
            }
        }

        onHeightChanged: {
            var htmlHeight = height - 16
            channelObject.setContainerHeight(htmlHeight.toString())
        }

        onWidthChanged: {
            var htmlWidth = width - 16
            channelObject.setContainerWidth(htmlWidth.toString())
        }

        // This handles the edge case of height and width not being reset after minimizing and/or maximizing the window,
        // the visibilty changed is called when the window is resized from signals outside of the app
        Connections {
            target: mainWindow

            onVisibilityChanged: {
                var htmlHeight = webEngine.height - 16
                var htmlWidth = webEngine.width - 16
                channelObject.resetContainer(htmlHeight.toString(), htmlWidth.toString())
            }
        }

        onLoadingChanged: {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                channelObject.setContainerHeight((webEngine.height - 16).toString())
                let fileText = openFile(model.filepath)
                channelObject.setHtml(fileText)
                channelObject.fileText = fileText
            } else if (loadRequest.status === WebEngineLoadRequest.LoadFailedStatus) {
                let errorProperties = {
                    "error_message": "Monaco text editor component failed to load or was not found"
                }

                fileLoader.setSource(NavigationControl.screens.LOAD_ERROR, errorProperties)
            }
        }

        Rectangle {
            id: barContainer
            color: "white"
            anchors {
                fill: webEngine
            }
            z: 1000
            visible: indicator.playing

            ProgressBar {
                id: progressBar
                height: 0
                width: 0
                from: 0
                to: 100
                value: webEngine.loadProgress
            }

            AnimatedImage {
                id: indicator
                anchors {
                    centerIn: barContainer
                    verticalCenterOffset: 10
                }
                source: "qrc:/images/loading.gif"

                Text {
                    text: qsTr(`Loading: ${webEngine.loadProgress}%`)
                    anchors {
                        bottom: indicator.top
                        bottomMargin: 10
                        horizontalCenter: indicator.horizontalCenter
                    }
                }
            }
        }
    }
}
