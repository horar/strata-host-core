import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
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

                    onContentYChanged: {
                        automaticScroll = scrollbackView.atYEnd
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
                            color: {
                                if (model.type === Sci.SciScrollbackModel.Request) {
                                    return Qt.lighter(SGWidgets.SGColorsJS.STRATA_GREEN, 2.3)
                                } else if (model.isJsonValid === false) {
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

                            font.family: "monospace"
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
                                    icon.source: model.isCondensed ? "qrc:/sgimages/chevron-right.svg" : "qrc:/sgimages/chevron-down.svg"
                                    iconSize: buttonRow.iconSize

                                    onClicked: {
                                        var sourceIndex = scrollbackFilterModel.mapIndexToSource(index)
                                        var item = scrollbackModel.setIsCondensed(sourceIndex, !model.isCondensed)
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

                            font.family: "monospace"
                            wrapMode: Text.WrapAnywhere
                            selectByKeyboard: true
                            selectByMouse: true
                            readOnly: true

                            text: {
                                if (model.isCondensed === false && model.isJsonValid) {
                                    return CommonCpp.SGUtilsCpp.prettifyJson(model.message)
                                }

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

            FocusScope {
                id: inputWrapper
                height: cmdInput.y + cmdInput.height + 6
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

                        property int filteredCount: scrollbackModel.count - scrollbackFilterModel.count
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
                                return SGWidgets.SGColorsJS.ERROR_COLOR
                            }

                            return SGWidgets.SGColorsJS.TANGO_PLUM1
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
                    font.family: "monospace"
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
                        model.platform.commandHistoryModel.removeAt(index)
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

            function sendTextInputTextAsComand() {
                var result = model.platform.sendMessage(cmdInput.text)
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
                scrollbackModel.condensedMode = ! scrollbackModel.condensedMode
                scrollbackModel.setAllCondensed(scrollbackModel.condensedMode)
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
