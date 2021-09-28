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
import QtQml.Models 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.fonts 1.0

import "../general"
import "components/"

Item {
    id: openProjectContainer

    property url url
    readonly property string configFileName: "previousProjects.json"
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
            editor.fileTreeModel.url = url
        }
    }

    function openProject(filepath, inRecentProjects) {
        const path = filepath.trim()

        if (projectFileMissing(path, inRecentProjects)) {
            return
        }
        if (unsavedFilesExist(path, inRecentProjects)) {
            return
        }

        openProjectContainer.url = path
        viewStack.currentIndex = 1 // switch to edit view
        controlViewCreatorRoot.projectInitialization = true

        if (controlViewCreatorRoot.projectName != "") {
            const projectName = controlViewCreatorRoot.projectName
        } else {
            controlViewCreatorRoot.getProjectNameFromCmake()
            const projectName = controlViewCreatorRoot.projectName
        }

        addToTheProjectList(projectName, path)
        controlViewCreatorRoot.recompileControlViewQrc()
        fileOutput.text = ""
    }

    function projectFileMissing(filepath, inRecentProjects) {
        let localFile
        if (SGUtilsCpp.isFile(filepath)) {
            localFile = filepath
        } else {
            localFile = SGUtilsCpp.urlToLocalFile(filepath)
        }

        if (!SGUtilsCpp.exists(localFile)) {
            console.warn("Tried to open non-existent QRC file/project")
            if (alertMessage.visible) {
                alertMessage.Layout.preferredHeight = 0
            }
            if (inRecentProjects) {
                alertMessage.text = "QRC file does not exist anymore. Removed from your recent projects."
                removeFromProjectList(filepath)
            } else {
                alertMessage.text = "Cannot open project. QRC file does not exist."
            }
            alertMessage.show()
            return true
        }

        return false
    }

    function unsavedFilesExist(path, inRecentProjects) {
        let unsavedFileCount = editor.openFilesModel.getUnsavedCount()
        if (unsavedFileCount > 0 && openProjectContainer.url.toString() !== path) {
            if (!controlViewCreatorRoot.isConfirmCloseOpen) {
                controlViewCreatorRoot.isConfirmCloseOpen = true
                startConfirmClosePopup.callback = function () {
                    openProject(path, inRecentProjects)
                }
                startConfirmClosePopup.unsavedFileCount = unsavedFileCount
                startConfirmClosePopup.open()
            }
            return true
        }
        return false
    }

    function saveSettings() {
        sgUserSettings.writeFile(configFileName, previousFileURL)
    }

    function loadSettings() {
        let config = sgUserSettings.readFile(configFileName)
        var projectsList  = JSON.parse(JSON.stringify(config))

        if (projectsList.projects) {
            for (var i = 0; i < projectsList.projects.length; ++i) {
                if (projectsList.projects[i].name && projectsList.projects[i].url) {
                    previousFileURL.projects.push({ name: projectsList.projects[i].name, url: projectsList.projects[i].url })
                    listModelForUrl.append({ name: previousFileURL.projects[i].name, url: previousFileURL.projects[i].url })
                } else {
                    previousFileURL.projects.push({ name: "", url: projectsList.projects[i] })
                    listModelForUrl.append({ name: "", url: projectsList.projects[i] })
                }
            }
        }
    }

    function addToTheProjectList(projectName, fileUrl) {
        for (var i = 0; i < previousFileURL.projects.length; ++i) {
            if (previousFileURL.projects[i].url === fileUrl) {
                listModelForUrl.remove(i)
                previousFileURL.projects.splice(i, 1)
                break
            }
        }

        if (previousFileURL.projects.length > 10) {
            previousFileURL.projects.pop()
            listModelForUrl.remove(listModelForUrl.count - 1)
        }

        previousFileURL.projects.unshift({ name: projectName, url: fileUrl })
        listModelForUrl.insert(0, { name: projectName, url: fileUrl })
        saveSettings()
    }

    function removeFromProjectList(fileUrl) {
        for (var i = 0; i < previousFileURL.projects.length; ++i) {
            if (previousFileURL.projects[i].url === fileUrl) {
                listModelForUrl.remove(i)
                previousFileURL.projects.splice(i, 1)
                saveSettings()
                return
            }
        }
    }

    // Grabs the most recent project from the fileUrl array
    // goes up two directories in order to be in the directory the project was created in
    // if there are no recent projects, the home folder is used
    function fileDialogFolder() {
        const project = previousFileURL.projects[0]
        if (project === undefined || project.url === undefined) {
            return fileDialog.shortcuts.home
        }

        let projectDir = project.url
        if (SGUtilsCpp.isValidFile(projectDir)) {
            projectDir = SGUtilsCpp.urlToLocalFile(projectDir)
            projectDir = SGUtilsCpp.parentDirectoryPath(projectDir)
            projectDir = SGUtilsCpp.parentDirectoryPath(projectDir)
            projectDir = SGUtilsCpp.pathToUrl(projectDir) // convert back to url for fileDialog.folder
            return projectDir
        }
        return fileDialog.shortcuts.home
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

        SGText {
            id: recentProjText
            color: "#666"
            fontSizeMultiplier: 1.25
            text: "Recent Projects:"
            visible: listModelForUrl.count > 0
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: implicitHeight
            implicitHeight: contentHeight
            orientation: ListView.Vertical
            spacing: 10
            clip: true

            model: ListModel {
                id: listModelForUrl
            }

            delegate:  Rectangle {
                id: projectUrlContainer
                implicitHeight: 40
                width: listView.width
                color: removeProjectMenu.opened ? "#aaa" : urlMouseArea.containsMouse ? "#eee" : "#ddd"

                RowLayout {
                    id: row
                    anchors {
                        fill: projectUrlContainer
                        margins: 5
                    }

                    SGIcon {
                        Layout.preferredHeight: projectUrlContainer.height * .5
                        Layout.preferredWidth: Layout.preferredHeight
                        source: "qrc:/sgimages/file-blank.svg"
                    }

                    SGText {
                        Layout.fillWidth: true
                        text: (model.name ? ("<b>" + model.name + "</b> - ") : "") + SGUtilsCpp.urlToLocalFile(model.url)
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
                            var item = itemAt(i)
                            result = Math.max(item.contentItem.implicitWidth, result)
                            padding = Math.max(item.padding, padding)
                        }
                        return result + padding * 2
                    }

                    MenuItem {
                        text: "Remove Project From Recent Projects"
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
                            openProject(model.url, true)
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

            SGControlViewButton {
                Layout.preferredHeight: 35
                Layout.preferredWidth: 150
                text: "Browse"

                onClicked: {
                    fileDialog.folder = fileDialogFolder()
                    fileDialog.open()
                }
            }

            Rectangle {
                Layout.preferredHeight: 35
                Layout.fillWidth: true
                color: "#eee"
                border.color: "#444"
                border.width: 1

                SGText {
                    id: fileOutput
                    color: "#333"
                    anchors {
                        margins: 8
                        fill: parent
                    }
                    elide: Text.ElideLeft
                    verticalAlignment: Text.AlignVCenter
                }

                SGText {
                    visible: fileOutput.text === ""
                    text: "Select a .qrc file..."
                    color: "#aaa"
                    anchors {
                        margins: 8
                        fill: parent
                    }
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 35

            SGControlViewButton {
                id: openbutton
                anchors {
                    fill: parent
                }
                text: "Open Project"
                enabled: fileOutput.text !== ""

                onClicked: {
                    openProject(fileOutput.text, false)
                }
            }

            MouseArea {
                id: createButtonToolTipShow
                anchors.fill: parent
                hoverEnabled: visible
                enabled: visible
                visible: !openbutton.enabled

                ToolTip {
                    text: "Please browse for a QRC project file to open"
                    visible: createButtonToolTipShow.containsMouse
                }
            }
        }

        Item {
            // space filler
            Layout.fillHeight: true
        }
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
}
