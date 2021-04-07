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

ColumnLayout {
    id: fileContainerRoot
    spacing: 0

    property int modelIndex: index
    property string file: model.filename
    property int savedVersionId
    property int currentVersionId
    property bool externalChanges: false

    function openFile() {
        let fileText = SGUtilsCpp.readTextFileContent(SGUtilsCpp.urlToLocalFile(model.filepath));

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

        const path = SGUtilsCpp.urlToLocalFile(model.filepath);
        treeModel.stopWatchingPath(path);
        const success = SGUtilsCpp.atomicWrite(path, channelObject.fileText);
        treeModel.startWatchingPath(path);

        if (success) {
            savedVersionId = currentVersionId;
            model.unsavedChanges = false;
            externalChanges = false;
            if (closeFile) {
                openFilesModel.closeTabAt(modelIndex)
            }
        } else {
            alertToast.text = "Could not save file. Make sure the file has write permissions or try again."
            alertToast.show()
            console.error("Unable to save file", model.filepath)
        }
    }

    Connections {
        target: treeModel

        onFileAdded: {
            // Here we handle the situation where a file that was previously deleted is now recreated.
            // We want to check to see if the files have different contents
            if (model.filepath === path) {
                let newFileText = SGUtilsCpp.readTextFileContent(SGUtilsCpp.urlToLocalFile(model.filepath));
                if (newFileText !== channelObject.fileText) {
                    externalChanges = true;
                    if (!model.unsavedChanges) {
                        channelObject.refreshEditorWithExternalChanges();
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
                saveFile(close);
            }
        }

        onSaveAllRequested: {
            if (model.unsavedChanges) {
                if (!model.exists) {
                    model.exists = true
                }
                saveFile(close, true);
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
                saveFile(closeOnSave);
            } else if (closeReason === closeFilesReason) {
                // User chose to abandon their changes
                channelObject.refreshEditorWithExternalChanges()
                if (closeOnSave) {
                    openFilesModel.closeTabAt(modelIndex)
                }
            }
        }
    }

    SGNotificationToast {
        id: alertToast
        Layout.fillWidth: true
        interval: 0
        z: 100
        color: "red"
    }

    RowLayout {

        SGComboBox {
            id: viewSelector
            model: ["Text Editor", "Visual Editor"]
            currentIndex: 0
            Layout.leftMargin: 5
            Layout.topMargin: 5
            Layout.bottomMargin: 5

            onCurrentIndexChanged:  {
                if (currentIndex === 1) {
                    visualEditor.functions.reload()
                }
            }
        }

        Loader {
            id: menuLoader
            source: {
                switch (viewSelector.currentIndex) {
                    case 0:
                        return ""
                    case 1:
                        active = true
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/VisualEditorMenu.qml"
                }
            }
        }
    }

    Rectangle {
        // divider
        Layout.fillWidth: true
        implicitHeight: 1
        color: "gray"
    }

    StackLayout {
        id: viewStack
        Layout.fillHeight: true
        Layout.fillWidth: true
        currentIndex: viewSelector.currentIndex

        Keys.onPressed: {
            if (event.matches(StandardKey.Save)) {
                saveFile()
            }
        }

        WebEngineView {
            id: webEngine
            webChannel: channel
            settings.localContentCanAccessRemoteUrls: false
            settings.localContentCanAccessFileUrls: true
            settings.localStorageEnabled: true

            settings.errorPageEnabled: false
            settings.javascriptCanOpenWindows: false
            settings.javascriptEnabled: true
            settings.javascriptCanAccessClipboard: true
            settings.pluginsEnabled: true
            settings.showScrollBars: false

            onHeightChanged: {
                channelObject.setContainerHeight(height.toString())
            }

            onWidthChanged: {
                channelObject.setContainerWidth(width.toString())
            }

            // This handles the edge case of height and width not being reset after minimizing and/or maximizing the window, 
            // the visibilty changed is called when the window is resized from signals outside of the app
            Connections {
                target: mainWindow

                onVisibilityChanged: {
                    channelObject.resetContainer(webEngine.height.toString(), webEngine.width.toString())
                }
            }

            onLoadingChanged: {
                if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                    channelObject.setContainerHeight(height.toString())
                    let fileText = openFile(model.filepath)
                    channelObject.setHtml(fileText)
                    channelObject.fileText = fileText
                }
            }

            url: "qrc:///tech/strata/monaco/minified/editor.html"

            Rectangle {
                id: barContainer
                color: "white"
                anchors {
                    fill: webEngine
                }
                visible: progressBar.value !== 100

                ProgressBar {
                    id: progressBar
                    anchors {
                        centerIn: barContainer
                        verticalCenterOffset: 10
                    }
                    height: 10
                    width: webEngine.width/2
                    from: 0
                    to: 100
                    value: webEngine.loadProgress

                    Text {
                        text: qsTr("Loading...")
                        anchors {
                            bottom: progressBar.top
                            bottomMargin: 10
                            horizontalCenter: progressBar.horizontalCenter
                        }
                    }
                }
            }
        }

        VisualEditor {
            id: visualEditor
            file: model.filepath
        }
    }

    WebChannel {
        id: channel
        registeredObjects: [channelObject]
    }

    QtObject {
        id: channelObject
        objectName: "fileChannel"
        WebChannel.id: "valueLink"

        property string fileText: ""
        property bool reset: false

        signal setValue(string value);
        signal setContainerHeight(string height);
        signal setContainerWidth(string width);
        signal undo();
        signal redo();
        signal goToUUID(string uuid)

        function setHtml(value) {
            setValue(value)
        }

         function checkForErrors(flag,log) {
            if(flag){
               console.error(log)
            }
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

                if (reset)
                    reset = false
            }

            currentVersionId = version
            model.unsavedChanges = (savedVersionId !== version)
        }
    }

    Connections {
        target: visualEditor.functions

        onPassUUID: {
            viewSelector.currentIndex = 0
            channelObject.goToUUID(uuid)
        }
    }
}
