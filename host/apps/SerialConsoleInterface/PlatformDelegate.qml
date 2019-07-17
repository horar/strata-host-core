import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.fonts 1.0 as StrataFonts
import QtQuick.Dialogs 1.3
import tech.strata.logger 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.sci 1.0 as Sci

FocusScope {
    id: platformDelegate

    property variant rootItem
    property bool condensedMode: false

    signal sendCommandRequested(string message)
    signal programDeviceRequested()

    ListModel {
        id: scrollbackModel

        onRowsInserted: {
            if (scrollbackView.atYEnd) {
                scrollbackViewAtEndTimer.restart()
            }
        }

        function setCondensedToAll(condensed) {
            for(var i = 0; i < count; ++i) {
                setProperty(i, "condensed", condensed)
            }
        }
    }

    ListModel {
        id: commandHistoryModel
    }

    Timer {
        id: scrollbackViewAtEndTimer
        interval: 1

        onTriggered: {
            scrollbackView.positionViewAtEnd()
        }
    }

    Connections {
        target: Sci.Settings

        onMaxCommandsInScrollbackChanged: {
            sanitizeScrollback()
        }

        onMaxCommandsInHistoryChanged: {
            sanitizeCommandHistory()
        }
    }

    Item {
        id: scrollBackWrapper
        anchors {
            top: parent.top
            topMargin: 4
            bottom: inputWrapper.top
            bottomMargin: 2
            left: parent.left
            right: parent.right
        }

        Rectangle {
            anchors.fill: parent
            color: "white"
        }

        ListView {
            id: scrollbackView
            anchors {
                fill: parent
                leftMargin: 2
                rightMargin: 2
            }

            model: scrollbackModel
            clip: true
            snapMode: ListView.SnapToItem;
            boundsBehavior: Flickable.StopAtBounds;

            ScrollBar.vertical: ScrollBar {
                width: 12
                anchors {
                    top: scrollbackView.top
                    bottom: scrollbackView.bottom
                    right: scrollbackView.right
                }

                policy: ScrollBar.AlwaysOn
                minimumSize: 0.1
                visible: scrollbackView.height < scrollbackView.contentHeight
            }

            delegate: Item {
                id: cmdDelegate
                width: ListView.view.width
                height: divider.y + divider.height

                property color helperTextColor: "#333333"

                Rectangle {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        bottom: divider.top
                    }
                    color: Qt.lighter(SGWidgets.SGColorsJS.STRATA_GREEN, 2.3)
                    visible: model.type === "query"
                }

                SGWidgets.SGText {
                    id: timeText
                    anchors {
                        top: parent.top
                        topMargin: 1
                        left: parent.left
                        leftMargin: 1
                    }

                    text: {
                        var date = new Date(model.timestamp)
                        return date.toLocaleTimeString(Qt.locale(), "hh:mm:ss.zzz")
                    }

                    font.family: StrataFonts.Fonts.inconsolata
                    color: cmdDelegate.helperTextColor
                }

                Row {
                    id: buttonRow
                    anchors {
                        left: timeText.right
                        leftMargin: 2
                        verticalCenter: timeText.verticalCenter
                    }

                    spacing: 2
                    property int iconSize: timeText.font.pixelSize - 4

                    Item {
                        height: buttonRow.iconSize
                        width: buttonRow.iconSize

                        SGWidgets.SGIconButton {
                            anchors.fill: parent

                            iconColor: cmdDelegate.helperTextColor
                            visible: model.type === "query"
                            hintText: qsTr("Resend")
                            icon.source: "qrc:/images/redo.svg"
                            iconSize: buttonRow.iconSize
                            onClicked: {
                                cmdInput.text = JSON.stringify(JSON.parse(model.message))
                            }
                        }
                    }

                    Item {
                        height: buttonRow.iconSize
                        width: buttonRow.iconSize

                        SGWidgets.SGIconButton {
                            id: condenseButton
                            anchors.fill: parent

                            iconColor: cmdDelegate.helperTextColor
                            hintText: qsTr("Condensed mode")
                            icon.source: model.condensed ? "qrc:/sgimages/chevron-right.svg" : "qrc:/sgimages/chevron-down.svg"
                            iconSize: buttonRow.iconSize

                            onClicked: {
                                var item = scrollbackModel.get(index)
                                scrollbackModel.setProperty(index, "condensed", !item.condensed)
                            }
                        }
                    }
                }

                SGWidgets.SGTextEdit {
                    id: cmdText
                    anchors {
                        top: timeText.top
                        left: buttonRow.right
                        leftMargin: 1
                        right: parent.right
                        rightMargin: 2
                    }

                    font.family: StrataFonts.Fonts.inconsolata
                    wrapMode: Text.WrapAnywhere
                    selectByKeyboard: true
                    selectByMouse: true
                    readOnly: true
                    text: prettifyJson(model.message, model.condensed)


                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        acceptedButtons: Qt.NoButton
                    }
                }

                Rectangle {
                    id: divider
                    height: 1
                    anchors {
                        top: cmdText.bottom
                        topMargin: 1
                        left: parent.left
                        right: parent.right
                    }

                    color: "black"
                    opacity: 0.2
                }
            }
        }
    }

    Item {
        id: inputWrapper
        height: cmdInput.y + cmdInput.height + 6
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Row {
            id: toolButtonRow
            anchors {
                top: parent.top
                left: cmdInput.left
            }

            property int iconHeight: tabBar.statusLightHeight
            spacing: 2

            SGWidgets.SGIconButton {
                hintText: qsTr("Clear scrollback")
                icon.source: "qrc:/images/broom.svg"
                iconSize: toolButtonRow.iconHeight
                padding: 4
                onClicked: {
                    scrollbackModel.clear()
                }
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Scroll to the bottom")
                icon.source: "qrc:/images/arrow-bottom.svg"
                iconSize: toolButtonRow.iconHeight
                padding: 4
                onClicked: {
                    scrollbackView.positionViewAtEnd()
                    scrollbackViewAtEndTimer.start()
                }
            }

            SGWidgets.SGIconButton {
                hintText: condensedMode ? qsTr("Expand all commands") : qsTr("Collapse all commands")
                icon.source: condensedMode ? "qrc:/images/list-expand.svg" : "qrc:/images/list-collapse.svg"
                iconSize: toolButtonRow.iconHeight
                padding: 4
                onClicked: {
                    condensedMode = ! condensedMode
                    scrollbackModel.setCondensedToAll(condensedMode)
                }
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Export to file")
                icon.source: "qrc:/images/file-export.svg"
                iconSize: toolButtonRow.iconHeight
                padding: 4
                onClicked: {
                    showFileExportDialog()
                }
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Program Device")
                icon.source: "qrc:/sgimages/chip-flash.svg"
                iconSize: toolButtonRow.iconHeight
                padding: 4
                onClicked: {
                    programDeviceRequested()
                }
            }
        }

        SGWidgets.SGTextField {
            id: cmdInput
            anchors {
                top: toolButtonRow.bottom
                left: parent.left
                right: btnSend.left
                topMargin: 2
                margins: 6
            }

            focus: true
            font.family: StrataFonts.Fonts.inconsolata
            placeholderText: "Enter Command..."
            isValidAffectsBackground: true
            maximumLength: 500
            suggestionListModel: commandHistoryModel
            suggestionModelTextRole: "message"
            suggestionPosition: Item.Top
            suggestionEmptyModelText: qsTr("No commands.")
            suggestionHeaderText: qsTr("Command history")
            suggestionOpenWithAnyKey: false
            suggestionMaxHeight: 250
            suggestionCloseOnDown: true

            Keys.onPressed: {
                isValid = true
                if (event.key === Qt.Key_Up) {
                    if (!suggestionPopup.opened) {
                        suggestionPopup.open()
                    }
                } else if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
                           && event.modifiers === Qt.NoModifier)
                {
                    sendTextInputTextAsComand()
                }
            }

            onSuggestionDelegateSelected: {
                if (index < 0) {
                    return
                }

                cmdInput.text = commandHistoryModel.get(index).message
            }
        }

        SGWidgets.SGButton {
            id: btnSend
            anchors {
                verticalCenter: cmdInput.verticalCenter
                right: parent.right
                rightMargin: 6
            }

            focusPolicy: Qt.NoFocus
            text: qsTr("SEND")
            onClicked: {
                sendTextInputTextAsComand()
            }

            enabled: model.status === "connected"
        }
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            title: qsTr("Select File to Export")
            folder: shortcuts.documents
            selectExisting: false
            defaultSuffix: "log"
        }
    }

    function appendCommand(command) {
        //add it to scrollback
        command["condensed"] = condensedMode
        scrollbackModel.append(command)
        sanitizeScrollback()

        //add it to command history
        try {
            var cmd = JSON.parse(command["message"])
        } catch(error) {
            return
        }

        if (cmd.hasOwnProperty("cmd")) {
            var newCommand = JSON.stringify(cmd)
            for (var i = 0; i < commandHistoryModel.count; ++i) {
                var item = commandHistoryModel.get(i)
                if (item["message"] === newCommand) {
                    commandHistoryModel.move(i, commandHistoryModel.count - 1, 1)
                    return
                }
            }

            commandHistoryModel.append({"message": JSON.stringify(cmd)})
            sanitizeCommandHistory();
        }
    }

    function sanitizeScrollback() {
        var removeCount = scrollbackModel.count - Sci.Settings.maxCommandsInScrollback
        if (removeCount > 0) {
            scrollbackModel.remove(0, removeCount)
        }
    }

    function sanitizeCommandHistory() {
        var removeCount = commandHistoryModel.count - Sci.Settings.maxCommandsInHistory
        if (removeCount > 0) {
            commandHistoryModel.remove(0, removeCount)
        }
    }

    function sendTextInputTextAsComand() {
        if (model.status !== "connected") {
            return
        }

        try {
            var obj =  JSON.parse(cmdInput.text)
        } catch(error) {
            cmdInput.isValid = false
            return
        }

        sendCommandRequested(JSON.stringify(obj))
        cmdInput.clear()
    }

    function showFileExportDialog() {
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(platformDelegate, fileDialogComponent)
        dialog.accepted.connect(function() {
            var result = CommonCpp.SGUtilsCpp.atomicWrite(
                        CommonCpp.SGUtilsCpp.urlToLocalFile(dialog.fileUrl),
                        getTextForExport())

            if (result === false) {
                console.error(LoggerModule.Logger.sciCategory, "failed to export content into", dialog.fileUrl)

                SGWidgets.SGDialogJS.showMessageDialog(
                            rootItem,
                            SGWidgets.SGMessageDialog.Error,
                            "Export Failed",
                            "Writting into selected file failed.")
            } else {
                console.log(Logger.sciCategory, "content exported into", dialog.fileUrl)
            }

            dialog.destroy()})

        dialog.rejected.connect(function() {
            dialog.destroy()
        })

        dialog.open();
    }

    function prettifyJson(message, condensed) {
        if (condensed === undefined) {
            condensed = true
        }

        try {
            var messageObj =  JSON.parse(message)
        } catch(error) {
            return message
        }

        if (condensed) {
            return JSON.stringify(messageObj)
        }

        return JSON.stringify(messageObj, undefined, 4)
    }

    function getTextForExport() {
        var text = ""

        for (var i = 0; i < scrollbackModel.count; ++i) {
            var item = scrollbackModel.get(i)

            var date = new Date(item.timestamp)
            var timeStr = date.toLocaleDateString(Qt.locale(), "yyyy.MM.dd") + " " + date.toLocaleTimeString(Qt.locale(), "hh:mm:ss.zzz")
            var typeStr = item.type === "query" ? "request" : "response"

            text += timeStr + " " + typeStr + "\n"
            text += prettifyJson(item.message, false)
            text += "\n\n"
        }

        return text
    }
}
