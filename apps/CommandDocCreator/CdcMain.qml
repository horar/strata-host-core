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
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.1 as QtLabsSettings
import Qt.labs.platform 1.1 as QtLabsPlatform
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.theme 1.0

Item {
    id: docCreator

    property int spacing: 4
    property var mdExampleWindow: null

    property string currentFilePath: ""
    property string lastOpenedFolder: ""
    property string tempFileName: "new-file.json"
    property bool fileEdited: false
    property int importedItemsLeft: 0

    property string allowedCommandNameChars: "0-9A-Za-z\_\-"
    property var textFieldValidatorRegExp: new RegExp("["+allowedCommandNameChars+"]*");
    property var sanitizeNameRegExp: new RegExp("[^"+allowedCommandNameChars+"]","gi")

    ListModel {
        id: commandModel

        onDataChanged: {
            fileEdited = true
        }

        onRowsInserted: {
            fileEdited = true
        }

        onRowsRemoved: {
            fileEdited = true
        }
    }

    ListModel {
        id: coreModel

        onDataChanged: {
            fileEdited = true
        }

        function clearChecks() {
            for (var i = 0; i < count; ++i) {
                setProperty(i, "checked", false)
            }
        }

        //TODO: once there is REST API to couchbase, we can query this list */
        function init() {
            clear()

            var list = ["get_firmware_info",
                        "get_platform_id",
                        "set_platform_id",
                        "request_platform_id",
                        "start_bootloader",
                        "flash_firmware",
                        "backup_firmware",
                        "start_application"]

            for (var i=0; i < list.length; ++i) {
                var item = {
                    "name": list[i],
                    "checked": false
                }

                coreModel.append(item)
            }
        }
    }

    QtLabsSettings.Settings {
        category: "app"
        property alias commandSectionWidth: commandSection.width
        property alias inputSectionWidth: inputSection.width
        property alias platformCommandHeight: platformCommandSection.height

        property alias currentFilePath: docCreator.currentFilePath
        property alias lastOpenedFolder: docCreator.lastOpenedFolder
    }

    Component.onCompleted: {
        coreModel.init()

        if (currentFilePath.length > 0) {
            var succeed = doImportFromFile(currentFilePath, true)
            if (succeed) {
                return
            }
        }

        newFile()
    }

    Item {
        id: header
        width: parent.width
        height: buttonRow.height + 12

        Rectangle {
            anchors.fill: parent
            color: Theme.palette.dark
        }

        Row {
            id: buttonRow
            anchors {
                left: parent.left
                leftMargin: buttonRow.spacing
                verticalCenter: parent.verticalCenter
            }

            spacing: 20

            property int iconHeight: 30

            SGWidgets.SGIconButton {
                text: "ADD"
                hintText: "Add Command"
                icon.source: "qrc:/sgimages/plus.svg"
                iconSize: buttonRow.iconHeight
                iconColor: Theme.palette.green
                alternativeColorEnabled: true

                onClicked: {
                    appendNewCommand()
                }
            }

            Item {
                width: 1
                height: 1
            }

            SGWidgets.SGIconButton {
                text: "NEW"
                hintText: "New File"
                icon.source: "qrc:/sgimages/file-add.svg"
                iconSize: buttonRow.iconHeight
                alternativeColorEnabled: true
                onClicked: {
                    newFileHandler()
                }
            }

            SGWidgets.SGIconButton {
                text: "OPEN"
                hintText: "Open File"
                icon.source: "qrc:/sgimages/folder-open.svg"
                iconSize: buttonRow.iconHeight
                alternativeColorEnabled: true
                onClicked: {
                    openFileHandler()
                }
            }

            SGWidgets.SGIconButton {
                text: "SAVE"
                hintText: "Save File"
                icon.source: "qrc:/sgimages/save.svg"
                iconSize: buttonRow.iconHeight
                alternativeColorEnabled: true
                onClicked: {
                    saveFileHandler()
                }
            }
        }
    }

    SGWidgets.SGSplitView {
        anchors {
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        SGWidgets.SGSplitView {
            id: commandSection

            Layout.minimumWidth: 250
            orientation: Qt.Vertical

            FocusScope {
                id: platformCommandSection

                Layout.minimumHeight: 300

                SGWidgets.SGText {
                    id: platformCommandLabel
                    anchors {
                        top: parent.top
                        topMargin: 2*docCreator.spacing
                    }

                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: "Platform Commands"
                    fontSizeMultiplier: 1.3
                    font.bold: true
                }

                SGWidgets.SGButton {
                    id: editButton
                    anchors {
                        right: parent.right
                        rightMargin: docCreator.spacing
                        verticalCenter: platformCommandLabel.verticalCenter
                    }

                    text: "Edit"
                    scaleToFit: true
                    checkable: true
                    onClicked: {
                         commandView.inEditMode = !commandView.inEditMode
                    }

                    Binding {
                        target: editButton
                        property: "checked"
                        value: commandView.inEditMode
                    }
                }

                ListView {
                    id: commandView
                    width: parent.width
                    anchors {
                        top: platformCommandLabel.bottom
                        topMargin: docCreator.spacing
                        bottom: parent.bottom
                        bottomMargin: docCreator.spacing
                    }

                    focus: true
                    model: commandModel
                    clip: true

                    property bool inEditMode
                    property int maybeRemoveIndex: -1
                    property int labelEditIndex: -1

                    onInEditModeChanged: {
                        if (inEditMode) {
                            if (commandView.currentItem) {
                                commandView.currentItem.forceActiveFocus()
                            } else {
                                commandView.forceActiveFocus()
                            }
                        } else {
                            maybeRemoveIndex = -1
                            labelEditIndex = -1
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        width: 8
                        policy: ScrollBar.AlwaysOn
                        visible: commandView.height < commandView.contentHeight
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Escape) {
                            if (commandView.maybeRemoveIndex >= 0) {
                                commandView.maybeRemoveIndex = -1
                            } else if (commandView.inEditMode) {
                                commandView.inEditMode = false
                            } else {
                                return
                            }

                        } else {
                            return
                        }

                        event.accepted = true
                    }

                    delegate: FocusScope {
                        id: delegate

                        focus: true

                        width: ListView.view.width
                        height: {
                            if (textFieldLoader.status === Loader.Ready) {
                                return textFieldLoader.height + 2
                            }

                            return label.contentHeight + 2*docCreator.spacing
                        }

                        property bool inRemoveMode: index === commandView.maybeRemoveIndex

                        ListView.onAdd: {
                            if (importedItemsLeft > 0) {
                                --importedItemsLeft
                                return
                            }

                            commandView.currentIndex = index
                            commandView.labelEditIndex = index
                            delegate.forceActiveFocus()
                        }

                        onActiveFocusChanged: {
                            if (delegate.activeFocus === false
                                    && commandView.labelEditIndex === index)
                            {
                                commandView.labelEditIndex = -1
                            }
                        }

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                                if (commandView.labelEditIndex === index) {
                                    commandView.labelEditIndex = -1
                                } else {
                                    if (commandView.inEditMode) {
                                        commandView.labelEditIndex = index
                                    }
                                }
                            } else if (event.key === Qt.Key_Escape) {
                                if (commandView.labelEditIndex === index) {
                                    commandView.labelEditIndex = -1
                                } else {
                                    return
                                }
                            } else {
                                return
                            }

                            event.accepted = true
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: Qt.darker("#aaaaaa", 1.1)
                            visible: delegate.ListView.isCurrentItem
                        }


                        Rectangle {
                            anchors.fill: parent
                            color: "black"
                            opacity: 0.05
                            visible: bgMouseArea.containsMouse
                                     || editLabelButton.hovered
                                     || leftRemoveButton.hovered
                                     || rightRemoveButton.hovered
                        }

                        MouseArea {
                            id: bgMouseArea
                            anchors.fill: parent

                            hoverEnabled: true
                            onClicked: {
                                commandView.currentIndex = index
                                commandView.forceActiveFocus()
                                commandView.maybeRemoveIndex = -1
                            }
                        }

                        Item {
                            id: leftRemoveWrapper
                            width: commandView.inEditMode && delegate.inRemoveMode === false ? leftRemoveButton.width : 0
                            height: parent.height
                            anchors {
                                left: parent.left
                                leftMargin: docCreator.spacing
                            }

                            clip: true

                            Behavior on width {
                                NumberAnimation { duration: 100 }
                            }

                            SGWidgets.SGIconButton {
                                id: leftRemoveButton
                                anchors {
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                }

                                icon.source: "qrc:/sgimages/times-circle.svg"
                                iconSize: label.contentHeight + 2
                                iconColor: TangoTheme.palette.error

                                onClicked: {
                                    commandView.currentIndex = index
                                    commandView.maybeRemoveIndex = index
                                    delegate.forceActiveFocus()
                                }
                            }
                        }

                        SGWidgets.SGText {
                            id: label

                            anchors {
                                left: leftRemoveWrapper.right
                                leftMargin: docCreator.spacing
                                right: editLabelButton.shown ? editLabelButton.left : rightRemoveWrapper.left
                                rightMargin: docCreator.spacing
                                verticalCenter: parent.verticalCenter
                            }

                            elide: Text.ElideRight
                            font.italic: nameIsEmpty
                            text: nameIsEmpty ? "empty" : model.name
                            visible: !textFieldLoader.sourceComponent
                            opacity: nameIsEmpty ? 0.6 : 1

                            property bool nameIsEmpty: model.name === ""
                        }

                        SGWidgets.SGIconButton {
                            id: editLabelButton
                            anchors {
                                right: rightRemoveWrapper.left
                                rightMargin: docCreator.spacing
                                verticalCenter: label.verticalCenter
                            }

                            icon.source: "qrc:/sgimages/edit.svg"
                            iconSize: parent.height - 2*docCreator.spacing

                            opacity: shown ? 1 : 0
                            enabled: shown

                            property bool shown: commandView.inEditMode
                                                 && (bgMouseArea.containsMouse
                                                     || hovered
                                                     || leftRemoveButton.hovered
                                                     || rightRemoveButton.hovered)

                            onClicked: {
                                commandView.labelEditIndex = index
                                commandView.currentIndex = index
                                delegate.forceActiveFocus()
                            }
                        }

                        Item {
                            id: rightRemoveWrapper
                            width: delegate.inRemoveMode ? rightRemoveButton.width : 0
                            height: parent.height
                            anchors {
                                right: parent.right
                                rightMargin: docCreator.spacing
                            }

                            Behavior on width {
                                NumberAnimation { duration: 100 }
                            }

                            clip: true

                            SGWidgets.SGIconButton {
                                id: rightRemoveButton
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }

                                icon.source: "qrc:/sgimages/times-circle.svg"
                                iconSize: label.contentHeight + 2
                                iconColor: TangoTheme.palette.error

                                onClicked: {
                                    commandView.maybeRemoveIndex = -1

                                    var doRefresh = index < commandModel.count - 1

                                    commandModel.remove(index)

                                    if (doRefresh) {
                                        descTextArea.text = descTextArea.refreshContent()
                                    }
                                }
                            }
                        }

                        Loader {
                            id: textFieldLoader

                            anchors {
                                left: parent.left
                                leftMargin: docCreator.spacing
                                right: parent.right
                                rightMargin: docCreator.spacing
                                verticalCenter: parent.verticalCenter
                            }

                            sourceComponent: {
                                if (commandView.labelEditIndex >= 0
                                        && commandView.labelEditIndex === index) {
                                    return textFieldComponent
                                }

                                return null
                            }

                            onStatusChanged: {
                                if (status === Loader.Ready) {
                                    item.forceActiveFocus()
                                }
                            }
                        }

                        Component {
                            id: textFieldComponent

                            SGWidgets.SGTextField {
                                id: textField

                                validator: RegExpValidator {
                                    regExp: textFieldValidatorRegExp
                                }

                                text: name
                                isValidAffectsBackground: true
                                isValid: textField.acceptableInput

                                onEditingFinished: {
                                    commandModel.setProperty(index, "name", text)
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.minimumHeight: 200
                Layout.fillHeight: true

                SGWidgets.SGText {
                    id: coreCommandLabel
                    width: parent.width
                    anchors {
                        top: parent.top
                        topMargin: 2*docCreator.spacing
                    }

                    horizontalAlignment: Text.AlignHCenter
                    text: "Supported\nCore Commands"
                    fontSizeMultiplier: 1.3
                    font.bold: true
                }

                ListView {
                    id: coreView
                    width: parent.width
                    anchors {
                        top: coreCommandLabel.bottom
                        topMargin: docCreator.spacing
                        bottom: parent.bottom
                    }

                    model: coreModel
                    clip: true

                    ScrollBar.vertical: ScrollBar {
                        width: 8
                        policy: ScrollBar.AlwaysOn
                        visible: coreView.height < coreView.contentHeight
                    }

                    delegate: SGWidgets.SGCheckBox {
                        id: checkBox
                        text: model.name

                        onCheckedChanged: {
                            coreModel.setProperty(index, "checked", checked)
                        }

                        Binding {
                            target: checkBox
                            property: "checked"
                            value: model.checked
                        }
                    }
                }
            }
        }

        Item {
            id: inputSection

            Layout.minimumWidth: 300

            Item {
                id: inputSectionHeader

                width: parent.width
                height: mdTextAreaLabel.contentHeight + 3*docCreator.spacing

                SGWidgets.SGText {
                    id: mdTextAreaLabel
                    anchors {
                        top: parent.top
                        topMargin: 2*docCreator.spacing
                    }

                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: "Description"
                    fontSizeMultiplier: 1.3
                    font.bold: true
                }

                SGWidgets.SGIconButton {
                    id: mdHelpButton
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: docCreator.spacing
                    }

                    iconSize: parent.height - 2*docCreator.spacing

                    icon.source: "qrc:/sgimages/question-circle.svg"
                    hintText: "Markdown syntax overview"

                    onClicked: showMdExampleWindow()
                }
            }


            SGWidgets.SGTextArea {
                id: descTextArea

                anchors {
                    top: inputSectionHeader.bottom
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    margins: 2
                }

                enabled: commandView.count > 0
                tabAllowed: true

                placeholderText: "Use markdown syntax to format text"

                Binding {
                    target: descTextArea
                    property: "text"
                    value: descTextArea.refreshContent()
                }

                onTextChanged: {
                    if (commandView.currentIndex < 0) {
                        return ""
                    }

                    commandModel.setProperty(commandView.currentIndex, "description", text)
                }

                function refreshContent() {
                    if (commandView.currentIndex < 0) {
                        return ""
                    }

                    return commandModel.get(commandView.currentIndex).description
                }
            }
        }

        Item {
            Layout.minimumWidth: 200
            Layout.fillWidth: true

            SGWidgets.SGMarkdownViewer {
                anchors.fill: parent

                text: descTextArea.text
            }
        }
    }

    function newFileHandler() {
        saveFileOrDoAction(
                    "New File",
                    function() {
                        newFile()
                    })
    }

    function openFileHandler() {
        commandView.inEditMode = false
        saveFileOrDoAction(
                    "Open File",
                    function() {
                        importFromFile()
                    })
    }

    function saveFileHandler() {
        saveCurrentState()
    }

    function saveAsFileHandler() {
        saveCurrentState(true)
    }

    function appendNewCommand() {
        var item = {
            "name": "",
            "description": "",
        }

        commandModel.append(item)
    }

    function saveCurrentState(doSaveAs, callbackSuccessful) {
        if (currentFilePath.length === 0 || doSaveAs) {
            getFilePath(
                        {
                            "title": "Select  file",
                            "selectExisting": false,
                            "defaultSuffix": "json",
                        },
                        function(path) {
                            var succeed = doSave(path)
                            if (succeed) {
                                currentFilePath = path
                                fileEdited = false

                                if (callbackSuccessful) {
                                    callbackSuccessful()
                                }
                            }
                        })
        } else {
            var succeed = doSave(currentFilePath)
            if (succeed) {
                fileEdited = false
                if (callbackSuccessful) {
                    callbackSuccessful()
                }
            }
        }
    }

    function doSave(path) {
        var output = serializeData()
        var fileSaved = CommonCPP.SGUtilsCpp.atomicWrite(path, output)
        if (fileSaved === false) {
            console.error(Logger.cdcCategory, "cannot save content into file", path)

            SGWidgets.SGDialogJS.showConfirmationDialog(
                        root,
                        "File not saved",
                        "File could not be saved as\n\n"+
                        path +"\n\n" +
                        "Do you want to save it elsewhere?",
                        "Save As...",
                        function() {
                            saveAsFileHandler()
                        },
                        "Cancel",
                        undefined,
                        SGWidgets.SGMessageDialog.Error)

            return false
        }

        console.log(Logger.cdcCategory, "content saved", path)
        return true
    }

    function serializeData() {
        var commandList = []

        for (var i = 0; i < commandModel.count; ++i) {
            var item = commandModel.get(i)

            var insertItem = {
                "name": item.name,
                "description": Qt.btoa(item.description) + ""
            }
            commandList.push(insertItem)
        }

        var coreList = []
        for (var i = 0; i < coreModel.count; ++i) {
            var item = coreModel.get(i)
            if(item["checked"] === true) {
                coreList.push(item["name"])
            }
        }

        var obj = {
            "command_list": commandList,
            "core_command_list": coreList,
            "format_version": "1.0"
        }

        return JSON.stringify(obj, undefined, 4)
    }


    function newFile() {
        currentFilePath = ""

        commandModel.clear()
        coreModel.clearChecks()

        fileEdited = false
    }

    function importFromFile() {
        getFilePath(
                    {
                        "title": "Select JSON file",
                        "nameFilters": ["JSON files (*.json)","All files (*)"],
                    },
                    function(path) {
                        currentFilePath = path
                        doImportFromFile(path)
                    })
    }

    function doImportFromFile(path, silently) {
        console.log(Logger.cdcCategory, "lets load", path)

        if (CommonCPP.SGUtilsCpp.isFile(path) === false) {
            console.error(Logger.cdcCategory, path, "is not a file")
            handleImportError("", silently)
            return false
        }

        var parseError = ""

        try {
            var content = JSON.parse(CommonCPP.SGUtilsCpp.readTextFileContent(path))
        }
        catch(error) {
            console.error(Logger.cdcCategory, "file import failed: ", error)
            handleImportError(error, silently)
            return false
        }

        commandModel.clear()
        coreModel.clearChecks()

         //populate platform commands
        if (content.hasOwnProperty("command_list") === false) {
            console.error(Logger.cdcCategory, "file import failed: no command_list property")
            handleImportError("", silently)
            return false
        }

        var commandList = content["command_list"]
        var ll = commandList.length

        for (var i = 0; i < ll; ++i) {
            var commandItem = commandList[i]

            if (commandItem.hasOwnProperty("name") === false
                    || commandItem.hasOwnProperty("description") === false) {


                console.error(Logger.cdcCategory, "file import failed: wrong command object structure")
                handleImportError("", silently)
                return false
            }

            var item = {
                "name": sanitizeName(commandItem["name"]),
                "description": CommonCPP.SGUtilsCpp.fromBase64(commandItem["description"]) + "",
            }
            ++importedItemsLeft
            commandModel.append(item)
        }

        //populate core commands
        if (content.hasOwnProperty("core_command_list") === false) {
            console.error(Logger.cdcCategory, "file import failed: no core_command_list property")
            handleImportError("", silently)
            return false
        }

        var coreCommandList = content["core_command_list"]
        ll = coreCommandList.length

        for (var i = 0; i < coreModel.count; ++i) {
            var isChecked = false
            for (var j = 0; j < ll; ++j) {
                if (coreModel.get(i).name === coreCommandList[j]) {
                    isChecked = true
                    break
                }
            }
            coreModel.setProperty(i, "checked", isChecked)
        }

        fileEdited = false

        return true
    }

    function sanitizeName(name) {
        var sanitized = name.replace(sanitizeNameRegExp, "")

        if (name !== sanitized) {
            console.log(Logger.cdcCategory, name, "->", sanitized)
        }

        return sanitized
    }

    function handleImportError(message, silently) {
        commandModel.clear()
        coreModel.clearChecks()
        importedItemsLeft = 0

        if (silently) {
            return
        }

        var text = "File has not a valid syntax and cannot be imported."
        if(message && message.length) {
            text += "\n\n"
            text += message
        }

        SGWidgets.SGDialogJS.showMessageDialog(
                    root,
                    SGWidgets.SGMessageDialog.Error,
                    qsTr("File import failed"),
                    text)
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            folder: lastOpenedFolder.length > 0 ? lastOpenedFolder : shortcuts.documents
        }
    }

    function getFilePath(properties, callback) {
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(
                    docCreator,
                    fileDialogComponent,
                    properties)

        dialog.accepted.connect(function() {
            if (callback) {
                lastOpenedFolder = dialog.folder
                callback(CommonCPP.SGUtilsCpp.urlToLocalFile(dialog.fileUrl))
            }

            dialog.destroy()
        })

        dialog.rejected.connect(function() {
            dialog.destroy()
        })

        dialog.open();
    }

    function showMdExampleWindow() {
        if (mdExampleWindow) {
            mdExampleWindow.close()
        }

        mdExampleWindow = SGWidgets.SGDialogJS.createDialog(
                    root,
                    "qrc:/MdExampleWindow.qml")

        mdExampleWindow.visible = true
    }

    function saveFileOrDoAction(actionTitle, callbackAction) {
        if (fileEdited) {
            SGWidgets.SGDialogJS.showConfirmationDialog(
                        root,
                        "Want to save your changes first?",
                        "Your changes will be lost if you don't save them.",
                        "Save",
                        function() {
                            saveCurrentState(
                                        undefined,
                                        function() {
                                        })
                        },
                        actionTitle,
                        function() {
                            callbackAction()
                        })
        } else {
            callbackAction()
        }
    }
}
