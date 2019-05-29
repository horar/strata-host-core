import QtQuick 2.12
import QtQuick.Controls 2.12
import "./common" as Common
import "./common/Colors.js" as Colors
import tech.strata.fonts 1.0 as StrataFonts
import QtQuick.Dialogs 1.3
import "./common/SgUtils.js" as SgUtils
import tech.strata.utils 1.0

FocusScope {
    id: platformDelegate

    property string connectionId: model.connectionId
    property int maxCommandsInHistory: 20
    property int maxCommandsInScrollback: 200
    property variant rootItem

    signal sendCommandRequested(string message)

    ListModel {
        id: scrollbackModel

        onRowsInserted: {
            if (scrollbackView.atYEnd) {
                scrollbackViewAtEndTimer.restart()
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

    Item {
        id: scrollBackWrapper
        anchors {
            top: parent.top
            topMargin: 4
            bottom: inputWrapper.top
            bottomMargin: 4
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
                    color: Qt.lighter(Colors.STRATA_GREEN, 2.3)
                    visible: model.type === "query"
                }

                Item {
                    id: header
                    width: headerRow.width
                    height: headerRow.height
                    anchors {
                        top: parent.top
                        topMargin: 1
                        left: parent.left
                        leftMargin: 1
                    }

                    Row {
                        id: headerRow
                        spacing: 8

                        property int iconSize: 16

                        Common.SgText {
                            id: timeText
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }

                            text: {
                                var date = new Date(model.timestamp)
                                return date.toLocaleTimeString(Qt.locale(), "hh:mm:ss.zzz")
                            }

                            fontSizeMultiplier: 1.1
                            font.family: StrataFonts.Fonts.inconsolata
                            color: cmdDelegate.helperTextColor
                        }

                        Common.SgIconButton {
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            height: timeText.font.pointSize
                            width: height

                            color: cmdDelegate.helperTextColor
                            visible: model.type === "query"
                            hintText: qsTr("Resend")
                            source: "qrc:/images/redo.svg"
                            onClicked: {
                                cmdInput.text = JSON.stringify(JSON.parse(model.message))
                            }
                        }
                    }
                }

                Item {
                    id: leftColumn
                    width: condenseButton.width
                    height: condenseButton.height
                    anchors {
                        left: header.left
                        top: cmdText.top
                    }

                    Common.SgIconButton {
                        id: condenseButton
                        height: cmdText.font.pointSize
                        width: height

                        color: cmdDelegate.helperTextColor
                        hintText: qsTr("Condensed mode")
                        source: model.condensed ? "qrc:/images/chevron-right.svg" : "qrc:/images/chevron-down.svg"
                        onClicked: {
                            var item = scrollbackModel.get(index)
                            scrollbackModel.setProperty(index, "condensed", !item.condensed)
                        }
                    }
                }

                TextEdit {
                    id: cmdText
                    anchors {
                        top: header.bottom
                        left: leftColumn.right
                        leftMargin: 2
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
            id: buttonRow
            anchors {
                top: parent.top
                topMargin: 6
                left: cmdInput.left
            }

            property int iconHeight: 20
            spacing: 6

            Common.SgIconButton {
                height: buttonRow.iconHeight
                width: height

                hintText: qsTr("Clear scrollback")
                source: "qrc:/images/broom.svg"
                onClicked: {
                    scrollbackModel.clear()
                }
            }

            Common.SgIconButton {
                height: buttonRow.iconHeight
                width: height

                hintText: qsTr("Scroll to the bottom")
                source: "qrc:/images/arrow-bottom.svg"
                onClicked: {
                    scrollbackView.positionViewAtEnd()
                    scrollbackViewAtEndTimer.start()
                }
            }

            Common.SgIconButton {
                height: buttonRow.iconHeight
                width: height

                hintText: qsTr("Export to file")
                source: "qrc:/images/file-export.svg"
                onClicked: {
                    showFileExportDialog()
                }
            }
        }

        Common.SgTextField {
            id: cmdInput
            anchors {
                top: buttonRow.bottom
                left: parent.left
                right: btnSend.left
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

        Common.SgButton {
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
        scrollbackModel.append(command)
        if (scrollbackModel.count > maxCommandsInScrollback) {
            scrollbackModel.remove(0)
        }

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
            if (commandHistoryModel.count > maxCommandsInHistory) {
                commandHistoryModel.remove(0)
            }
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
        var dialog = SgUtils.createDialogFromComponent(platformDelegate, fileDialogComponent)

        dialog.accepted.connect(function() {
            var result = SgUtilsCpp.atomicWrite(
                        SgUtilsCpp.urlToPath(dialog.fileUrl),
                        getTextForExport())

            if (result === false) {
                SgUtils.showMessageDialog(
                            rootItem,
                            Common.SgMessageDialog.Error,
                            "Export Failed",
                            "Writting into selected file failed.")
            }

            console.log("showFileExportDialog() atomicWrite()", dialog.fileUrl, result)

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
