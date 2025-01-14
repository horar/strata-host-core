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
import tech.strata.sgwidgets 1.0 as SGWidgets
import QtQuick.Dialogs 1.3
import tech.strata.logger 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.sci 1.0 as Sci
import tech.strata.theme 1.0

FocusScope {
    id: platformDelegate

    property variant rootItem
    property QtObject scrollbackModel
    property QtObject filterScrollbackModel
    property QtObject searchScrollbackModel
    property QtObject commandHistoryModel
    property QtObject filterSuggestionModel
    property color tabBorderColor

    property bool filteringIsActive: filterScrollbackModel.filterList.length > 0 && filterScrollbackModel.disableAllFiltering === false
    property bool automaticScroll: true
    property bool scrollbackLimitReached: scrollbackModel.count >= sciModel.platformModel.maxScrollbackCount

    property bool hexViewShown: false

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

            property int maximumInputAreaHeight: height - 2*searchAreaHeight
            property int minimumInputAreaHeight: 100
            property int searchAreaHeight: 200

            onMaximumInputAreaHeightChanged: {
                messageEditor.height = Math.min(maximumInputAreaHeight, messageEditor.height)
            }

            property var keyboardActions: {
                "clear_scrollback": {"sequence": "Ctrl+D", "action": "clearScrollback", "hint":"Clear scrollback"},
                "toggle_expand": {"sequence": "Ctrl+E", "action": "toggleExpand", "hint":"Toggle Expand"},
                "toggle_follow": {"sequence": "Ctrl+F", "action": "toggleFollow", "hint":"Auto scroll down when new message arrives"},
                "send_message_ent": {"sequence": "Ctrl+Enter", "action": "sendMessages", "hint":"Send message(s)"},
                "send_message_ret": {"sequence": "Ctrl+Return", "action": "sendMessages", "hint":"Send message(s)"},
            }

            Connections {
                target: model.platform
                onSendMessageResultReceived: {
                    sendMessageResultHandler(error)
                }

                onSendQueueFinished: {
                    sendMessageResultHandler(error)
                }
            }

            Keys.onPressed: {
                var key = event.key + event.modifiers

                if (tryKeyboardAction("clear_scrollback", key)) {
                } else if (tryKeyboardAction("toggle_expand", key)) {
                } else if (tryKeyboardAction("toggle_follow", key)) {
                } else if (tryKeyboardAction("send_message_ent", key)) {
                } else if (tryKeyboardAction("send_message_ret", key)) {
                } else {
                    return
                }

                event.accepted = true
            }

            Item {
                id: hexViewWrapper
                width: platformDelegate.hexViewShown ? hexView.width + 4 : 0
                anchors {
                    top: parent.top
                    bottom: searchViewWrapper.bottom
                    right: parent.right
                    rightMargin: 6
                }

                clip: true

                Behavior on width { NumberAnimation {}}

                SGWidgets.SGText {
                    id: hexViewTitle
                    anchors {
                        top: parent.top
                        left: hexView.left
                    }

                    text: "Raw Message"
                }

                HexView {
                    id: hexView
                    anchors {
                        top: hexViewTitle.bottom
                        bottom: parent.bottom
                        right: parent.right
                    }

                    property string nextContent: ""
                    onNextContentChanged: {
                        changeContentTimer.start()
                    }

                    Timer {
                        id: changeContentTimer
                        interval: 500
                        triggeredOnStart: true
                        onTriggered: {
                            hexView.content = hexView.nextContent
                        }
                    }

                    Binding {
                        target: hexView
                        property: "nextContent"
                        when: platformDelegate.hexViewShown
                        value: {
                            if (platformDelegate.filterScrollbackModel.count === 0 || scrollbackView.currentIndex < 0) {
                                return ""
                            }
                            let sourceIndex = platformDelegate.filterScrollbackModel.mapIndexToSource(scrollbackView.currentIndex)
                            if (sourceIndex < 0) {
                                return ""
                            }

                            let selectedMsg = platformDelegate.scrollbackModel.data(sourceIndex, "rawMessage")
                            if (selectedMsg === undefined) {
                                return ""
                            } else {
                                return selectedMsg
                            }
                        }
                    }
                }
            }

            ScrollbackView {
                id: scrollbackView
                anchors {
                    top: parent.top
                    bottom: searchViewWrapper.top
                    bottomMargin: searchViewWrapper.shown ? 6 : 0
                    left: parent.left
                    leftMargin: 6
                    right: hexViewWrapper.left
                }

                model: platformDelegate.filterScrollbackModel
                timestampFormat: platformDelegate.scrollbackModel.timestampFormat
                automaticScroll: platformDelegate.automaticScroll

                onResendMessageRequested: {
                    messageEditor.text = message;
                }

                onCondenseMessageRequested: {
                    var sourceIndex = scrollbackView.model.mapIndexToSource(index)
                    if (sourceIndex < 0) {
                        console.error(Logger.sciCategory, "Index out of range.")
                        return
                    }

                    platformDelegate.scrollbackModel.setIsCondensed(sourceIndex, isCondensed)
                }
            }

            Item {
                id: searchViewWrapper
                height: shown ? mainPage.searchAreaHeight : 0
                anchors {
                    bottom: inputWrapper.top
                    bottomMargin: 6
                    left: parent.left
                    leftMargin: 6
                    right: scrollbackView.right
                }

                clip: true

                property bool shown: searchInput.text.length

                Behavior on height { NumberAnimation {} }

                SGWidgets.SGText {
                    id: searchViewTitle
                    anchors {
                        top: parent.top
                        left: searchScrollbackView.left
                    }

                    text: "Search Results: " + searchScrollbackView.count.toString()
                }

                ScrollbackView {
                    id: searchScrollbackView
                    width: parent.width
                    anchors {
                        top: searchViewTitle.bottom
                        bottom: parent.bottom
                    }

                    model: platformDelegate.searchScrollbackModel
                    timestampFormat: platformDelegate.scrollbackModel.timestampFormat
                    automaticScroll: false
                    allowOnlyCondensedMode: true
                    allowResendButton: false
                    allowSyntaxHighlight: false
                    allowMouseSelection: false
                    allowCopyMenu: false
                    allowSearchHighlight: true

                    onDelegateEnterPressed: positionScrollbackViewAtEnd(index)
                    onDelegateClicked: positionScrollbackViewAtEnd(index)

                    function positionScrollbackViewAtEnd(index) {
                        var srcIndex = platformDelegate.searchScrollbackModel.mapIndexToSource(index);
                        var dstIndex = platformDelegate.filterScrollbackModel.mapIndexFromSource(srcIndex)

                        if (dstIndex < 0) {
                            console.warn(Logger.sciCategory, "Could not map index", index, "->", srcIndex, "->", dstIndex)
                            return
                        }

                        scrollbackView.positionViewAtIndex(dstIndex)
                    }
                }
            }

            FocusScope {
                id: inputWrapper
                height: leftButtonRow.y + leftButtonRow.height + 6
                anchors {
                    bottom: statusBar.top
                    bottomMargin: 2
                    left: parent.left
                    leftMargin: 6
                    right: parent.right
                    rightMargin: 6
                }

                focus: true

                Row {
                    id: toolButtonRow
                    anchors {
                        top: parent.top
                        topMargin: handle.height + 4
                        left: messageEditor.left
                    }

                    property int iconHeight: tabBar.statusLightHeight
                    spacing: 10

                    SGWidgets.SGIconButton {
                        text: "Clear"
                        hintText: mainPage.resolveKeyboardActionHintText("clear_scrollback")
                        icon.source: "qrc:/sgimages/broom.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: mainPage.clearScrollback()
                    }

                    SGWidgets.SGIconButton {
                        id: automaticScrollButton
                        text: "Follow"
                        hintText: mainPage.resolveKeyboardActionHintText("toggle_follow")
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

                            return mainPage.resolveKeyboardActionHintText("toggle_expand", t)
                        }
                        icon.source: scrollbackModel.condensedMode ? "qrc:/images/list-expand.svg" : "qrc:/images/list-collapse.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: mainPage.toggleExpand()
                    }

                    VerticalDivider {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SGWidgets.SGIconButton {
                        text: "Filter"
                        hintText: qsTr("Filter out messages")
                        icon.source: "qrc:/sgimages/funnel.svg"
                        iconSize: toolButtonRow.iconHeight
                        showActiveFlag: platformDelegate.filteringIsActive
                        onClicked: showFilterView()
                    }

                    SGWidgets.SGIconButton {
                        id: hexViewButton
                        text: qsTr("Hex")
                        hintText: "Raw message in hex viewer"
                        icon.source: "qrc:/images/hex-view.svg"
                        iconSize: toolButtonRow.iconHeight
                        checkable: true
                        onClicked: {
                            platformDelegate.hexViewShown = !platformDelegate.hexViewShown
                        }

                        Binding {
                            target: hexViewButton
                            property: "checked"
                            value: platformDelegate.hexViewShown
                        }
                    }

                    SGWidgets.SGIconButton {
                        text: "Export"
                        hintText: qsTr("Export to file")
                        icon.source: "qrc:/sgimages/file-export.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: showExportView()
                        showActiveFlag: model.platform.scrollbackModel.autoExportIsActive && showErrorFlag === false
                        showErrorFlag: model.platform.scrollbackModel.autoExportErrorString.length > 0
                    }

                    VerticalDivider {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SGWidgets.SGIconButton {
                        text: "Program"
                        hintText: qsTr("Program device with new firmware")
                        icon.source: "qrc:/sgimages/chip-flash.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: showProgramView()
                    }

                    SGWidgets.SGIconButton {
                        text: "Save"
                        hintText: qsTr("Save device firmware into file")
                        icon.source: "qrc:/images/chip-download.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: showSaveFirmwareView()
                    }

                    SGWidgets.SGIconButton {
                        text: "Validator"
                        hintText: qsTr("Validate platform interface")
                        icon.source: "qrc:/images/list-check.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: showValidationView()
                    }

                    VerticalDivider {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    SGWidgets.SGIconButton {
                        text: "Queue"
                        hintText: qsTr("Manage message queue")
                        icon.source: "qrc:/sgimages/queue.svg"
                        iconSize: toolButtonRow.iconHeight
                        onClicked: showMessageQueueView()
                    }

                    VerticalDivider {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: mockSettingsButton.visible
                    }

                    SGWidgets.SGIconButton {
                        id: mockSettingsButton
                        text: "Mock Settings"
                        hintText: qsTr("Modify Mock Device settings")
                        icon.source: "qrc:/sgimages/tools.svg"
                        iconSize: toolButtonRow.iconHeight
                        visible: (model.platform.deviceType === Sci.SciPlatform.MockDevice)
                        onClicked: showMockSettingsView()
                    }
                }

                Item {
                    id: handle
                    width: handleColumn.width
                    height: handleColumn.height
                    anchors {
                        top: inputWrapper.top
                        topMargin: 2
                        horizontalCenter: inputWrapper.horizontalCenter
                    }

                    Column {
                        id: handleColumn

                        spacing: 2
                        anchors.centerIn: parent

                        Rectangle {
                            id: topLine
                            width: 30
                            height: 1
                            color: handleMouseArea.pressed ? TangoTheme.palette.highlight : Qt.rgba(0,0,0,0.5)
                        }

                        Rectangle {
                            width: topLine.width
                            height: topLine.height
                            color: topLine.color
                        }
                    }

                    MouseArea {
                        id: handleMouseArea
                        anchors {
                            fill: parent
                            margins: -2
                        }

                        cursorShape: Qt.SplitVCursor
                        acceptedButtons: Qt.LeftButton

                        property int pressStartedY: 0

                        onPressed: {
                            pressStartedY = mouse.y
                        }

                        onMouseYChanged: {
                            var newHeight = messageEditor.height + pressStartedY - mouse.y
                            if (newHeight > maximumInputAreaHeight) {
                                newHeight = maximumInputAreaHeight
                            }

                            if (newHeight < minimumInputAreaHeight) {
                                newHeight = minimumInputAreaHeight
                            }

                            messageEditor.height = newHeight
                        }
                    }
                }

                SGWidgets.SGTextField {
                    id: searchInput
                    anchors {
                        top: inputWrapper.top
                        right: parent.right
                    }

                    focus: false
                    placeholderText: "Search..."
                    leftIconSource: "qrc:/sgimages/zoom.svg"
                    showClearButton: true
                    onTextChanged: {
                        platformDelegate.searchScrollbackModel.searchPattern = text
                        searchScrollbackView.searchHighlightPattern = text
                    }
                }

                SGWidgets.SGTag {
                    id: inputStatusTag
                    anchors {
                        top: toolButtonRow.bottom
                        left: parent.left
                        topMargin: 2
                    }

                    text: model.platform.errorString
                    verticalPadding: 1
                    color: TangoTheme.palette.scarletRed1
                    textColor: "white"
                    font.bold: true
                    mask: "A"
                    sizeByMask: text.length === 0
                }

                MessageEditor {
                    id: messageEditor
                    height: 160
                    anchors {
                        top: inputStatusTag.bottom
                        left: parent.left
                        right: btnSend.left
                        topMargin: 2
                        rightMargin: 6
                    }

                    enabled: model.platform.sendMessageInProgress === false
                             && model.platform.sendQueueInProgress === false
                             && (model.platform.status === Sci.SciPlatform.Ready
                             || model.platform.status === Sci.SciPlatform.NotRecognized)

                    focus: true

                    suggestionListModel: commandHistoryModel
                    suggestionModelTextRole: "message"
                    suggestionParent: messageHistoryButton

                    onTextChanged: {
                        model.platform.errorString = "";
                    }
                }

                Row {
                    id: rightInfoRow
                    anchors {
                        top: messageEditor.bottom
                        topMargin: 2
                        right: messageEditor.right
                    }

                    spacing: 4

                    SGWidgets.SGTag {
                        visible: messageEditor.lineCount >= Sci.Settings.maxInputLines
                        text: "Line limit reached"
                        color: TangoTheme.palette.warning
                        textColor: "white"
                        horizontalPadding: 2
                        verticalPadding: 2
                        font: positionTag.font
                    }

                    SGWidgets.SGTag {
                        id: positionTag

                        text: "Line: " + (messageEditor.currentLine + 1) + ", Col: " + (messageEditor.currentColumn + 1)
                        color: "#b2b2b2"
                        textColor: "white"
                        horizontalPadding: 2
                        verticalPadding: 2
                        font.family: messageEditor.font.family
                        font.pixelSize: messageEditor.font.pixelSize
                        font.bold: true
                    }
                }

                Row {
                    id: leftButtonRow
                    anchors {
                        top: messageEditor.bottom
                        topMargin: 2
                        left: messageEditor.left
                    }

                    spacing: 6

                    SGWidgets.SGIconButton {
                        anchors.verticalCenter: parent.verticalCenter
                        hintText: "Clear input"
                        icon.source: "qrc:/sgimages/broom.svg"
                        onClicked: {
                            messageEditor.forceActiveFocus()
                            messageEditor.clear()
                        }
                    }

                    SGWidgets.SGIconButton {
                        id: messageHistoryButton
                        anchors.verticalCenter: parent.verticalCenter
                        hintText: "Message history"
                        icon.source: "qrc:/sgimages/history.svg"

                        onClicked: {
                            messageEditor.forceActiveFocus()

                            if (messageEditor.suggestionOpened) {
                                messageEditor.closeSuggestionPopup()
                            } else {
                                messageEditor.openSuggestionPopup()
                            }
                        }
                    }
                }

                SGWidgets.SGCheckBox {
                    id: validateCheckBox
                    anchors {
                        left: leftButtonRow.right
                        leftMargin: 2*leftButtonRow.spacing
                        verticalCenter: leftButtonRow.verticalCenter
                    }

                    focusPolicy: Qt.NoFocus
                    padding: 0
                    checked: true
                    text: "Send only valid JSON message"
                }

                SGWidgets.SGButton {
                    id: btnSend
                    anchors {
                        top: messageEditor.top
                        right: parent.right
                    }

                    enabled: messageEditor.enabled
                    focusPolicy: Qt.NoFocus
                    hintText: {
                        if (Qt.platform.os === "osx") {
                            return mainPage.resolveKeyboardActionHintText("send_message_ret")
                        }
                        return mainPage.resolveKeyboardActionHintText("send_message_ent")
                    }
                    text: qsTr("SEND")
                    minimumContentWidth: btnAddToQueue.preferredContentWidth
                    onClicked: {
                        sendMessages()
                    }

                    SGWidgets.SGTag {
                        anchors {
                            right: parent.right
                            rightMargin: -4
                            top: parent.top
                            topMargin: -4
                        }

                        color: TangoTheme.palette.chameleon2
                        fontSizeMultiplier: 0.9
                        text: "+" + model.platform.messageQueueModel.count
                        textColor: "white"
                        font.bold: true
                        visible: model.platform.messageQueueModel.count > 0
                    }
                }

                SGWidgets.SGButton {
                    id: btnAddToQueue
                    anchors {
                        top: btnSend.bottom
                        topMargin: 6
                        right: parent.right
                    }

                    enabled: messageEditor.enabled
                    text: "TO QUEUE"
                    hintText: "Add message to queue"

                    onClicked: {
                        queueMessageInputTextAsComand()
                    }
                }
            }

            Item {
                id: statusBar
                height: statusBarRow.y + statusBarRow.height + 2
                anchors {
                    bottom: parent.bottom
                    right: parent.right
                    left: parent.left
                    leftMargin: 6
                    rightMargin: 6
                }

                Rectangle {
                    id: statusBarDivider
                    anchors.top: parent.top
                    width: parent.width
                    height: 1
                    color: tabBorderColor
                }

                Row {
                    id: statusBarRow
                    anchors {
                        top: statusBarDivider.bottom
                        topMargin: 2
                        right: parent.right
                        rightMargin: 4
                    }

                    spacing: 8

                    SGWidgets.SGTag {
                        id: filterCountTag
                        font.family: "monospace"
                        visible: platformDelegate.filteringIsActive
                        text: "Filtered: " + (scrollbackModel.count - scrollbackView.count).toString()
                        color: "transparent"
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        height: Math.floor(filterCountTag.height - 6)
                        width: 1

                        visible: filterCountTag.visible
                        color: tabBorderColor
                    }

                    SGWidgets.SGTag {
                        font.family: "monospace"
                        text: "Messages: " + scrollbackModel.count + " / " + sciModel.platformModel.maxScrollbackCount
                        color: {
                            if (platformDelegate.scrollbackLimitReached) {
                                return TangoTheme.palette.warning
                            }

                            return "transparent"
                        }

                        textColor: {
                            if (platformDelegate.scrollbackLimitReached) {
                                return "white"
                            }

                            return "black"
                        }
                    }

                    Item {
                        id: messageRxIndicator
                        anchors.verticalCenter: parent.verticalCenter
                        height: filterCountTag.height - 8
                        width: height

                        Rectangle {
                            id: messageRxFill
                            anchors.fill: parent
                            radius: height/2
                            color: TangoTheme.palette.chameleon2
                            opacity: 0
                        }

                        Rectangle {
                            anchors.fill: parent
                            border.width: 1
                            border.color: tabBorderColor
                            radius: height/2
                            color: "transparent"
                        }

                        Connections {
                            target: model.platform
                            onMessageReceived: {
                                messageRxAnimation.restart();
                            }
                        }

                        SequentialAnimation {
                            id: messageRxAnimation

                            PropertyAction {
                                target: messageRxFill
                                property: "opacity"
                                value: 0
                            }

                            PauseAnimation {
                                duration: 10
                            }

                            PropertyAction {
                                target: messageRxFill
                                property: "opacity"
                                value: 1
                            }

                            PauseAnimation {
                                duration: 100
                            }

                            PropertyAction {
                                target: messageRxFill
                                property: "opacity"
                                value: 0
                            }
                        }
                    }
                }
            }

            //to show proper cursor when dragging
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SplitVCursor
                acceptedButtons: Qt.NoButton
                visible: handleMouseArea.pressed
            }

            function sendMessages() {
                if (model.platform.messageQueueModel.count > 0) {
                    if (messageEditor.text.length > 0) {
                        queueMessageInputTextAsComand()
                        if (model.platform.errorString.length > 0) {
                            return
                        }
                    }

                    model.platform.sendQueue()
                } else {
                    sendMessageInputTextAsComand()
                }
            }

            function sendMessageInputTextAsComand() {
                if (messageEditor.enabled === false) {
                    return
                }

                model.platform.sendMessage(messageEditor.text, validateCheckBox.checked)
            }

            function queueMessageInputTextAsComand() {
                if (messageEditor.enabled === false) {
                    return
                }

                var result = model.platform.queueMessage(messageEditor.text, validateCheckBox.checked)
                sendMessageResultHandler(result)
            }

            function sendMessageResultHandler(error) {
                if (error.error_code === Sci.SciPlatform.NoError) {
                    model.platform.errorString = ""
                    messageEditor.clear()
                } else if (error.error_code === Sci.SciPlatform.NotConnectedError) {
                    model.platform.errorString = "Device not connected"
                } else if (error.error_code === Sci.SciPlatform.JsonError) {
                    var pos = messageEditor.resolveCoordinates(error.offset, messageEditor.text)
                    model.platform.errorString = "JSON error at " + (pos.line+1) + ":" + (pos.column+1) + " - " + error.error_string;
                } else if (error.error_code === Sci.SciPlatform.PlatformError) {
                    model.platform.errorString = data.error_string
                } else if (error.error_code === Sci.SciPlatform.QueueError) {
                    model.platform.errorString = "Queue Limit Exceeded"
                } else {
                    model.platform.errorString = "Unknown error"
                    console.error("unknown message send error", JSON.stringify(error))
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

                scrollbackView.clearSelection()

                toggleExpandButton.enabled = false
                scrollbackModel.condensedMode = ! scrollbackModel.condensedMode
                scrollbackModel.setIsCondensedAll(scrollbackModel.condensedMode)
                toggleExpandButton.enabled = true
            }

            function tryKeyboardAction(actionName, key) {
                if (keyboardActionMatches(actionName, key)) {
                    var action = keyboardActions[actionName].action
                    mainPage[action]()
                    return true
                }

                return false
            }

            function keyboardActionMatches(actionName, key) {
                var sequence = keyboardActions[actionName].sequence
                return CommonCpp.SGUtilsCpp.keySequenceMatches(sequence, key)
            }

            function resolveKeyboardActionHintText(actionName, customHintText) {
                var nativeSequence = CommonCpp.SGUtilsCpp.keySequenceNativeText(keyboardActions[actionName].sequence)

                if (customHintText === undefined) {
                    var hint = keyboardActions[actionName].hint
                } else {
                    hint = customHintText
                }

                return prettifyHintText(hint, nativeSequence)
            }
        }
    }

    Component {
        id: programDeviceComponent

        ProgramDeviceView {
        }
    }

    Component {
        id: saveFirmwareComponent

        SaveFirmwareView {
        }
    }

    Component {
        id: exportComponent

        ExportView {
        }
    }

    Component {
        id: filterComponent

        FilterView {
            id: filterView
            disableAllFiltering: platformDelegate.filterScrollbackModel.disableAllFiltering
            filterSuggestionModel: platformDelegate.filterSuggestionModel
            filterList: platformDelegate.filterScrollbackModel.filterList

            onFilterDataChanged: {
                var filterList = filterView.getFilterData()
                console.log(Logger.sciCategory, "filters:", JSON.stringify(filterList))
                console.log(Logger.sciCategory, "disableAllFiltering", filterView.disableAllFiltering)

                platformDelegate.filterScrollbackModel.invalidateFilter(filterList, filterView.disableAllFiltering)
            }
        }
    }

    Component {
        id: mockSettingsComponent

        MockSettingsView {
        }
    }

    Component {
        id: messageQueueComponent

        MessageQueueView {
            messageQueueModel: model.platform.messageQueueModel
        }
    }

    Component {
        id: validationComponent

        ValidationView {
        }
    }

    function showProgramView() {
        stackView.push(programDeviceComponent)
    }

    function showSaveFirmwareView() {
        stackView.push(saveFirmwareComponent)
    }

    function showExportView() {
        stackView.push(exportComponent)
    }

    function showMockSettingsView() {
        stackView.push(mockSettingsComponent)
    }

    function showFilterView() {
        stackView.push(filterComponent)
    }

    function showMessageQueueView() {
        stackView.push(messageQueueComponent)
    }

    function showValidationView() {
        stackView.push(validationComponent)
    }

    function prettifyHintText(hintText, shortcut) {
        return hintText + " - " + shortcut
    }
}
