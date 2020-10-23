import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.fonts 1.0

import "../general"

import "../"

Rectangle {
    id: openProjectContainer

    property alias fileUrl: filePath.text
    property url url
    property string configFileName: "previousProjects.json"
    property var previousFileURL: { "projects" : [] }
    color: "#ccc"

    onVisibleChanged: {
        if(!openProjectContainer.visible) {
            alertMessage.Layout.preferredHeight = 0
        }
    }

    Component.onCompleted:  {
        loadSettings()
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
            if(previousFileURL.projects[i] === fileUrl) {
                return
            }
        }
        if(previousFileURL.projects.length > 5) {
            previousFileURL.projects.pop()
            listModelForUrl.remove(listModelForUrl.count - 1)
        }
        previousFileURL.projects.unshift(fileUrl)
        listModelForUrl.insert(0,{ url: fileUrl })
        saveSettings()
    }

    function removeFromProjectList(fileUrl) {
        for (var i = 0; i < previousFileURL.projects.length; ++i) {
            if(previousFileURL.projects[i] === fileUrl) {
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
                if (openProject(addToProjectList ? filePath.text : newUrl.toString(), addToProjectList)) {
                    filePath.text = "Select a .QRC file..."
                }
            }
        }
    }

    ColumnLayout {
        id:recentProjColumn
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 10

        SGText {
            color: "#666"
            fontSizeMultiplier: 2
            text: "Open Control View Project"
        }

        Rectangle {
            // divider line
            color: "#333"
            Layout.preferredHeight: 1
            Layout.fillWidth: true
        }

        SGNotificationToast {
            id: alertMessage
            Layout.preferredWidth: parent.width * 0.7
            interval: 0
            z: 100
            color: "red"
        }

        SGText {
            id: recentProjText
            color: "#666"
            fontSizeMultiplier: 1.25
            text: "Recent Projects:"
            visible: (listModelForUrl.count > 0) ? true : false
        }

        ListView {
            implicitWidth: contentItem.childrenRect.width
            implicitHeight: contentItem.childrenRect.height
            orientation: ListView.Vertical
            model:ListModel{
                id: listModelForUrl
            }
            highlightFollowsCurrentItem: true
            spacing: 10
            delegate:  Rectangle {
                id: projectUrlContainer
                width: openProjectContainer.width - 40
                height: 40
                color: removeProjectMenu.opened  ? "lightgray" : "white"

                RowLayout {
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
                        Layout.fillWidth:true
                        text: model.url.toString()
                        elide:Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.Wrap
                        maximumLineCount: 1
                        color:  urlMouseArea.containsMouse ?  "#bbb" : "black"
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
                            removeFromProjectList(model.url.toString())
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
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: {
                        if(mouse.button === Qt.RightButton) {
                            removeProjectMenu.popup()
                        }
                        else  {
                            if(!SGUtilsCpp.exists(SGUtilsCpp.urlToLocalFile(model.url))) {
                                if (alertMessage.visible) {
                                    alertMessage.Layout.preferredHeight = 0
                                }

                                alertMessage.text = "This project does not exist anymore. Removing it from your recent projects..."
                                alertMessage.show()
                                removeFromProjectList(model.url.toString())
                            }
                            else {
                                let unsavedFileCount = editor.openFilesModel.getUnsavedCount()
                                if (unsavedFileCount > 0
                                        && openProjectContainer.url.toString() !== model.url) {
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
                                }
                            }
                        }
                        
                    }
                }
            }
        }

        SGAlignedLabel {
            Layout.topMargin: 20
            color: "#666"
            fontSizeMultiplier: 1.25
            text: "Select control view project .QRC file:"
            target: directoryInput

            RowLayout {
                id: directoryInput

                SGButton {
                    text: "Select"
                    onClicked: {
                        fileDialog.open()
                    }
                }

                FileDialog {
                    id: fileDialog
                    nameFilters: ["*.qrc"]
                    selectMultiple: false
                    selectFolder: false
                    onAccepted: {
                        filePath.text = fileDialog.fileUrl
                    }
                }

                Rectangle {
                    id: filePathContainer
                    Layout.preferredWidth: 600
                    Layout.preferredHeight: 40
                    color: "#eee"
                    border.color: "#333"
                    border.width: 1
                    clip: true

                    TextInput {
                        id: filePath

                        anchors {
                            leftMargin: 10
                            rightMargin: 5
                            fill: parent
                            verticalCenter: parent.verticalCenter
                        }
                        height: parent.height
                        text: "Select a .QRC file..."
                        color: "#333"
                        verticalAlignment: Text.AlignVCenter
                        selectByMouse: true
                    }
                }
            }
        }

        RowLayout {
            Layout.topMargin: 20
            Layout.fillWidth: false
            spacing: 20

            SGButton {
                text: "Open Project"

                onClicked: {
                    if (filePath.text !== "" && filePath.text !== "Select a .QRC file...") {
                        let unsavedFileCount = editor.openFilesModel.getUnsavedCount()
                        if (unsavedFileCount > 0
                                && openProjectContainer.url !== fileDialog.fileUrl) {
                            if (!controlViewCreatorRoot.isConfirmCloseOpen) {
                                confirmClosePopup.unsavedFileCount = unsavedFileCount
                                confirmClosePopup.addToProjectList = true
                                confirmClosePopup.open()
                                controlViewCreatorRoot.isConfirmCloseOpen = true
                            }
                        } else {
                            if (openProject(filePath.text, true)) {
                                filePath.text = "Select a .QRC file..."
                            }
                        }
                    }
                }
            }

            SGButton {
                text: "Cancel"

                onClicked: {
                    toolBarListView.currentIndex = -1
                }
            }
        }

        Item {
            // space filler
            Layout.fillHeight: true
        }
    }
}
