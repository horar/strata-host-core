/*
 * Copyright (c) 2018-2021 onsemi.
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
    property variant scrollbackModel
    property variant commandHistoryModel
    property variant filterSuggestionModel
    property color tabBorderColor

    property bool disableAllFiltering: false
    property var filterList: []
    property bool filteringIsActive: filterList.length > 0 && disableAllFiltering == false
    property bool automaticScroll: true
    property bool scrollbackLimitReached: scrollbackModel.count >= sciModel.platformModel.maxScrollbackCount

    property bool hexViewShown: false

    signal invalidateScrollbackFilterRequested()

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

            property int maximumInputAreaHeight: Math.floor(height/2)
            property int minimumInputAreaHeight: 100

            onMaximumInputAreaHeightChanged: {
                messageEditor.height = Math.min(maximumInputAreaHeight, messageEditor.height)
            }

            property var keyboardActions: {
                "clear_scrollback": {"sequence": "Ctrl+D", "action": "clearScrollback", "hint":"Clear scrollback"},
                "toggle_expand": {"sequence": "Ctrl+E", "action": "toggleExpand", "hint":"Toggle Expand"},
                "toggle_follow": {"sequence": "Ctrl+F", "action": "toggleFollow", "hint":"Auto scroll down when new message arrives"},
                "send_message_ent": {"sequence": "Ctrl+Enter", "action": "sendMessageInputTextAsComand", "hint":"Send message"},
                "send_message_ret": {"sequence": "Ctrl+Return", "action": "sendMessageInputTextAsComand", "hint":"Send message"},
            }

            Connections {
                target: model.platform
                onSendMessageResultReceived: {
                    messageEditor.messageSendInProgress = false
                    sendMessageResultHandler(type, data)
                }
            }

            Connections {
                target: platformDelegate
                onInvalidateScrollbackFilterRequested: {
                    scrollbackView.invalidateFilter()
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
                    bottom: scrollbackView.bottom
                    right: parent.right
                    rightMargin: 6
                }

                Behavior on width { NumberAnimation {}}

                HexView {
                    id: hexView
                    height: parent.height
                    anchors.right: parent.right

                    property var nextContent: ""
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
                            if (scrollbackView.currentIndex < 0 || scrollbackView.count === 0) {
                                return ""
                            }

                            var selectedMsg = platformDelegate.scrollbackModel.data(scrollbackView.currentIndex, "rawMessage")
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
                    bottom: inputWrapper.top
                    bottomMargin: 2
                    left: parent.left
                    leftMargin: 6
                    right: hexViewWrapper.left
                }

                model: platformDelegate.scrollbackModel
                automaticScroll: platformDelegate.automaticScroll
                disableAllFiltering: platformDelegate.disableAllFiltering
                filterList: platformDelegate.filterList

                onResendMessageRequested: {
                    messageEditor.text = message;
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
                    height: 200
                    anchors {
                        top: inputStatusTag.bottom
                        left: parent.left
                        right: btnSend.left
                        topMargin: 2
                        rightMargin: 6
                    }

                    enabled: messageSendInProgress === false
                             && (model.platform.status === Sci.SciPlatform.Ready
                             || model.platform.status === Sci.SciPlatform.NotRecognized)

                    focus: true

                    suggestionListModel: commandHistoryModel
                    suggestionModelTextRole: "message"
                    suggestionParent: messageHistoryButton

                    onTextChanged: {
                        model.platform.errorString = "";
                    }

                    property bool messageSendInProgress: false
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
                    onClicked: {
                        sendMessageInputTextAsComand()
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
                }
            }

            //to show proper cursor when dragging
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SplitVCursor
                acceptedButtons: Qt.NoButton
                visible: handleMouseArea.pressed
            }

            function sendMessageInputTextAsComand() {
                if (messageEditor.enabled === false) {
                    return
                }

                messageEditor.messageSendInProgress = true
                model.platform.sendMessage(messageEditor.text, validateCheckBox.checked)
            }

            function sendMessageResultHandler(type, data) {
                if (type === Sci.SciPlatform.NoError) {
                    model.platform.errorString = ""
                    messageEditor.clear()
                } else if (type === Sci.SciPlatform.NotConnectedError) {
                    model.platform.errorString = "Device not connected"
                } else if (type === Sci.SciPlatform.JsonError) {
                    var pos = messageEditor.resolveCoordinates(data.offset, messageEditor.text)
                    model.platform.errorString = "JSON error at " + (pos.line+1) + ":" + (pos.column+1) + " - " + data.message;
                } else if (type === Sci.SciPlatform.PlatformError) {
                    model.platform.errorString = data.error_string
                } else {
                    model.platform.errorString = "Unknown error"
                    console.error("unknown message send error", type, data)
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
            disableAllFiltering: platformDelegate.disableAllFiltering
            filterSuggestionModel: platformDelegate.filterSuggestionModel
            filterList: platformDelegate.filterList

            onInvalidate: {
                platformDelegate.filterList = JSON.parse(JSON.stringify(filterView.getFilterData()))
                platformDelegate.disableAllFiltering = filterView.disableAllFiltering

                console.log(Logger.sciCategory, "filters:", JSON.stringify(platformDelegate.filterList))
                console.log(Logger.sciCategory, "disableAllFiltering", platformDelegate.disableAllFiltering)

                platformDelegate.invalidateScrollbackFilterRequested()
            }
        }
    }

    Component {
        id: mockSettingsComponent

        MockSettingsView {
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

    function prettifyHintText(hintText, shortcut) {
        return hintText + " - " + shortcut
    }
}
