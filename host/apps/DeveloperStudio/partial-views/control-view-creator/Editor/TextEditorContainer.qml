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

Item {
    id: fileContainerRoot
    Layout.fillHeight: true
    Layout.fillWidth: true

    property int modelIndex: index
    property string file: model.filename
    property int savedVersionId
    property int currentVersionId

    function openFile() {
        return SGUtilsCpp.readTextFileContent(SGUtilsCpp.urlToLocalFile(model.filepath));
    }

    function saveFile() {
        let success = SGUtilsCpp.atomicWrite(SGUtilsCpp.urlToLocalFile(model.filepath), channelObject.fileText);

        if (success) {
            savedVersionId = currentVersionId;
            model.unsavedChanges = false;
        } else {
            console.error("Unable to save file", model.filepath)
        }
    }

    Keys.onPressed: {
        if (event.matches(StandardKey.Save)) {
            saveFile()
        }
    }

    Connections {
        target: openFilesModel

        onSaveRequested: {
            if (index === fileContainerRoot.modelIndex) {
                saveFile();
            }
        }

        onSaveAllRequested: {
            if (model.unsavedChanges) {
                saveFile();
            }
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

        function setHtml(value) {
            setValue(value)
        }

        function setVersionId(version) {
            // If this is the first change, then we have just initialized the editor
            if (!savedVersionId) {
                savedVersionId = version
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

        anchors.fill: parent

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

