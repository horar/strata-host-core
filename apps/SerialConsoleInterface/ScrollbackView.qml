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
import tech.strata.logger 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.sci 1.0 as Sci
import tech.strata.theme 1.0


Item {
    id: scrollbackView

    property variant model
    property bool disableAllFiltering
    property bool automaticScroll
    property var filterList
    readonly property int count: scrollbackFilterModel.count

    property int selectionStartIndex: -1
    property int selectionEndIndex: -1
    property int selectionStartPosition: -1
    property int selectionEndPosition: -1

    property int currentIndex: scrollbackFilterModel.mapIndexToSource(listView.currentIndex)
    property color highlightNoFocusColor: "#aaaaaa"

    signal resendMessageRequested(string message)


    function invalidateFilter() {
        scrollbackFilterModel.invalidate()
        clearSelection()
    }

    function positionViewAtEnd() {
        listView.positionViewAtEnd()
        scrollbackViewAtEndTimer.restart()
    }

    // internal stuff
    property int delegateBaseSpacing: 1
    property int delegateRightMargin: 2
    property int buttonRowIconSize: SGWidgets.SGSettings.fontPixelSize - 4
    property int buttonRowSpacing: 2
    property int timestampWidth: timestampTextMetrics.width
    property int buttonRowWidth: 2*dummyIconButton.width + buttonRowSpacing
    property int delegateTimestampX: delegateBaseSpacing
    property int delegateButtonRowX: delegateTimestampX + timestampWidth + buttonRowSpacing
    property int delegateTextX: delegateButtonRowX + buttonRowWidth + delegateBaseSpacing

    Keys.onPressed: {
        if (event.matches(StandardKey.Copy)) {
            copyToClipboard()
        } else if (event.matches(StandardKey.SelectAll)) {
            selectAllText()
        } else {
            return
        }

        event.accepted = true
    }

    Timer {
        id: scrollbackViewAtEndTimer
        interval: 1

        onTriggered: {
            listView.positionViewAtEnd()
        }
    }

    CommonCpp.SGSortFilterProxyModel {
        id: scrollbackFilterModel
        sourceModel: scrollbackView.model
        filterRole: "message"
        sortEnabled: false
        invokeCustomFilter: true

        // New messages can be added only at the end
        // Existing messages can be removed only from beginning

        onRowsInserted: {
            if (automaticScroll) {
                scrollbackViewAtEndTimer.restart()
            }
        }

        onModelReset: {
            clearSelection()
        }

        onRowsRemoved: {
            if (selectionEndIndex <= last) {
                var newSelectionStartIndex = -1
                var newSelectionEndIndex = -1;
            } else {
                if (selectionStartIndex <= last) {
                    newSelectionStartIndex = 0
                } else {
                    newSelectionStartIndex = selectionStartIndex - last - 1
                }

                newSelectionEndIndex = selectionEndIndex - last - 1
            }

            selectionStartIndex = newSelectionStartIndex;
            selectionEndIndex = newSelectionEndIndex
        }

        function filterAcceptsRow(row) {
            if (filterList.length === 0) {
                return true
            }

            if (disableAllFiltering) {
                return true
            }

            var type = sourceModel.data(row, "type")
            if (type !== Sci.SciScrollbackModel.NotificationReply) {
                return true
            }

            var value = sourceModel.data(row, "value")

            for (var i = 0; i < platformDelegate.filterList.length; ++i) {
                var filterString = platformDelegate.filterList[i]["filter_string"].toString().toLowerCase();
                var filterCondition = platformDelegate.filterList[i]["condition"].toString();

                if (filterCondition === "contains" && value.includes(filterString)) {
                    return false
                } else if (filterCondition === "equal" && value === filterString) {
                    return false
                } else if (filterCondition === "startswith" && value.startsWith(filterString)) {
                    return false
                } else if (filterCondition === "endswith" && value.endsWith(filterString)) {
                    return false
                }
            }

            return true
        }
    }

    SGWidgets.SGIconButton {
        id: dummyIconButton
        visible: false
        icon.source: "qrc:/sgimages/chevron-right.svg"
        iconSize: scrollbackView.buttonRowIconSize
    }

    TextMetrics {
        id: timestampTextMetrics
        font.family: "monospace"
        font.pixelSize: SGWidgets.SGSettings.fontPixelSize
        text: model.timestampFormat
    }

    Rectangle {
        id: listViewBg
        anchors {
            fill: listView
            margins: -listViewBg.border.width
        }
        color: "white"
        border {
            width: 1
            color: TangoTheme.palette.componentBorder
        }
    }

    SGWidgets.SGAbstractContextMenu {
        id: contextMenuPopup

        Action {
            id: undoAction
            text: qsTr("Undo")
            enabled: false
        }
        Action {
            id: redoAction
            text: qsTr("Redo")
            enabled: false
        }
        MenuSeparator { }
        Action {
            id: cutAction
            text: qsTr("Cut")
            enabled: false
        }
        Action {
            id: copyAction
            text: qsTr("Copy")
            enabled: (selectionStartPosition !== selectionEndPosition) || (selectionStartIndex !== selectionEndIndex)
            onTriggered: {
                copyToClipboard()
            }
        }
        Action {
            id: pasteAction
            text: qsTr("Paste")
            enabled: false
        }
        MenuSeparator { }
        Action {
            id: selectAction
            text: qsTr("Select All")
            enabled: listView.count > 0
            onTriggered: {
                selectAllText()
            }
        }

        onClosed: {
            listView.forceActiveFocus()
        }
    }

    ListView {
        id: listView
        anchors {
            fill: parent
            margins: listViewBg.border.width
        }

        model: scrollbackFilterModel
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 100

        onActiveFocusChanged: {
            if ((activeFocus === false) && (contextMenuPopup.visible === false)) {
                clearSelection()
            }
        }

        MouseArea {
            id: menuPopupMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.RightButton

            /*this is to stop interaction with flickable while selecting text */
            drag.target: Item {}

            onPressed: {
                listView.forceActiveFocus()
            }

            onReleased: {
                if (menuPopupMouseArea.containsMouse) {
                    contextMenuPopup.popup(null)
                }
            }
        }

        MouseArea {
            id: textSelectionMouseArea
            height: Math.min(listView.height, listView.contentHeight)
            anchors {
                top: listView.top
                left: listView.left
                leftMargin: delegateTextX
                right: listView.right
                rightMargin: delegateRightMargin
            }

            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.LeftButton

            /*this is to stop interaction with flickable while selecting text */
            drag.target: Item {}

            property int startIndex
            property int startPosition

            onPressed: {
                listView.forceActiveFocus()

                var position = resolvePosition(mouse.x, mouse.y)
                if (position === undefined) {
                    return
                }

                listView.currentIndex = position.delegate_index

                startIndex = position.delegate_index
                startPosition = position.cursor_pos

                selectionStartIndex = startIndex
                selectionEndIndex = startIndex
                selectionStartPosition = startPosition
                selectionEndPosition = startPosition
            }

            onPositionChanged: {
                //do not allow to select delegates outside of view
                if (mouse.y < 0) {
                   var mouseY = 0
                } else if (mouse.y > textSelectionMouseArea.height * 0.95) {
                    mouseY = textSelectionMouseArea.height
                } else {
                    mouseY = mouse.y
                }

                var position = resolvePosition(mouse.x, mouseY)
                if (position === undefined) {
                    return
                }

                //make sure start <= end
                if (startIndex <= position.delegate_index) {
                   selectionStartIndex = startIndex
                   selectionEndIndex = position.delegate_index
                } else {
                    selectionStartIndex = position.delegate_index
                    selectionEndIndex = startIndex
                }

                if (startPosition <= position.cursor_pos) {
                    selectionStartPosition = startPosition
                    selectionEndPosition = position.cursor_pos
                } else {
                    selectionStartPosition = position.cursor_pos
                    selectionEndPosition = startPosition
                }

                //flick view while dragging
                if (mouse.y > textSelectionMouseArea.height * 0.95) {
                    listView.flick(0, -300)
                } else if (mouse.y < textSelectionMouseArea.height * 0.05) {
                    listView.flick(0, 300)
                }
            }

            function resolvePosition(x,y) {
                var posInListViewX = listView.contentX + textSelectionMouseArea.x + x
                var posInListViewY = listView.contentY + textSelectionMouseArea.y + y

                var delegateIndex = listView.indexAt(posInListViewX, posInListViewY)
                if (delegateIndex < 0) {
                    return
                }

                var item = listView.itemAt(posInListViewX, posInListViewY)
                var posInDelegate = item.mapFromItem(textSelectionMouseArea, x, y)
                var cursorPos = item.positionAtTextEdit(posInDelegate.x, posInDelegate.y)

                return {
                    "delegate_index": delegateIndex,
                    "cursor_pos": cursorPos
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            id: verticalScrollbar
            anchors {
                right: listView.right
                rightMargin: 0
            }
            width: visible ? 8 : 0

            policy: ScrollBar.AlwaysOn
            minimumSize: 0.1
            visible: listView.height < listView.contentHeight

            Behavior on width { NumberAnimation {}}
        }

        delegate: Item {
            id: cmdDelegate
            width: ListView.view.width - verticalScrollbar.width
            height: cmdText.height + 3

            property color helperTextColor: "#333333"

            property int delegateIndex: index
            onDelegateIndexChanged: selectTimer.restart()

            Rectangle {
                id: messageTypeBg
                anchors {
                    top: parent.top
                    left: parent.left
                    right: buttonRow.right
                    bottom: divider.top
                }

                color: {
                    if (model.type === Sci.SciScrollbackModel.Request) {
                        return Qt.lighter(TangoTheme.palette.chocolate1, 1.3)
                    }

                    return "transparent"
                }
            }

            Rectangle {
                id: messageValidityBg
                anchors {
                    top: parent.top
                    left: messageTypeBg.right
                    right: parent.right
                    bottom: divider.top
                }

                color: {
                    if (model.isJsonValid === false) {
                        return Qt.lighter(TangoTheme.palette.error, 2.3)
                    }

                    return "transparent"
                }
            }

            Rectangle {
                anchors.fill: parent

                color: "transparent"
                border {
                    width: 2
                    color: {
                        if (listView.activeFocus) {
                            return TangoTheme.palette.highlight
                        } else {
                            return highlightNoFocusColor
                        }
                    }
                }

                visible: cmdDelegate.ListView.isCurrentItem
            }

            SGWidgets.SGText {
                id: timeText
                anchors {
                    top: parent.top
                    topMargin: 1
                    left: parent.left
                    leftMargin: delegateBaseSpacing
                }

                text: model.timestamp
                font.family: "monospace"
                color: cmdDelegate.helperTextColor
            }

            Item {
                id: buttonRow
                height: dummyIconButton.height
                width: buttonRowWidth
                anchors {
                    left: parent.left
                    leftMargin: delegateButtonRowX
                    verticalCenter: timeText.verticalCenter
                }

                Loader {
                    anchors {
                        left: parent.left
                        leftMargin: scrollbackView.buttonRowSpacing
                        verticalCenter: parent.verticalCenter
                    }

                    sourceComponent: model.type === Sci.SciScrollbackModel.Request ? resendButtonComponent : null
                }

                Loader {
                    anchors {
                        left: parent.left
                        leftMargin: dummyIconButton.width + scrollbackView.buttonRowSpacing
                    }

                    sourceComponent: condensedButtonComponent
                }
            }

            SGWidgets.SGTextEdit {
                id: cmdText
                anchors {
                    top: timeText.top
                    left: parent.left
                    leftMargin: delegateTextX
                    right: parent.right
                    rightMargin: delegateRightMargin
                }

                textFormat: Text.PlainText
                font.family: "monospace"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                selectByKeyboard: true
                selectByMouse: false
                readOnly: true
                text: model.message
                selectionColor: TangoTheme.palette.selectedText
                selectedTextColor: "white"

                Component.onCompleted: {
                    selectTimer.restart()
                }

                Connections {
                    target: scrollbackView
                    onSelectionStartIndexChanged: selectTimer.restart()
                    onSelectionEndIndexChanged: selectTimer.restart()
                    onSelectionStartPositionChanged: selectTimer.restart()
                    onSelectionEndPositionChanged: selectTimer.restart()
                }

                Timer {
                    id: selectTimer
                    interval: 1
                    repeat: false
                    onTriggered: {
                        if (index >= selectionStartIndex && index <= selectionEndIndex) {
                            if (selectionStartIndex === selectionEndIndex) {
                                cmdText.select(selectionStartPosition, selectionEndPosition)
                            } else {
                                cmdText.selectAll()
                            }
                        } else {
                            cmdText.deselect()
                        }
                    }
                }
            }

            Loader {
                id: syntaxHighlighterLoader
                sourceComponent: model.isJsonValid ? syntaxHighlighterComponent : null
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
                visible: index < scrollbackView.count - 1 || verticalScrollbar.visible == false
            }

            Component {
                id: resendButtonComponent
                SGWidgets.SGIconButton {
                    iconColor: cmdDelegate.helperTextColor
                    hintText: qsTr("Resend")
                    iconSize: scrollbackView.buttonRowIconSize
                    icon.source: "qrc:/images/redo.svg"
                    onClicked: {
                        if (model.isJsonValid) {
                            var msg = CommonCpp.SGJsonFormatter.prettifyJson(model.message)
                        } else {
                            msg = model.message
                        }

                        resendMessageRequested(msg)
                    }
                }
            }

            Component {
                id: condensedButtonComponent
                SGWidgets.SGIconButton {
                    iconColor: cmdDelegate.helperTextColor
                    hintText: qsTr("Condensed mode")
                    iconSize: scrollbackView.buttonRowIconSize
                    enabled: model.isJsonValid
                    icon.source: {
                        if (model.isCondensed || model.isJsonValid === false) {
                            return "qrc:/sgimages/chevron-right.svg"
                        }
                         return "qrc:/sgimages/chevron-down.svg"
                    }

                    onClicked: {
                        var sourceIndex = scrollbackFilterModel.mapIndexToSource(index)
                        if (sourceIndex < 0) {
                            console.error(Logger.sciCategory, "Index out of scope.")
                            return
                        }

                        var item = scrollbackView.model.setIsCondensed(sourceIndex, !model.isCondensed)
                        clearSelection()
                    }
                }
            }

            Component {
                id: syntaxHighlighterComponent
                CommonCpp.SGJsonSyntaxHighlighter {
                    textDocument: cmdText.textDocument
                }
            }

            function positionAtTextEdit(x,y) {
                return cmdText.positionAt(x-cmdText.x , y)
            }

            function positionAtTextEditEnd() {
                return cmdText.length
            }
        }
    }

    function clearSelection() {
        selectionStartIndex = -1
        selectionEndIndex = -1
        selectionStartPosition = -1
        selectionEndPosition = -1
    }

    function copyToClipboard() {
        if (selectionStartPosition < 0 || selectionEndPosition < 0) {
            return
        }

        var text = ""

        for (var i = selectionStartIndex; i <= selectionEndIndex; ++i) {
            var sourceIndex = scrollbackFilterModel.mapIndexToSource(i)
            if (sourceIndex < 0) {
                console.error(Logger.sciCategory, "Index out of scope.")
                text = ""
                break
            }

            text += CommonCpp.SGJsonFormatter.convertToHardBreakLines(model.data(sourceIndex, "message"))
            if (i !== selectionEndIndex) {
                text += '\n'
            }
        }

        if (selectionStartIndex == selectionEndIndex) {
            text = text.slice(selectionStartPosition, selectionEndPosition)
        }

        CommonCpp.SGUtilsCpp.copyToClipboard(text)
    }

    function selectAllText() {
        if (listView.count === 0) {
            return
        }

        var delegateIndexEnd = listView.count -1
        var delegatePositionEnd = 0
        if (delegateIndexEnd === 0) {
            var delegateItemEnd = listView.itemAt(0, 0)
            delegatePositionEnd = delegateItemEnd.positionAtTextEditEnd()
        }

        selectionStartIndex = 0
        selectionEndIndex = delegateIndexEnd
        selectionStartPosition = 0
        selectionEndPosition = delegatePositionEnd
    }
}
