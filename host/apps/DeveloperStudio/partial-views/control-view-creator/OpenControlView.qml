import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.fonts 1.0

import "../general"
import "components/"

Rectangle {
    id: openProjectContainer
    color: "#ccc"

    property url url
    property string configFileName: "previousProjects.json"
    property var previousFileURL: { "projects" : [] }
    property alias projectContainer: openProjectContainer

    Component.onCompleted:  {
        loadSettings()
    }

    onVisibleChanged: {
        if (!openProjectContainer.visible) {
            alertMessage.Layout.preferredHeight = 0
        }
    }

    onUrlChanged: {
        if (url.toString() !== "") {
            editor.treeModel.url = url
        }
    }

    function openProject(filepath, addToProjectList) {
        let path = filepath.trim();

        if (path.startsWith("file:///")) {
            // type is url
            path = SGUtilsCpp.urlToLocalFile(path);
        }

        if (!SGUtilsCpp.exists(path)) {
            console.warn("Tried to open non-existent project")
            if (alertMessage.visible) {
                alertMessage.Layout.preferredHeight = 0
            }
            alertMessage.text = "Cannot open project. Qrc file does not exist."
            alertMessage.show()
            return false;
        }

        openProjectContainer.url = SGUtilsCpp.pathToUrl(path)
        console.info(openProjectContainer.url);
        toolBarListView.currentIndex = toolBarListView.editTab
        if (addToProjectList) {
            addToTheProjectList(openProjectContainer.url.toString())
        }
        controlViewCreatorRoot.rccInitialized = false
        return true;
    }

    function saveSettings() {
        sgUserSettings.writeFile(configFileName, previousFileURL);
    }

    function loadSettings() {
        let config = sgUserSettings.readFile(configFileName)
        var projectsList  = JSON.parse(JSON.stringify(config))
        if(projectsList.projects) {
            for (var i = 0; i < projectsList.projects.length; ++i) {
                previousFileURL.projects.push(projectsList.projects[i])
                listModelForUrl.append({ url: previousFileURL.projects[i] })
            }
        }
    }

    function addToTheProjectList (fileUrl) {
        for (var i = 0; i < previousFileURL.projects.length; ++i) {
            if (previousFileURL.projects[i] === fileUrl) {
                return
            }
        }

        if (previousFileURL.projects.length > 5) {
            previousFileURL.projects.pop()
            listModelForUrl.remove(listModelForUrl.count - 1)
        }
        previousFileURL.projects.unshift(fileUrl)
        listModelForUrl.insert(0,{ url: fileUrl })
        saveSettings()
    }

    function removeFromProjectList(fileUrl) {
        for (var i = 0; i < previousFileURL.projects.length; ++i) {
            if (previousFileURL.projects[i] === fileUrl) {
                listModelForUrl.remove(i)
                previousFileURL.projects.splice(i,1)
                saveSettings()
                return
            }
        }
    }

    ConfirmClosePopup {
        id: confirmClosePopup
        parent: controlViewCreatorRoot

        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        titleText: "You have unsaved changes in " + unsavedFileCount + " files."
        popupText: "Your changes will be lost if you choose to not save them."
        acceptButtonText: "Save all"

        property int unsavedFileCount
        property url newUrl
        property bool addToProjectList: false

        onPopupClosed: {
            if (closeReason === confirmClosePopup.closeFilesReason) {
                editor.openFilesModel.closeAll()
            } else if (closeReason === confirmClosePopup.acceptCloseReason) {
                editor.openFilesModel.saveAll()
            }
            controlViewCreatorRoot.isConfirmCloseOpen = false
            if (closeReason !== confirmClosePopup.cancelCloseReason) {
                if (openProject(addToProjectList ? fileOutput.text : newUrl.toString(), addToProjectList)) {
                    fileOutput.text = "Select a .QRC file..."
                }
            }
        }
    }

    ColumnLayout {
        id: recentProjColumn
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 20

        SGNotificationToast {
            id: alertMessage
            Layout.preferredWidth: parent.width/1.5
            color: "red"
        }

        FileDialog {
            id: fileDialog
            nameFilters: ["*.qrc"]
            folder: fileDialog.shortcuts.home
            onAccepted: {
                if (fileDialog.fileUrl.toString() !== "") {
                    fileOutput.text = fileDialog.fileUrl
                }
            }
        }

        SGText {
            id: recentProjText
            color: "#666"
            fontSizeMultiplier: 1.25
            text: "Recent Projects:"
            visible: (listModelForUrl.count > 0) ? true : false
        }

        ListView {
            id: listView
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height
            Layout.fillHeight: true
            Layout.maximumHeight: implicitHeight
            orientation: ListView.Vertical
            highlightFollowsCurrentItem: true
            spacing: 10
            clip: true

            model: ListModel {
                id: listModelForUrl
            }

            delegate:  Rectangle {
                id: projectUrlContainer
                height: 40
                width: recentProjColumn.width
                color: removeProjectMenu.opened  ? "#aaa" : urlMouseArea.containsMouse ? "#eee" : "#ddd"

                RowLayout {
                    id: row
                    anchors {
                        fill: projectUrlContainer
                        margins: 5
                    }

                    SGIcon {
                        Layout.preferredHeight: projectUrlContainer.height*.5
                        Layout.preferredWidth: Layout.preferredHeight
                        source: "qrc:/sgimages/file-blank.svg"
                    }

                    SGText {
                        Layout.fillWidth: true
                        text: model.url
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap
                        font.underline: urlMouseArea.containsMouse
                        maximumLineCount: 1
                        color: urlMouseArea.containsPress ? "#555" : "black"
                    }
                }

                Menu {
                    id: removeProjectMenu
                    width: {
                        var result = 0;
                        var padding = 0;
                        for (var i = 0; i < count; ++i) {
                            var item = itemAt(i);
                            result = Math.max(item.contentItem.implicitWidth, result);
                            padding = Math.max(item.padding, padding);
                        }
                        return result + padding * 2;
                    }

                    MenuItem {
                        text: "Remove Projects From Recent Project"
                        onTriggered: {
                            removeFromProjectList(model.url)
                        }
                    }

                    MenuItem {
                        text: "Clear Recent Project List"
                        onTriggered: {
                            previousFileURL.projects = []
                            listModelForUrl.clear()
                            saveSettings()
                        }
                    }
                }

                MouseArea {
                    id: urlMouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        if (mouse.button === Qt.RightButton) {
                            removeProjectMenu.popup()
                        } else {
                            if (!SGUtilsCpp.exists(SGUtilsCpp.urlToLocalFile(model.url))) {
                                alertMessage.text = "This project does not exist anymore. Removing it from your recent projects..."
                                alertMessage.show()
                                removeFromProjectList(model.url)
                            } else {
                                let unsavedFileCount = editor.openFilesModel.getUnsavedCount()
                                if (unsavedFileCount > 0 && openProjectContainer.url.toString() !== model.url) {
                                    if (!controlViewCreatorRoot.isConfirmCloseOpen) {
                                        confirmClosePopup.unsavedFileCount = unsavedFileCount
                                        confirmClosePopup.newUrl = model.url
                                        confirmClosePopup.addToProjectList = false
                                        confirmClosePopup.open()
                                        controlViewCreatorRoot.isConfirmCloseOpen = true
                                    }
                                } else {
                                    openProjectContainer.url = model.url
                                    toolBarListView.currentIndex = toolBarListView.editTab
                                    controlViewCreatorRoot.rccInitialized = false
                                }
                            }
                        }
                    }
                }
            }
        }

        SGText {
            Layout.alignment: Qt.AlignLeft
            text: "Select control view project .QRC file: "
            color: "#666"
            fontSizeMultiplier: 1.25
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            SGControlViewButton {
                Layout.preferredHeight: 35
                Layout.preferredWidth: 150
                text: "Browse"

                function onClicked() {
                    fileDialog.open()
                }
            }

            Rectangle {
                Layout.preferredHeight: 35
                Layout.fillWidth: true
                color: "#eee"
                border.color: "#444"
                border.width: 0.5

                TextInput {
                    id: fileOutput

                    anchors.fill: parent
                    text: "Select a .qrc file..."
                    color: "#333"
                    verticalAlignment: Text.AlignVCenter
                    selectByMouse: true
                    leftPadding: 10
                }
            }
        }

        SGControlViewButton {
            id: openbutton
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            text: "Open Project"

            function onClicked() {
                if (fileOutput.text !== "" && fileOutput.text !== "Select a .qrc file...") {
                    let unsavedFileCount = editor.openFilesModel.getUnsavedCount()

                    if (unsavedFileCount > 0 && openProjectContainer.url !== fileDialog.fileUrl) {
                        if (!controlViewCreatorRoot.isConfirmCloseOpen) {
                            confirmClosePopup.unsavedFileCount = unsavedFileCount
                            confirmClosePopup.addToProjectList = true
                            confirmClosePopup.open()
                            controlViewCreatorRoot.isConfirmCloseOpen = true
                        }
                    } else {
                        if (openProject(fileOutput.text,true)) {
                            fileOutput.text = "Select a .qrc file..."
                        }
                    }
                }
            }
        }

        Item {
            // space filler
            Layout.fillHeight: true
        }
    }
}
