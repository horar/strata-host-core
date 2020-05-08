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
    property variant scrollbackModel
    property variant commandHistoryModel

    property bool disableAllFiltering: false
    property var filterList: []
    property bool automaticScroll: true

    signal programDeviceRequested()

    CommonCpp.SGSortFilterProxyModel {
        id: scrollbackFilterModel
        sourceModel: scrollbackModel
        filterRole: "message"
        sortEnabled: false
        invokeCustomFilter: true

        onRowsInserted: {
            if (automaticScroll) {
                scrollbackViewAtEndTimer.restart()
            }
        }

        function filterAcceptsRow(row) {
            if (filterList.length === 0) {
                return true
            }

            if (disableAllFiltering) {
                return true
            }

            var type = sourceModel.data(row, "type")

            if (type === Sci.SciScrollbackModel.Request) {
                return true
            }

            var message = sourceModel.data(row, "message")

            try {
                var notificationItem = JSON.parse(message)["notification"]
            } catch(error) {
                return true
            }

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
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                width: 12
                policy: ScrollBar.AlwaysOn
                minimumSize: 0.1
                visible: scrollbackView.height < scrollbackView.contentHeight
            }

            onMovementStarted: {
                automaticScroll = false
            }

            delegate: Item {
                id: cmdDelegate
                width: ListView.view.width
                height: divider.y + divider.height

                property color helperTextColor: "#333333"
                property bool jsonIsValid

                Rectangle {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        bottom: divider.top
                    }
                    color: {
                        if (model.type === Sci.SciScrollbackModel.Request) {
                            return Qt.lighter(SGWidgets.SGColorsJS.STRATA_GREEN, 2.3)
                        } else if (cmdDelegate.jsonIsValid === false) {
                            return Qt.lighter(SGWidgets.SGColorsJS.ERROR_COLOR, 2.3)
                        }

                        return "transparent"
                    }
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
                            sourceComponent: model.type === Sci.SciScrollbackModel.Request ? resendButtonComponent : undefined
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
                                var item = scrollbackModel.setCondensed(sourceIndex, !model.condensed)
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

                    text: {
                        var prettyText = prettifyJson(model.message, model.condensed)
                        if (prettyText.length > 0) {
                            cmdDelegate.jsonIsValid = true
                            return prettyText
                        }

                        cmdDelegate.jsonIsValid = false
                        return model.message
                    }


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
            spacing: 10

            SGWidgets.SGIconButton {
                hintText: qsTr("Clear scrollback")
                icon.source: "qrc:/images/broom.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    scrollbackModel.clear()
                }
            }

            SGWidgets.SGIconButton {
                id: automaticScrollButton
                hintText: qsTr("Automatically scroll to the last message")
                icon.source: "qrc:/sgimages/arrow-list-bottom.svg"
                iconSize: toolButtonRow.iconHeight
                checkable: true
                onClicked: {
                    automaticScroll = !automaticScroll
                    if (automaticScroll) {
                        scrollbackView.positionViewAtEnd()
                    }
                }

                Binding {
                    target: automaticScrollButton
                    property: "checked"
                    value: automaticScroll
                }
            }

            SGWidgets.SGIconButton {
                hintText: scrollbackModel.condensedMode ? qsTr("Expand all commands") : qsTr("Collapse all commands")
                icon.source: scrollbackModel.condensedMode ? "qrc:/images/list-expand.svg" : "qrc:/images/list-collapse.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    scrollbackModel.condensedMode = ! scrollbackModel.condensedMode
                    scrollbackModel.setAllCondensed(scrollbackModel.condensedMode)
                }
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Filter")
                icon.source: "qrc:/sgimages/funnel.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    openFilterDialog()
                }
            }

            VerticalDivider {
                anchors.verticalCenter: parent.verticalCenter
            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Export to file")
                icon.source: "qrc:/sgimages/file-export.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    showFileExportDialog()
                }
            }

//            SGWidgets.SGIconButton {
//                hintText: qsTr("Program Device")
//                icon.source: "qrc:/sgimages/chip-flash.svg"
//                iconSize: toolButtonRow.iconHeight
//                onClicked: {
//                    programDeviceRequested()
//                }
//            }

            SGWidgets.SGIconButton {
                hintText: qsTr("Platform Info")
                icon.source: "qrc:/sgimages/info-circle.svg"
                iconSize: toolButtonRow.iconHeight
                onClicked: {
                    showPlatformInfoWindow("201", model.platform.verboseName)
                }
                //hiden until remote db is ready
                visible: false
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

        SGWidgets.SGTag {
            id: inputStatusTag
            anchors {
                top: toolButtonRow.bottom
                left: parent.left
                topMargin: 2
                margins: 6
            }

            text: model.platform.errorString
            verticalPadding: 1
            color: SGWidgets.SGColorsJS.TANGO_SCARLETRED1
            textColor: "white"
            font.bold: true
        }

        SGWidgets.SGTextField {
            id: cmdInput
            anchors {
                top: inputStatusTag.bottom
                left: parent.left
                right: btnSend.left
                topMargin: 2
                margins: 6
            }

            enabled: model.platform.status === Sci.SciPlatform.Ready
                     || model.platform.status === Sci.SciPlatform.NotRecognized

            focus: true
            font.family: StrataFonts.Fonts.inconsolata
            placeholderText: "Enter Command..."
            isValidAffectsBackground: true
            suggestionListModel: commandHistoryModel
            suggestionModelTextRole: "message"
            suggestionPosition: Item.Top
            suggestionEmptyModelText: qsTr("No commands.")
            suggestionHeaderText: qsTr("Command history")
            suggestionOpenWithAnyKey: false
            suggestionMaxHeight: 250
            suggestionCloseOnDown: true
            suggestionDelegateRemovable: true
            showCursorPosition: true

            onTextChanged: {
                model.platform.errorString = "";
            }

            Keys.onPressed: {
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

            onSuggestionDelegateRemoveRequested: {
                model.platform.removeCommandFromHistoryAt(index)
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

            enabled: cmdInput.enabled
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

    function sendTextInputTextAsComand() {
        var result = model.platform.sendMessage(cmdInput.text)
        if (result) {
            cmdInput.clear()
        }
    }

    function showFileExportDialog() {
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(platformDelegate, fileDialogComponent)
        dialog.accepted.connect(function() {
            var result = model.platform.exportScrollback(CommonCpp.SGUtilsCpp.urlToLocalFile(dialog.fileUrl))
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
            return ""
        }

        if (condensed) {
            return JSON.stringify(messageObj)
        }

        return JSON.stringify(messageObj, undefined, 4)
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
