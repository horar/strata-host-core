/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

import "utils/template_selection.js" as TemplateSelection
import "components/"

import "../general"
import "../"

Item {
    id: createNewContainer

    property alias templateButtonGroup: templateButtonGroup
    property var openProjectContainer: openControlView.projectContainer

    onVisibleChanged: {
        if (!visible) {
            alertMessage.hideInstantly()
        } else {
            if (fileOutput.text === "") {
                fileOutput.text = openProjectContainer.fileDialogFolder()
            }
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 10

        SGNotificationToast {
            id: alertMessage
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width * 0.7
            interval: 0
            color: Theme.palette.error
        }

        SGText {
            Layout.alignment: Qt.AlignLeft
            text: "Enter a project name:"
            color: "#666"
            fontSizeMultiplier: 1.25
        }

        Rectangle {
            Layout.preferredHeight: 35
            Layout.fillWidth: true
            color: "#eee"
            border.color: "#444"
            border.width: 0.5

            SGTextInput {
                id: projectName

                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 10
                }
                color: "#333"
                verticalAlignment: Text.AlignVCenter
                selectByMouse: true
                selectionColor: Theme.palette.onsemiOrange
                contextMenuEnabled: true
                clip: true
            }
        }

        SGText {
            Layout.alignment: Qt.AlignLeft
            text: "Select directory to create project in:"
            color: "#666"
            fontSizeMultiplier: 1.25
        }

        RowLayout {

            SGControlViewButton {
                Layout.preferredHeight: 35
                Layout.preferredWidth: 150
                text: "Browse"

                onClicked: {
                    fileDialog.folder = openProjectContainer.fileDialogFolder()
                    fileDialog.open()
                }
            }

            Rectangle {
                Layout.preferredHeight: 35
                Layout.fillWidth: true
                color: "#eee"
                border.color: "#444"
                border.width: 0.5

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
            }
        }

        SGText {
            Layout.alignment: Qt.AlignLeft
            Layout.topMargin: 10
            text: "Select a project template:"
            color: "#666"
            fontSizeMultiplier: 1.25
        }

        ScrollView {
            id: scrollView
            Layout.maximumHeight: 400
            Layout.minimumHeight: 150
            Layout.fillWidth: true
            clip: true

            ScrollBar.vertical.policy: scrollView.height < templateLayout.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            ScrollBar.vertical.background: Rectangle {
                color: "#333"
                radius: 5
            }

            GridLayout {
                id: templateLayout
                rowSpacing: 5
                columnSpacing: 5
                anchors.fill: parent
                clip: true
                columns: 9
                anchors.horizontalCenter: parent.horizontalCenter

                ButtonGroup {
                    id: templateButtonGroup
                    exclusive: true
                }

                Repeater {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: ListModel {
                        id: templateModel

                        Component.onCompleted: {
                            TemplateSelection.createDataModel(templateModel)
                        }
                    }

                    delegate: AbstractButton {
                        id: templateButton
                        Layout.preferredWidth: delegateContent.width
                        Layout.preferredHeight: delegateContent.height
                        ButtonGroup.group: templateButtonGroup
                        checkable: true

                        property string path: model.path

                        Component.onCompleted: {
                            if (index === 0) {
                                checked = true
                            }
                        }

                        Rectangle {
                            id: delegateContent
                            width: delegateColumn.implicitWidth + 20
                            height: delegateColumn.implicitHeight + 20
                            color: templateButton.checked ? "#eee" : "transparent"
                            radius: 10

                            MouseArea {
                                anchors {
                                    fill: parent
                                }
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPressed: {
                                    TemplateSelection.setPath(templateButton.path)
                                    mouse.accepted = false
                                }
                            }

                            ColumnLayout {
                                id: delegateColumn
                                anchors {
                                    centerIn: parent
                                }

                                Image {
                                    id: templateImage
                                    Layout.preferredWidth: 150
                                    Layout.preferredHeight: 100
                                    source: model.image
                                }

                                SGText {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.maximumWidth: templateImage.width
                                    wrapMode: Text.Wrap
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    text: model.name
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: buttonContainer
            Layout.fillWidth: true
            Layout.preferredHeight: 35

            SGControlViewButton {
                id: createButton
                anchors.fill: parent
                text: "Create Project"
                enabled: projectName.text !== "" && projectNameValid && fileOutput.text !== "" && fileOutput.text !== fileOutput.defaultText

                property bool projectNameValid: projectName.text.match(/^[a-zA-Z0-9_\.\+\-]*$/)

                onClicked: {
                    if (enabled) {
                        let unsavedFileCount = editor.openFilesModel.getUnsavedCount()
                        if (unsavedFileCount > 0) {
                            if (!controlViewCreatorRoot.isConfirmCloseOpen) {
                                controlViewCreatorRoot.isConfirmCloseOpen = true
                                startConfirmClosePopup.callback = function () {
                                    createControlView()
                                }
                                startConfirmClosePopup.unsavedFileCount = unsavedFileCount
                                startConfirmClosePopup.open()
                            }
                        } else {
                            createControlView()
                        }
                    }
                }
            }

            MouseArea {
                id: createButtonToolTipShow
                anchors.fill: parent
                hoverEnabled: true
                enabled: visible
                visible: !createButton.enabled

                ToolTip {
                    text: {
                        var result = ""
                        if (projectName.text == "") {
                            result += (result === "" ? "" : "<br>")
                            result += "Project name is empty"
                        } else if (!createButton.projectNameValid) {
                            result += (result === "" ? "" : "<br>")
                            result += "Project name is not valid"
                        }
                        if (fileOutput.text == "" || fileOutput.text == fileOutput.defaultText) {
                            result += (result === "" ? "" : "<br>")
                            result += "Project directory is not valid"
                        }
                        return result
                    }
                    visible: createButtonToolTipShow.containsMouse && !createButton.enabled
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
        selectMultiple: false
        selectFolder: true
        folder: fileDialog.shortcuts.home

        onAccepted: {
            fileOutput.text = fileDialog.fileUrl
        }
    }

    function createControlView() {
        let path = fileOutput.text.trim()
        if (!SGUtilsCpp.isFile(path)) {
            path = SGUtilsCpp.urlToLocalFile(path)
        }

        if (!SGUtilsCpp.exists(path)) {
            console.warn("Tried to open non-existent project")
            if (alertMessage.visible) {
                alertMessage.hideInstantly()
            }
            alertMessage.text = "Cannot create project. Destination folder does not exist"
            alertMessage.show()
            return
        }

        const projectExists = sdsModel.newControlView.projectExists(projectName.text, SGUtilsCpp.pathToUrl(path))
        if (projectExists) {
            console.warn("Identically-named project already exists in this location")
            if (alertMessage.visible) {
                alertMessage.hideInstantly()
            }
            alertMessage.text = "A non-empty project '" + projectName.text + "' already exists in the selected location"
            alertMessage.show()
            return
        }

        const qrcUrl = sdsModel.newControlView.createNewProject(projectName.text, SGUtilsCpp.pathToUrl(path), TemplateSelection.selectedPath)
        openProjectContainer.url = qrcUrl
        openProjectContainer.addToTheProjectList(projectName.text, qrcUrl.toString())
        viewStack.currentIndex = 1
        controlViewCreatorRoot.projectInitialization = true
        controlViewCreatorRoot.recompileControlViewQrc()
        projectName.text = ""
        fileOutput.text = ""
    }
}
