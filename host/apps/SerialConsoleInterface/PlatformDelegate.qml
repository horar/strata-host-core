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
    property bool disableAllFiltering: false
    property var filterList: []

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

    CommonCpp.SGSortFilterProxyModel {
        id: scrollbackFilterModel
        sourceModel: scrollbackModel
        filterRole: "message"
        sortEnabled: false
        invokeCustomFilter: true

        function filterAcceptsRow(row) {
            if (filterList.length === 0) {
                return true
            }

            if (disableAllFiltering) {
                return true
            }

            var item = sourceModel.get(row)

            if (item.type === "query") {
                return true
            }

            var notificationItem = JSON.parse(item["message"])["notification"]
            if (notificationItem === undefined) {
               return true
            }

            for (var i = 0; i < platformDelegate.filterList.length; ++i) {
                var filterItem = platformDelegate.filterList[i]
                if (notificationItem.hasOwnProperty(filterItem["property"])) {
                    var value = notificationItem[filterItem["property"]]
                    var valueType = typeof(value)

                    if (valueType === "string"
                            || valueType === "boolean"
                            || valueType === "number"
                            || valueType === "bigint") {

                        var filterValue = filterItem["value"].toString().toLowerCase()
                        value = value.toString().toLowerCase()

                        if (filterItem["condition"] === "contains" && value.includes(filterValue)) {
                            return false
                        } else if(filterItem["condition"] === "equal" && value === filterValue) {
                            return false
                        } else if(filterItem["condition"] === "startswith" && value.startsWith(filterValue)) {
                            return false
                        } else if(filterItem["condition"] === "endswith" && value.endsWith(filterValue)) {
                            return false
                        }
                    }
                }
            }

            return true
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

        onCommandsInScrollbackUnlimitedChanged: {
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

            model: scrollbackFilterModel
            clip: true
            snapMode: ListView.SnapToItem
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                width: 12
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
                        height: condenseButtonWrapper.height
                        width: condenseButtonWrapper.width

                        Loader {
                            sourceComponent: model.type === "query" ? resendButtonComponent : undefined
                        }

                        Component {
                            id: resendButtonComponent
                            SGWidgets.SGIconButton {
                                iconColor: cmdDelegate.helperTextColor
                                hintText: qsTr("Resend")
                                icon.source: "qrc:/images/redo.svg"
                                iconSize: buttonRow.iconSize
                                onClicked: {
                                    cmdInput.text = JSON.stringify(JSON.parse(model.message))
                                }
                            }
                        }
                    }

                    Item {
                        id: condenseButtonWrapper
                        height: childrenRect.height
                        width: childrenRect.width

                        SGWidgets.SGIconButton {
                            id: condenseButton

                            iconColor: cmdDelegate.helperTextColor
                            hintText: qsTr("Condensed mode")
                            icon.source: model.condensed ? "qrc:/sgimages/chevron-right.svg" : "qrc:/sgimages/chevron-down.svg"
                            iconSize: buttonRow.iconSize

                            onClicked: {
                                var sourceIndex = scrollbackFilterModel.mapIndexToSource(index)
                                var item = scrollbackModel.get(sourceIndex)
                                scrollbackModel.setProperty(sourceIndex, "condensed", !item.condensed)
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
            spacing: 4

            SGWidgets.SGIconButton {
                hintText: qsTr("Clear scrollback")
                icon.source: "qrc:/images/broom.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    scrollbackModel.clear()
                }
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Scroll to the bottom")
                icon.source: "qrc:/images/arrow-bottom.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    scrollbackView.positionViewAtEnd()
                    scrollbackViewAtEndTimer.start()
                }
            }

            SGWidgets.SGIconButton {
                hintText: condensedMode ? qsTr("Expand all commands") : qsTr("Collapse all commands")
                icon.source: condensedMode ? "qrc:/images/list-expand.svg" : "qrc:/images/list-collapse.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    condensedMode = ! condensedMode
                    scrollbackModel.setCondensedToAll(condensedMode)
                }
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Export to file")
                icon.source: "qrc:/sgimages/file-export.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    showFileExportDialog()
                }
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Program Device")
                icon.source: "qrc:/sgimages/chip-flash.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    programDeviceRequested()
                }
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Platform Info")
                icon.source: "qrc:/sgimages/info-circle.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    showPlatformInfoWindow("201", model.verboseName)
                }
                //hiden until remote db is ready
                visible: false
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Filter")
                icon.source: "qrc:/sgimages/funnel.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    openFilterDialog()
                }
            }
        }

        SGWidgets.SGTag {
            anchors {
                verticalCenter: toolButtonRow.verticalCenter
                right: parent.right
                rightMargin: 6
            }

            sizeByMask: true
            mask: "Filtered notifications: " + "9".repeat(filteredCount.toString().length)
            text: "Filtered notifications: " + filteredCount
            visible: filteredCount > 0

            property int filteredCount: scrollbackModel.count - scrollbackFilterModel.count
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
                           && (event.modifiers === Qt.NoModifier || event.modifiers & Qt.KeypadModifier))
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
        if (Sci.Settings.commandsInScrollbackUnlimited) {
            var limit = 200000
        } else {
            limit = Sci.Settings.maxCommandsInScrollback
        }

        var removeCount = scrollbackModel.count - limit

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
                console.error(Logger.sciCategory, "failed to export content into", dialog.fileUrl)

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

    function getCommandHistoryList() {
        var list = []
        for (var i = 0; i < commandHistoryModel.count; ++i) {
            list.push(commandHistoryModel.get(i)["message"]);
        }

        return list
    }

    function setCommandHistoryList(list) {
        for (var i = 0; i < list.length; ++i) {
            commandHistoryModel.append({"message": list[i]})
        }
    }

    function openFilterDialog() {
        var dialog = SGWidgets.SGDialogJS.createDialog(
                    root,
                    "qrc:/FilterDialog.qml",
                    {
                        "disableAllFiltering": disableAllFiltering,
                    })

        var list = []

        dialog.populateFilterData(filterList)

        dialog.accepted.connect(function() {
            filterList = JSON.parse(JSON.stringify(dialog.getFilterData()))
            disableAllFiltering = dialog.disableAllFiltering

            console.log(Logger.sciCategory, "filters:", JSON.stringify(filterList))
            console.log(Logger.sciCategory, "disableAllFiltering", disableAllFiltering)

            scrollbackFilterModel.invalidate()
        })

        dialog.open()
    }
}
