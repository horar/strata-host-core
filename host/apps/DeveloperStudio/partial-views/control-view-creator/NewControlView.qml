import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "utils/template_selection.js" as TemplateSelection
import "components/"

import "../general"

Rectangle {
    id: createNewContainer
    color: "#ccc"

    property alias templateButtonGroup: templateButtonGroup
    property var openProjectContainer: openControlView.projectContainer

    onVisibleChanged: {
        if (!visible) {
            alertMessage.Layout.preferredHeight = 0
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

        onPopupClosed: {
            if (closeReason === confirmClosePopup.closeFilesReason) {
                editor.openFilesModel.closeAll()
            } else if (closeReason === confirmClosePopup.acceptCloseReason) {
                editor.openFilesModel.saveAll(true)
            }

            controlViewCreatorRoot.isConfirmCloseOpen = false

            if (closeReason !== confirmClosePopup.cancelCloseReason) {
                if (createControlView(fileOutput.text)) {
                    fileOutput.text = "Select a folder for your project..."
                }
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
            Layout.preferredWidth: parent.width * 0.7
            interval: 0
            z: 100
            color: "red"
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
                id: browseButton
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
                    text: "Select a folder for your project..."
                    color: "#333"
                    verticalAlignment: Text.AlignVCenter
                    selectByMouse: true
                    leftPadding: 10
                    persistentSelection: true   // must deselect manually

                    onActiveFocusChanged: {
                        if ((activeFocus === false) && (contextMenuPopup.visible === false)) {
                            fileOutput.deselect()
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        acceptedButtons: Qt.RightButton
                        onClicked: {
                            fileOutput.forceActiveFocus()
                        }
                        onReleased: {
                            if (containsMouse) {
                                contextMenuPopup.popup(null)
                            }
                        }
                    }

                    SGContextMenuEditActions {
                        id: contextMenuPopup
                        textEditor: fileOutput
                    }
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
                rowSpacing: 10
                columnSpacing: 10
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

        SGControlViewButton {
            id: createButton
            Layout.fillWidth: true
            Layout.preferredHeight: 35
            text: "Create Project"

            function onClicked() {
                if (fileOutput.text !== "" && fileOutput.text !== "Select a folder for your project...") {
                    let unsavedFileCount = editor.openFilesModel.getUnsavedCount()
                    if (unsavedFileCount > 0) {
                        if (!controlViewCreatorRoot.isConfirmCloseOpen) {
                            confirmClosePopup.unsavedFileCount = unsavedFileCount
                            confirmClosePopup.open()
                            controlViewCreatorRoot.isConfirmCloseOpen = true
                        }
                    } else {
                        if (createControlView(fileOutput.text)) {
                            fileOutput.text = "Select a folder for your project..."
                        }
                    }
                }
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

        Item {
            // space filler
            Layout.fillHeight: true
        }
    }

    function createControlView(filepath) {
        let path = filepath.trim();
        if (path.startsWith("file:")) {
            // type is url
            path = SGUtilsCpp.urlToLocalFile(path);
        }

        if (!SGUtilsCpp.exists(path)) {
            console.warn("Tried to open non-existent project")
            if (alertMessage.visible) {
                alertMessage.Layout.preferredHeight = 0
            }
            alertMessage.text = "Cannot create project. Destination folder does not exist"
            alertMessage.show()
            return false;
        }

        const qrcUrl = sdsModel.newControlView.createNewProject(
                         SGUtilsCpp.pathToUrl(path),
                         TemplateSelection.selectedPath
                         );
        openProjectContainer.url = qrcUrl
        openProjectContainer.addToTheProjectList(qrcUrl.toString())
        controlViewCreatorRoot.rccInitialized = false
        toolBarListView.currentIndex = toolBarListView.editTab
        return true;
    }
}
