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

            property int maximumInputAreaHeight: Math.floor(height/2)
            property int minimumInputAreaHeight: 100

            onMaximumInputAreaHeightChanged: {
                messageEditor.height = Math.min(maximumInputAreaHeight, messageEditor.height)
            }

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

            Shortcut {
                id: sendMultilineCommandWinOS
                sequence: "Ctrl+Enter"
                onActivated: mainPage.sendMessageInputTextAsComand()
            }

            Shortcut {
                id: sendMultilineCommandMacOS
                sequence: "Ctrl+Return"
                onActivated: mainPage.sendMessageInputTextAsComand()
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
                    messageEditor.text = message;
                }
            }

            FocusScope {
                id: inputWrapper
                height: rightButtonRow.y + rightButtonRow.height + 6
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
                        left: messageEditor.left
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
                        margins: 6
                    }

                    text: model.platform.errorString
                    verticalPadding: 1
                    color: TangoTheme.palette.scarletRed1
                    textColor: "white"
                    font.bold: true
                }

                MessageEditor {
                    id: messageEditor
                    height: 200
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

                    suggestionListModel: commandHistoryModel
                    suggestionModelTextRole: "message"

                    onTextChanged: {
                        model.platform.errorString = "";
                    }
                }

                SGWidgets.SGTag {
                    anchors {
                        top: messageEditor.bottom
                        topMargin: 2
                        right: messageEditor.right
                    }

                    text: "Line: " + (messageEditor.currentLine + 1) + ", Col: " + (messageEditor.currentColumn + 1)
                    color: "#b2b2b2"
                    textColor: "white"
                    horizontalPadding: 2
                    verticalPadding: 2
                    font: messageEditor.font
                }

                Row {
                    id: rightButtonRow
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
                }

                SGWidgets.SGCheckBox {
                    id: validateCheckBox
                    anchors {
                        left: rightButtonRow.right
                        leftMargin: 2*rightButtonRow.spacing
                        verticalCenter: rightButtonRow.verticalCenter
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
                        rightMargin: 6
                    }

                    enabled: messageEditor.enabled
                    focusPolicy: Qt.NoFocus
                    hintText: prettifyHintText("Send command", showSendShorcut(sendMultilineCommandMacOS,sendMultilineCommandWinOS))
                    text: qsTr("SEND")
                    onClicked: {
                        sendMessageInputTextAsComand()
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
                var result = model.platform.sendMessage(messageEditor.text, validateCheckBox.checked)

                if (result.error === "no_error") {
                    model.platform.errorString = ""
                    messageEditor.clear()
                } else if (result.error === "not_connected") {
                    model.platform.errorString = "Platfrom not connected"
                } else if (result.error === "json_error") {
                    var pos = messageEditor.resolveCoordinates(result.offset, messageEditor.text)
                    model.platform.errorString = "JSON error at " + (pos.line+1) + ":" + (pos.column+1) +  "- " + result.message;
                } else if (result.error === "send_error") {
                    model.platform.errorString = "Could not send message"
                } else {
                    model.platform.errorString = "Unknown error"
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

    function showSendShorcut(macShortcut, winShortcut) {
        return Qt.platform.os === "osx" ? macShortcut.nativeText : winShortcut.nativeText 
    }
}
