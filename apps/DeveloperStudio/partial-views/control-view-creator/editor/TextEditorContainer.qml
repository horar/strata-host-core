/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.3
import QtWebEngine 1.8
import QtWebChannel 1.0

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.theme 1.0
import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl

import "../../general"
import "../"
import "../components"

ColumnLayout {
    id: fileContainerRoot
    spacing: 0

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
    property bool internalChanges: model.unsavedChanges

    signal saveClicked()
    signal undoClicked()
    signal redoClicked()

    signal textEditorSavedFile(string file)

    function openFile() {
        let fileText = SGUtilsCpp.readTextFileContent(SGUtilsCpp.urlToLocalFile(model.filepath))

        // Before returning the fileText, replace tabs with 4 spaces
        return fileText.replace(/\t/g, '    ')
    }

    function resetHeightAndWidth() {
        var htmlHeight = webEngine.height - 16
        var htmlWidth = webEngine.width - 16
        channelObject.resetContainer(htmlHeight, htmlWidth)
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

            textEditorSavedFile(model.filepath)

            // Force QRC model reload if QRC file is changed and saved
            if (model.filepath === treeModel.url) {
                treeModel.reloadQrcModel()
            }

            if (closeFile) {
                openFilesModel.closeTabAt(modelIndex)
            } else {
                visualEditor.functions.checkFile()
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
        target: fileContainerRoot

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

        onCurrentIndexChanged: {
            if (openFilesModel.currentIndex === fileContainerRoot.modelIndex) {
                resetHeightAndWidth()
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

    SGNotificationToast {
        id: alertToast
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
        interval: 0
        color: Theme.palette.error
    }

    RowLayout {
        id: menuRow
        Layout.fillHeight: false
        Layout.preferredHeight: 40
        Layout.leftMargin: spacing

        ButtonGroup {
            id: buttonGroup
            exclusive: true
        }

        MenuButton {
            id: textEditorButton
            text: "Text Editor"
            checkable: true
            checked: viewStack.currentIndex === 0

            implicitHeight: menuRow.height - 10

            Component.onCompleted: {
                buttonGroup.addButton(this)
            }

            onCheckedChanged: {
                if (checked) {
                    viewStack.currentIndex = 0
                }
            }
        }

        Item {
            implicitHeight: visualEditorButton.implicitHeight
            implicitWidth: visualEditorButton.implicitWidth

            MenuButton {
                id: visualEditorButton
                text: "Visual Editor"
                checkable: true
                implicitHeight: menuRow.height - 10
                enabled: visualEditor.fileValid
                checked: viewStack.currentIndex === 1

                Component.onCompleted: {
                    buttonGroup.addButton(this)
                }

                onCheckedChanged: {
                    if (checked) {
                        viewStack.currentIndex = 1
                    }
                }
            }

            MouseArea {
                id: toolTipMouse
                anchors {
                    fill: parent
                }
                hoverEnabled: enabled
                enabled: !visualEditorButton.enabled

                ToolTip {
                    visible: toolTipMouse.containsMouse
                    text: "Visual Editor supports QML files only"
                }
            }
        }

        Rectangle {
            // divider
            Layout.preferredHeight: menuRow.height - 6
            Layout.preferredWidth: 1
            color: "grey"
            visible: !menuLoader.active
        }

        Repeater {
            id: mainButtons

            model: [
                { buttonType: "save", iconSource: "qrc:/sgimages/save.svg", visible: !menuLoader.active, enabled: internalChanges },
                { buttonType: "undo", iconSource: "qrc:/sgimages/undo.svg", visible: !menuLoader.active, enabled: true },
                { buttonType: "redo", iconSource: "qrc:/sgimages/redo.svg", visible: !menuLoader.active, enabled: true }
            ]

            delegate: Button {
                Layout.preferredHeight: 25
                Layout.preferredWidth: height

                enabled: openFilesModel.count > 0 && modelData.enabled
                visible: modelData.visible

                background: Rectangle {
                    radius: 0
                    color: enabled === false ? "transparent" : hovered ? "#eee" : "#fff"
                }

                SGIcon {
                    id: icon
                    anchors.fill: parent
                    anchors.margins: 4
                    iconColor: parent.enabled ? Qt.rgba(255, 255, 255, 0.4) : "light gray"
                    source: modelData.iconSource
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: parent.enabled
                    hoverEnabled: true
                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onPressed: {
                        icon.iconColor = Qt.darker(icon.iconColor, 1.5)
                    }

                    onReleased: {
                        icon.iconColor = Qt.rgba(255, 255, 255, 0.4)
                    }

                    onClicked: {
                        switch (modelData.buttonType) {
                            case "save":
                                saveClicked()
                                break
                            case "undo":
                                undoClicked()
                                break
                            case "redo":
                                redoClicked()
                                break
                        }
                    }
                }
            }
        }

        Rectangle {
            // divider
            Layout.preferredHeight: menuRow.height - 6
            Layout.preferredWidth: 1
            color: "grey"
            visible: menuLoader.active
        }

        Loader {
            id: menuLoader
            active: menuLoaded
            Layout.fillWidth: true

            property bool menuLoaded: false

            source: {
                switch (viewStack.currentIndex) {
                    case 0:
                        menuLoaded = false
                        return ""
                    case 1:
                        menuLoaded = true
                        return "qrc:/partial-views/control-view-creator/editor/visual-editor/VisualEditorMenu.qml"
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
        currentIndex: 0

        Item {

            Keys.onPressed: {
                if (event.matches(StandardKey.Save)) {
                    saveFile()
                }
            }

            WebEngineView {
                id: webEngine
                webChannel: channel
                url: "qrc:///tech/strata/monaco/minified/editor.html"
                anchors.fill: parent

                settings.localContentCanAccessRemoteUrls: false
                settings.localContentCanAccessFileUrls: true
                settings.localStorageEnabled: true
                settings.errorPageEnabled: false
                settings.javascriptCanOpenWindows: false
                settings.javascriptEnabled: true
                settings.javascriptCanAccessClipboard: true
                settings.pluginsEnabled: true
                settings.showScrollBars: false

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
                    channelObject.setContainerHeight(htmlHeight)
                }

                onWidthChanged: {
                    var htmlWidth = width - 16
                    channelObject.setContainerWidth(htmlWidth)
                }

                // This handles the edge case of height and width not being reset after minimizing and/or maximizing the window,
                // the visibilty changed is called when the window is resized from signals outside of the app
                Connections {
                    target: mainWindow

                    onVisibilityChanged: {
                        resetHeightAndWidth()
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
                            "error_intro": "Control View Creator Error:",
                            "error_message": "Monaco text editor component failed to load or was not found"
                        }

                        fileLoader.setSource(NavigationControl.screens.LOAD_ERROR, errorProperties);
                    }
                }
            }

            Rectangle {
               	id: barContainer
                color: "white"
                anchors {
                    fill: parent
                }
                visible: indicator.playing

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

        VisualEditor {
            id: visualEditor
            file: model.filepath
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
        signal setContainerHeight(int height)
        signal setContainerWidth(int width)
        signal resetContainer(int height, int width)
        signal undo()
        signal redo()
        signal goToUUID(string uuid)

        function setFinished(isFinished) {
            indicator.playing = !isFinished
        }

        function setHtml(value) {
            setValue(value)
        }

        function checkForErrors(flag, log) {
            if (flag) {
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

                if (reset) {
                    reset = false
                }
            }

            currentVersionId = version
            model.unsavedChanges = (savedVersionId !== version)
        }
    }

    Connections {
        target: visualEditor.functions

        onPassUUID: {
            viewStack.currentIndex = 0
            channelObject.goToUUID(uuid)
        }
    }
}
