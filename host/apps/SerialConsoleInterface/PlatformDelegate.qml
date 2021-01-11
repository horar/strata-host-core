import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import QtQuick.Dialogs 1.3
import tech.strata.logger 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.sci 1.0 as Sci
import tech.strata.theme 1.0

FocusScope {
    id: platformDelegate

    property variant rootItem
    property variant scrollbackModel
    property variant commandHistoryModel

    property bool disableAllFiltering: false
    property var filterList: []
    property bool automaticScroll: true

    StackView {
        id: stackView
        anchors.fill: parent

        focus: true
        initialItem: mainPageComponent
        pushEnter: null
        pushExit: null
        popEnter: null
        popExit: null
    }

    Component {
        id: mainPageComponent

        FocusScope {
            id: mainPage

            Shortcut {
                id: clearShortcut
                sequence: "Ctrl+D"
                onActivated: mainPage.clearScrollback()
            }

            Shortcut {
                id: followShortcut
                sequence: "Ctrl+F"
                onActivated: mainPage.toggleFollow()
            }

            Shortcut {
                id: expandShortcut
                sequence: "Ctrl+E"
                onActivated: mainPage.toggleExpand()
            }

            ScrollbackView {
                id: scrollbackView
                anchors {
                    top: parent.top
                    bottom: inputWrapper.top
                    bottomMargin: 2
                    left: parent.left
                    right: parent.right
                }

                model: platformDelegate.scrollbackModel
                automaticScroll: platformDelegate.automaticScroll
                disableAllFiltering: platformDelegate.disableAllFiltering
                filterList: platformDelegate.filterList

                onResendMessageRequested: {
                    textAreaInput.text = message;
                }
            }

            FocusScope {
                id: inputWrapper
                height: validateCheckBox.y + validateCheckBox.height + 6
                anchors {
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                }

                focus: true

                Row {
                    id: toolButtonRow
                    anchors {
                        top: parent.top
                        topMargin: 2
                        left: cmdInput.left
                    }

                    property int iconHeight: tabBar.statusLightHeight
                    spacing: 10

                    SGWidgets.SGIconButton {
                        text: "Clear"
                        hintText: prettifyHintText("Clear scrollback", clearShortcut.nativeText)
                        icon.source: "qrc:/sgimages/broom.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: mainPage.clearScrollback()
                    }

                    SGWidgets.SGIconButton {
                        id: automaticScrollButton
                        text: "Follow"
                        hintText: prettifyHintText("Auto scroll down when new message arrives", followShortcut.nativeText)
                        icon.source: "qrc:/sgimages/arrow-list-bottom.svg"
                        iconSize: toolButtonRow.iconHeight
                        checkable: true
                        onClicked: mainPage.toggleFollow()

                        Binding {
                            target: automaticScrollButton
                            property: "checked"
                            value: automaticScroll
                        }
                    }

                    SGWidgets.SGIconButton {
                        id: toggleExpandButton
                        text: scrollbackModel.condensedMode ? "Expand" : "Collapse"
                        minimumWidthText: "Collapse"
                        hintText: {
                            if (scrollbackModel.condensedMode) {
                                var t = qsTr("Expand all commands")
                            } else {
                                t = qsTr("Collapse all commands")
                            }

                            return prettifyHintText(t, expandShortcut.nativeText)
                        }
                        icon.source: scrollbackModel.condensedMode ? "qrc:/images/list-expand.svg" : "qrc:/images/list-collapse.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: mainPage.toggleExpand()
                    }

                    SGWidgets.SGIconButton {
                        text: "Filter"
                        hintText: qsTr("Filter messages")
                        icon.source: "qrc:/sgimages/funnel.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: openFilterDialog()
                    }

                    VerticalDivider {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SGWidgets.SGIconButton {
                        text: "Export"
                        hintText: qsTr("Export to file")
                        icon.source: "qrc:/sgimages/file-export.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: showExportView()
                    }

                    SGWidgets.SGIconButton {
                        text: "Program"
                        hintText: qsTr("Program device with new firmware")
                        icon.source: "qrc:/sgimages/chip-flash.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: showProgramView()
                    }

                    SGWidgets.SGIconButton {
                        hintText: qsTr("Platform info")
                        icon.source: "qrc:/sgimages/info-circle.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: {
                            showPlatformInfoWindow("201", model.platform.verboseName)
                        }
                        //hiden until remote db is ready
                        visible: false
                    }
                }

                Column {
                    anchors {
                        top: toolButtonRow.top
                        right: parent.right
                        rightMargin: 6
                    }

                    spacing: 4

                    SGWidgets.SGTag {
                        anchors.right: parent.right
                        sizeByMask: true
                        mask: "Filtered: " + "9".repeat(filteredCount.toString().length)
                        text: "Filtered: " + filteredCount
                        font.bold: true
                        visible: filteredCount > 0

                        property int filteredCount: scrollbackModel.count - scrollbackView.count
                    }

                    SGWidgets.SGTag {
                        anchors.right: parent.right
                        text: {
                            if (model.platform.scrollbackModel.autoExportErrorString.length > 0) {
                                return "EXPORT FAILED"
                            } else if (model.platform.scrollbackModel.autoExportIsActive) {
                                return "Export"
                            }

                            return ""
                        }

                        font.bold: true
                        textColor: "white"
                        color: {
                            if (model.platform.scrollbackModel.autoExportErrorString.length > 0) {
                                return TangoTheme.palette.error
                            }

                            return TangoTheme.palette.plum1
                        }
                    }
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
                    color: TangoTheme.palette.scarletRed1
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
                    font.family: "monospace"
                    placeholderText: "Enter Message..."
                    isValidAffectsBackground: true
                    suggestionListModel: commandHistoryModel
                    suggestionModelTextRole: "message"
                    suggestionPosition: Item.Top
                    suggestionEmptyModelText: qsTr("No commands.")
                    suggestionHeaderText: qsTr("Message history")
                    suggestionOpenWithAnyKey: false
                    suggestionMaxHeight: 250
                    suggestionCloseOnDown: true
                    suggestionDelegateRemovable: true
                    showCursorPosition: true
                    showClearButton: true
                    suggestionDelegateTextWrap: true

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
                        model.platform.commandHistoryModel.removeAt(index)
                    }

                    suggestionListDelegate: Item {
                        width: ListView.view.width
                        height: textEdit.paintedHeight + 10

                        Loader {
                            id: suggestionListHighlighterLoader
                            sourceComponent: model.isJsonValid ? suggestionListHighlighterComponent : null
                        }

                        Component {
                            id: suggestionListHighlighterComponent
                            CommonCpp.SGJsonSyntaxHighlighter {
                                textDocument: textEdit.textDocument
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: {
                                if (parent.ListView.isCurrentItem) {
                                    return Qt.lighter(cmdInput.palette.highlight, 1.7)
                                } else if (delegateMouseArea.containsMouse || removeBtn.hovered) {
                                    return Qt.lighter(cmdInput.palette.highlight, 1.9)
                                }

                                return "transparent"
                            }
                        }

                        SGWidgets.SGTextEdit {
                            id: textEdit
                            anchors {
                                verticalCenter: parent.verticalCenter
                                left: parent.left
                                leftMargin: 4
                                right: removeBtn.left
                                rightMargin: 4
                            }

                            textFormat: Text.PlainText
                            readOnly: true
                            wrapMode: Text.WrapAnywhere
                            text: model.message
                        }

                        MouseArea {
                            id: delegateMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                parent.ListView.view.currentIndex = index
                                cmdInput.suggestionDelegateSelected(index)
                            }
                        }

                        SGWidgets.SGIconButton {
                            id: removeBtn
                            anchors {
                                verticalCenter: parent.verticalCenter
                                right: parent.right
                                rightMargin: 2 + 8
                            }

                            iconSize: SGWidgets.SGSettings.fontPixelSize
                            hintText: qsTr("Remove")
                            visible: delegateMouseArea.containsMouse
                                     || removeBtn.hovered
                                     || parent.ListView.isCurrentItem

                            iconColor: "white"
                            icon.source: "qrc:/sgimages/times.svg"
                            highlightImplicitColor: Theme.palette.error
                            onClicked: {
                                cmdInput.suggestionDelegateRemoveRequested(index)
                            }
                        }
                    }
                }

                SGWidgets.SGCheckBox {
                    id: validateCheckBox
                    anchors {
                        top: cmdInput.bottom
                        topMargin: 2
                        left: cmdInput.left
                    }

                    focusPolicy: Qt.NoFocus
                    padding: 0
                    checked: true
                    text: "Send only valid JSON message"
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

            function sendTextInputTextAsComand() {
                var result = model.platform.sendMessage(cmdInput.text, validateCheckBox.checked)
                if (result) {
                    cmdInput.clear()
                }
            }

            function clearScrollback() {
                scrollbackModel.clear()
            }

            function toggleFollow() {
                automaticScroll = !automaticScroll
                if (automaticScroll) {
                    scrollbackView.positionViewAtEnd()
                }
            }

            function toggleExpand() {
                if (toggleExpandButton.enabled === false) {
                    return
                }

                toggleExpandButton.enabled = false
                scrollbackModel.condensedMode = ! scrollbackModel.condensedMode
                scrollbackModel.setIsCondensedAll(scrollbackModel.condensedMode)
                toggleExpandButton.enabled = true
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

                    scrollbackView.invalidateFilter()
                })

                dialog.open()
            }
        }
    }

    Component {
        id: programDeviceComponent

        ProgramDeviceView {
        }
    }

    Component {
        id: exportComponent

        ExportView {
        }
    }

    function showProgramView() {
        stackView.push(programDeviceComponent)
    }

    function showExportView() {
        stackView.push(exportComponent)
    }

    function prettifyHintText(hintText, shortcut) {
        return hintText + " - " + shortcut
    }
}
