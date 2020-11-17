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

Item {
    id: fileContainerRoot
    Layout.fillHeight: true
    Layout.fillWidth: true

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

    function saveFile() {
        if (alertToast.visible) {
            alertToast.hide()
        }

        if (!model.unsavedChanges) {
            return
        }

        // If the file doesn't exist anymore, we need to notify the user with a confirmation dialog
        if (!model.exists) {
            controlViewCreatorRoot.isConfirmCloseOpen = true
            deletedFileSavedConfirmation.open()
            return
        }

        // If the file has been modified externally, notify the user with a confirmation dialog
        if (externalChanges) {
            controlViewCreatorRoot.isConfirmCloseOpen = true
            externalChangesConfirmation.open()
            return
        }

        const path = SGUtilsCpp.urlToLocalFile(model.filepath);
        treeModel.stopWatchingPath(path);
        const success = SGUtilsCpp.atomicWrite(path, channelObject.fileText);
        treeModel.startWatchingPath(path);

        if (success) {
            savedVersionId = currentVersionId;
            model.unsavedChanges = false;
        } else {
            alertToast.text = "Could not save file. Make sure the file has write permissions or try again."
            alertToast.show()
            console.error("Unable to save file", model.filepath)
        }
    }

    Keys.onPressed: {
        if (event.matches(StandardKey.Save)) {
            saveFile()
        }
    }

    Connections {
        target: treeModel

        onFileChanged: {
            if (model.filepath === path) {
                externalChanges = true
                if (!model.unsavedChanges) {
                    channelObject.fileText = openFile()
                    channelObject.setHtml(channelObject.fileText)
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
                saveFile();
            }
        }

        onSaveAllRequested: {
            if (model.unsavedChanges) {
                if (!model.exists) {
                    model.exists = true
                }
                saveFile();
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

        onPopupClosed: {
            controlViewCreatorRoot.isConfirmCloseOpen = false
            if (closeReason === acceptCloseReason) {
                externalChanges = false
                saveFile()
            } else if (closeReason === closeFilesReason) {
                channelObject.fileText = openFile()
                channelObject.setHtml(channelObject.fileText)
                externalChanges = false
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
        registeredObjects: [channelObject]
    }

    QtObject {
        id: channelObject
        objectName: "fileChannel"
        WebChannel.id: "valueLink"

        property string fileText: ""

        signal setValue(string value);
        signal setContainerHeight(string height);
        signal undo();
        signal redo();

        function setHtml(value) {
            setValue(value)
        }

        function setVersionId(version) {
            // If this is the first change, then we have just initialized the editor
            if (!savedVersionId) {
                savedVersionId = version
            }

            if (externalChanges) {
                savedVersionId = version
                externalChanges = false
            }

            currentVersionId = version
            model.unsavedChanges = (savedVersionId !== version)
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

        anchors {
            top: alertRow.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        onHeightChanged: {
            channelObject.setContainerHeight(height.toString())
        }

        onLoadingChanged: {
            if (loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus) {
                channelObject.setContainerHeight(height.toString())
                let fileText = openFile(model.filepath)
                channelObject.setHtml(fileText)
                channelObject.fileText = fileText
            }
        }

        url: "qrc:///partial-views/control-view-creator/editor.html"

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
}

