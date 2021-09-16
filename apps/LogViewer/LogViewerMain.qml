import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.logviewer.models 1.0 as LogViewModels
import tech.strata.theme 1.0
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.logger 1.0

FocusScope {
    id: logViewerMain

    property bool fileLoaded: false
    property bool messageWrapEnabled: true
    property alias linesCount: logModel.count
    property alias fileModel: logModel.fileModel
    property int openedFilesCount: fileModel.count
    property int cellHeightSpacer: 6
    property int defaultIconSize: 24
    property int smallIconSize: 20
    property int fontMinSize: 8
    property int fontMaxSize: 24
    property string lastOpenedFolder: ""
    property int buttonPadding: 6
    property bool timestampColumnVisible: true
    property bool pidColumnVisible: true
    property bool tidColumnVisible: true
    property bool levelColumnVisible: true
    property bool messageColumnVisible: true
    property bool sidePanelShown: true
    property int sidePanelWidth: 150
    property bool searchingMode: false
    property bool searchTagShown: false
    property bool automaticScroll: true
    property bool timestampSimpleFormat: false
    property int searchResultCount: searchResultModel.count
    property int statusBarHeight: statusBar.height
    property string borderColor: "darkgray"
    property string timestampFormat: "yyyy-MM-dd hh:mm:ss.zzz t"
    property string simpleTimestampFormat: "hh:mm:ss.zzz"
    property bool showDropAreaIndicator: false
    property bool showMarks: false
    property string markColor: TangoTheme.palette.chameleon3
    readonly property int maxRecentFiles: 5
    property var recentFiles: []

    LogViewModels.LogModel {
        id: logModel

        onRowsInserted: {
            if (automaticScroll) {
                scrollbackViewAtEndTimer.restart()
            }
        }

        onModelReset: {
            scrollbackViewAtEndTimer.restart()
        }
    }

    onOpenedFilesCountChanged: {
        if (openedFilesCount < 1) {
            fileLoaded = false
            searchInput.text = ""
        }
    }

    Timer {
        id: scrollbackViewAtEndTimer
        interval: 1

        onTriggered: {
            primaryLogView.positionViewAtEnd()
        }
    }

    QtLabsSettings.Settings {
        category: "app"

        property alias lastOpenedFolder: logViewerMain.lastOpenedFolder
        property alias messageWrapEnabled: logViewerMain.messageWrapEnabled
        property alias timestampColumnVisible: checkBoxTs.checked
        property alias pidColumnVisible: checkBoxPid.checked
        property alias tidColumnVisible: checkBoxTid.checked
        property alias levelColumnVisible: checkBoxLevel.checked
        property alias sidePanelShown: logViewerMain.sidePanelShown
        property alias sidePanelWidth: logViewerMain.sidePanelWidth
        property alias automaticScroll: logViewerMain.automaticScroll
        property alias timestampSimpleFormat: logViewerMain.timestampSimpleFormat
        property alias recentFiles: logViewerMain.recentFiles
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            id:fileDialog
            folder: lastOpenedFolder.length > 0 ? lastOpenedFolder : shortcuts.documents
            selectMultiple: true
            selectFolder: false
            nameFilters: ["Log files (*.log)","All files (*)"]

            onAccepted: {
                loadFiles(fileUrls)
            }
        }
    }

    function getFilePath() {
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(
                    logViewerMain,
                    fileDialogComponent)

        dialog.accepted.connect(function() {
            lastOpenedFolder = dialog.folder
            dialog.destroy()
        })

        dialog.rejected.connect(function() {
            dialog.destroy()
        })

        dialog.open();
    }

    function loadFiles(path) {
        var errorStringList = []
        var pathList = []

        for (var i = 0; i < path.length; ++i) {
            var errorString = logModel.followFile(CommonCPP.SGUtilsCpp.urlToLocalFile(path[i]))
            if (errorString.length === 0) {
                updateRecentFilesModel(CommonCPP.SGUtilsCpp.urlToLocalFile(path[i]))
            }
            if (errorString.length > 0) {
                errorStringList.push(errorString)
                pathList.push(CommonCPP.SGUtilsCpp.urlToLocalFile(path[i]))
                removeFromRecentFiles(CommonCPP.SGUtilsCpp.urlToLocalFile(path[i]))
            }

            if (errorStringList.length > 0 && fileLoaded === false) {
                fileLoaded = false
            } else {
                fileLoaded = true
            }
        }
        if (errorStringList.length > 0) {
            SGWidgets.SGDialogJS.showMessageDialog(
                        root,
                        SGWidgets.SGMessageDialog.Error,
                        errorStringList.length > 1 ? qsTr("Could not open files (" + errorStringList.length + ")") : qsTr("Could not open file"),
                        generateHtmlList(pathList, errorStringList))
        }

    }

    function updateRecentFilesModel(path) {
        var tmpRecentFiles = recentFiles
        var index = tmpRecentFiles.indexOf(path);
        if (index >= 0) {
	        tmpRecentFiles.splice(index, 1)
        }

        tmpRecentFiles.splice(0,0,path)

        if (tmpRecentFiles.length > maxRecentFiles) {
            tmpRecentFiles = tmpRecentFiles.slice(0, maxRecentFiles)
        }
        recentFiles = tmpRecentFiles
    }

    function removeFromRecentFiles(path) {
        var tmpRecentFiles = recentFiles
        for (var j = 0; j < tmpRecentFiles.length; ++j) {
            if (path === tmpRecentFiles[j] && fileModel.containsFilePath(path) === false) {
                tmpRecentFiles.splice(j, 1)
            }
        }
        recentFiles = tmpRecentFiles
    }

    function generateHtmlList(firstList,secondList) {
        var text = "<ul>"
        for (var i = 0; i < firstList.length; ++i) {
            text += "<li>" + firstList[i] + " - " + secondList[i].charAt(0).toUpperCase() + secondList[i].slice(1) + "</li>"
        }
        text += "</ul>"
        return text
    }

    function clearScrollback() {
        logModel.clear();
    }

    function closeAllFiles() {
        logModel.removeAllFiles()
    }

    function clearRecentFiles() {
        recentFiles = []
    }

    CommonCPP.SGSortFilterProxyModel {
        id: searchResultModel
        sourceModel: logSortFilterModel
        filterPattern: searchInput.text
        filterPatternSyntax: regExpButton.checked ? CommonCPP.SGSortFilterProxyModel.RegExp : CommonCPP.SGSortFilterProxyModel.FixedString
        caseSensitive: caseSensButton.checked ? true : false
        filterRole: "message"
        invokeCustomFilter: true
        sortEnabled: false

        function filterAcceptsRow(row) {
            var sourceIndex = logSortFilterModel.mapIndexToSource(row)
            if (sourceIndex < 0) {
                console.error(Logger.logviewerCategory, "Index out of scope.")
                return
            }
            var isMarked = logModel.data(sourceIndex, "isMarked")
            if (showMarksButton.checked && isMarked === false) {
                return false
            }

            var message = logModel.data(sourceIndex, "message")
            var matches = searchResultModel.matches(message)

            if (matches) {
                if (showMarksButton.checked) {
                    return isMarked
                } else {
                    return matches
                }
            } else {
                return false
            }
        }
    }

    CommonCPP.SGSortFilterProxyModel {
        id: logSortFilterModel
        sourceModel: logModel
        filterRole: "level"
        sortEnabled: false
        invokeCustomFilter: true

        function filterAcceptsRow(row) {
            var logLevelMsg = logModel.data(row, "level")

            if (checkBoxInfo.checked && logLevelMsg === LogViewModels.LogModel.LevelInfo) {
                return true
            } else if (checkBoxWarning.checked && logLevelMsg === LogViewModels.LogModel.LevelWarning) {
                return true
            } else if (checkBoxError.checked && logLevelMsg === LogViewModels.LogModel.LevelError) {
                return true
            } else if (checkBoxDebug.checked && logLevelMsg === LogViewModels.LogModel.LevelDebug) {
                return true
            } else if (checkBoxUnknown.checked && logLevelMsg === LogViewModels.LogModel.LevelUnknown) {
                return true
            } else {
                return false
            }
        }
    }

    CommonCPP.SGSortFilterProxyModel{
        id: markedModel
        sourceModel: logSortFilterModel
        filterRole: "isMarked"
        filterPattern: "true"
        sortEnabled: false
    }

    Row {
        id: buttonRow
        anchors {
            top: parent.top
            left: parent.left
        }
        spacing: 10

        SGWidgets.SGIconButton {
            icon.source: sidePanelShown ? "qrc:/images/side-pane-right-close.svg" : "qrc:/images/side-pane-right-open.svg"
            iconSize: defaultIconSize
            backgroundOnlyOnHovered: false
            enabled: fileLoaded
            iconMirror: true
            padding: buttonPadding
            hintText: "Toggle sidebar"

            onClicked: {
                sidePanelShown = !sidePanelShown
            }
        }

        SGWidgets.SGIconButton {
            icon.source: "qrc:/sgimages/file-add.svg"
            iconSize: defaultIconSize
            backgroundOnlyOnHovered: false
            padding: buttonPadding
            hintText: "Add file"

            onClicked:  {
                getFilePath()
            }
        }

        Row {
            spacing: 2

            SGWidgets.SGIconButton {
                icon.source: "qrc:/images/uppercase-a-small.svg"
                iconSize: defaultIconSize
                backgroundOnlyOnHovered: false
                enabled: fileLoaded
                padding: buttonPadding
                hintText: "Decrease font size"

                onClicked:  {
                    if (SGWidgets.SGSettings.fontPixelSize > fontMinSize) {
                        --SGWidgets.SGSettings.fontPixelSize
                    }
                }
            }

            SGWidgets.SGIconButton {
                icon.source: "qrc:/images/uppercase-a.svg"
                iconSize: defaultIconSize
                backgroundOnlyOnHovered: false
                enabled: fileLoaded
                padding: buttonPadding
                hintText: "Increase font size"

                onClicked:  {
                    if (SGWidgets.SGSettings.fontPixelSize < fontMaxSize) {
                        ++SGWidgets.SGSettings.fontPixelSize
                    }
                }
            }
        }

        Row {
            spacing: 2

            SGWidgets.SGIconButton {
                id: wrapButton
                icon.source: "qrc:/images/text-wrap.svg"
                iconSize: defaultIconSize
                backgroundOnlyOnHovered: false
                checkable: true
                enabled: fileLoaded
                padding: buttonPadding
                checked: messageWrapEnabled
                hintText: "Message wrap"

                onCheckedChanged: {
                    messageWrapEnabled = checked
                }
            }

            SGWidgets.SGIconButton {
                id: timestampSimpleFormatButton
                hintText: qsTr("Simple time format")
                icon.source: "qrc:/sgimages/clock.svg"
                iconSize: defaultIconSize
                backgroundOnlyOnHovered: false
                enabled: fileLoaded
                padding: buttonPadding
                checkable: true
                checked: timestampSimpleFormat

                onClicked: {
                    timestampSimpleFormat = !timestampSimpleFormat
                }
            }

            SGWidgets.SGIconButton {
                id: automaticScrollButton
                hintText: qsTr("Auto scroll")
                icon.source: "qrc:/sgimages/arrow-list-bottom.svg"
                iconSize: defaultIconSize
                backgroundOnlyOnHovered: false
                enabled: fileLoaded
                padding: buttonPadding
                checkable: true

                onClicked: {
                    automaticScroll = !automaticScroll

                    if (automaticScroll) {
                        primaryLogView.positionViewAtEnd()
                    }
                }

                Binding {
                    target: automaticScrollButton
                    property: "checked"
                    value: automaticScroll
                }
            }

            SGWidgets.SGIconButton {
                id: clearScrollbackButton
                hintText: qsTr("Clear scrollback")
                icon.source: "qrc:/sgimages/broom.svg"
                iconSize: defaultIconSize
                backgroundOnlyOnHovered: false
                enabled: fileLoaded
                padding: buttonPadding
                onClicked: clearScrollback()
            }
        }
    }

    Row {
        id: buttonRowRight
        anchors.right: parent.right
        anchors.top: buttonRow.top
        spacing: 1

        SGWidgets.SGTextField {
            id: searchInput
            width: 400
            enabled: fileLoaded
            placeholderText: qsTr("Search...")
            activeFocusOnTab: false
            focus: false
            leftIconSource: "qrc:/sgimages/zoom.svg"
            contextMenuEnabled: true
            showClearButton: true

            onTextChanged: {
                searchingMode = true
                primaryLogView.height = contentView.height/1.5
                if (searchInput.text === ""){
                    searchingMode = false
                    primaryLogView.height = contentView.height
                    secondaryLogView.currentIndex = 0
                }
            }
        }
    }

    Row {
        id: buttonRowRightButtons
        spacing: 2
        anchors.top: buttonRowRight.bottom
        anchors.left: buttonRowRight.left
        anchors.topMargin: 2

        SGWidgets.SGIconButton {
            id: caseSensButton
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/images/case-sensitive.svg"
            iconSize: smallIconSize
            backgroundOnlyOnHovered: false
            checkable: true
            enabled: fileLoaded
            padding: buttonPadding/2
            hintText: "Case sensitive"
        }

        SGWidgets.SGIconButton {
            id: regExpButton
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/images/regular-expression.svg"
            iconSize: smallIconSize
            backgroundOnlyOnHovered: false
            checkable: true
            enabled: fileLoaded
            padding: buttonPadding/2
            hintText: "Regular expression"
        }

        SGWidgets.SGIconButton {
            id: showMarksButton
            anchors.verticalCenter: parent.verticalCenter
            icon.source: "qrc:/sgimages/bookmark.svg"
            iconSize: smallIconSize
            backgroundOnlyOnHovered: false
            checkable: true
            enabled: fileLoaded
            padding: buttonPadding/2
            hintText: "Marks only"
            iconColor: markColor

            onClicked: {
                searchResultModel.invalidate()
                showMarks = !showMarks
            }
        }
    }

    Rectangle {
        id: topBorderSidePanel
        anchors.top: sidePanelSplitView.top
        anchors.left: sidePanelSplitView.left
        width: sidePanel.width
        height: 1
        color: "lightgray"
        visible: sidePanel.visible
    }

    Rectangle {
        id: leftBorderSidePanel
        anchors.left: sidePanelSplitView.left
        anchors.top: sidePanelSplitView.top
        anchors.bottom: sidePanelSplitView.bottom
        width: 1
        color: "lightgray"
        visible: sidePanel.visible
    }

    SGWidgets.SGSplitView {
        id: sidePanelSplitView
        anchors {
            top: buttonRowRightButtons.bottom
            topMargin: 10
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        orientation: Qt.Horizontal
        visible: fileLoaded

        onResizingChanged: {
            sidePanelWidth = sidePanel.width
        }

        Flickable {
            id: sidePanel
            anchors.right: contentView.left
            anchors.rightMargin: sidePanelShown ? 4 : 0
            width: sidePanelWidth
            contentHeight: sidePanelContent.height
            visible: sidePanelShown
            flickableDirection: Flickable.VerticalFlick
            boundsMovement: Flickable.StopAtBounds
            boundsBehavior: Flickable.DragAndOvershootBounds
            clip: true
            Layout.minimumWidth: 150

            ScrollBar.vertical: ScrollBar {
                minimumSize: 0.1
                policy: ScrollBar.AsNeeded
            }

            Column {
                id: sidePanelContent
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                Item {
                    id: columnFilterButton
                    width: parent.width + 10
                    height: columnFilterLabel.height

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.4
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            columnFilterMenu.visible = !columnFilterMenu.visible
                        }
                    }

                    Row {
                        id: columnFilterLabel
                        spacing: 6
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        SGWidgets.SGIcon {
                            width: height - 6
                            height: label.contentHeight + cellHeightSpacer
                            source: columnFilterMenu.visible ? "qrc:/sgimages/chevron-down.svg" : "qrc:/sgimages/chevron-right.svg"
                        }

                        SGWidgets.SGText {
                            id: label
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Columns")
                        }
                    }
                }

                Column {
                    id: columnFilterMenu
                    padding: 5

                    SGWidgets.SGCheckBox {
                        id: checkBoxTs
                        text: qsTr("Timestamp")
                        font.family: "monospace"
                        checked: timestampColumnVisible
                    }

                    SGWidgets.SGCheckBox {
                        id: checkBoxPid
                        text: qsTr("PID")
                        font.family: "monospace"
                        checked: pidColumnVisible
                    }

                    SGWidgets.SGCheckBox {
                        id: checkBoxTid
                        text: qsTr("TID")
                        font.family: "monospace"
                        checked: tidColumnVisible
                    }

                    SGWidgets.SGCheckBox {
                        id: checkBoxLevel
                        text: qsTr("Level")
                        font.family: "monospace"
                        checked: levelColumnVisible
                    }

                    SGWidgets.SGCheckBox {
                        id: checkBoxMessage
                        text: qsTr("Message")
                        font.family: "monospace"
                        checked: true
                        enabled: !checked
                    }
                }

                Item {
                    id: logLevelButton
                    width: parent.width + 10
                    height: logLevelLabel.height

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.4
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            logLevelMenu.visible = !logLevelMenu.visible
                        }
                    }

                    Row {
                        id: logLevelLabel
                        spacing: 6
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        SGWidgets.SGIcon {
                            width: height - 6
                            height: logLabel.contentHeight + cellHeightSpacer
                            source: logLevelMenu.visible ? "qrc:/sgimages/chevron-down.svg" : "qrc:/sgimages/chevron-right.svg"
                        }

                        SGWidgets.SGText {
                            id: logLabel
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Log Levels")
                        }
                    }
                }

                Column {
                    id: logLevelMenu
                    padding: 5

                    SGWidgets.SGCheckBox {
                        id: checkBoxDebug
                        text: qsTr("Debug")
                        font.family: "monospace"
                        checked: true
                        onCheckedChanged: {
                            logSortFilterModel.invalidate()
                            if (searchingMode) {
                                searchResultModel.invalidate()
                            }
                        }
                    }

                    SGWidgets.SGCheckBox {
                        id: checkBoxInfo
                        text: qsTr("Info")
                        font.family: "monospace"
                        checked: true
                        onCheckedChanged: {
                            logSortFilterModel.invalidate()
                            if (searchingMode) {
                                searchResultModel.invalidate()
                            }
                        }
                    }

                    SGWidgets.SGCheckBox {
                        id: checkBoxWarning
                        text: qsTr("Warning")
                        font.family: "monospace"
                        checked: true
                        onCheckedChanged: {
                            logSortFilterModel.invalidate()
                            if (searchingMode) {
                                searchResultModel.invalidate()
                            }
                        }
                    }

                    SGWidgets.SGCheckBox {
                        id: checkBoxError
                        text: qsTr("Error")
                        font.family: "monospace"
                        checked: true
                        onCheckedChanged: {
                            logSortFilterModel.invalidate()
                            if (searchingMode) {
                                searchResultModel.invalidate()
                            }
                        }
                    }

                    SGWidgets.SGCheckBox {
                        id: checkBoxUnknown
                        text: qsTr("Unknown")
                        font.family: "monospace"
                        checked: true
                        onCheckedChanged: {
                            logSortFilterModel.invalidate()
                            if (searchingMode) {
                                searchResultModel.invalidate()
                            }
                        }
                    }
                }

                Item {
                    id: openedFilesButton
                    width: parent.width + 10
                    height: columnFilterLabel.height

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.4
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            openedFilesMenu.visible = !openedFilesMenu.visible
                        }
                    }

                    Row {
                        id: openedFilesLabel
                        spacing: 6
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        SGWidgets.SGIcon {
                            width: height - 6
                            height: label.contentHeight + cellHeightSpacer
                            source: openedFilesMenu.visible ? "qrc:/sgimages/chevron-down.svg" : "qrc:/sgimages/chevron-right.svg"
                        }

                        SGWidgets.SGText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Opened Files")
                        }
                    }
                }

                Column {
                    id: openedFilesMenu
                    padding: 5

                    ListView {
                        id: listViewSide
                        width: sidePanel.width
                        height: contentHeight
                        model: fileModel
                        interactive: false
                        clip: true

                        property int maybeRemoveIndex: -1

                        delegate: Item {
                            id: delegateSide
                            width: ListView.view.width
                            height: fileName.height + horizontalDivider.height

                            property bool inRemoveMode: index === listViewSide.maybeRemoveIndex

                            MouseArea {
                                id: delegateSideMouseArea
                                anchors.fill: delegateSide
                                hoverEnabled: true

                                onClicked: {
                                    listViewSide.maybeRemoveIndex = -1
                                }

                                onEntered: {
                                    cellSide.color = "darkgray"
                                    rightCloseFileButton.iconColor = "white"
                                }

                                onExited: {
                                    cellSide.color = "#eeeeee"
                                    rightCloseFileButton.iconColor = "#eeeeee"
                                }

                                ToolTip {
                                    id: fileNameToolTip
                                    text: model.filepath
                                    visible: delegateSideMouseArea.containsMouse
                                    delay: 500
                                    timeout: 4000
                                    font.pixelSize: SGWidgets.SGSettings.fontPixelSize
                                }

                                Rectangle {
                                    id: cellSide
                                    height: fileName.height
                                    width: parent.width
                                    color: "#eeeeee"
                                }

                                Item {
                                    id: leftFileWrapper
                                    width: delegateSide.inRemoveMode ? leftCloseFileButton.width : 0
                                    height: cellSide.height
                                    anchors.left: cellSide.left
                                    anchors.leftMargin: delegateSide.inRemoveMode ? 5 : 0

                                    clip: true

                                    Behavior on width {
                                        NumberAnimation { duration: 100 }
                                    }

                                    SGWidgets.SGIconButton {
                                        id: leftCloseFileButton
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        iconSize: fileName.contentHeight + 1
                                        icon.source: "qrc:/sgimages/times-circle.svg"
                                        iconColor: TangoTheme.palette.error
                                        alternativeColorEnabled: true

                                        onClicked: {
                                            listViewSide.maybeRemoveIndex = -1
                                            logModel.removeFile(model.filepath)
                                        }
                                    }
                                }

                                SGWidgets.SGIcon {
                                    id: fileIcon
                                    source: "qrc:/sgimages/file-blank.svg"
                                    height: cellSide.height - 5
                                    width: height - 5
                                    anchors.left: leftFileWrapper.right
                                    anchors.verticalCenter: cellSide.verticalCenter
                                    anchors.leftMargin: 3
                                }

                                SGWidgets.SGText {
                                    id: fileName
                                    topPadding: 5
                                    bottomPadding: 5
                                    anchors.left: fileIcon.right
                                    anchors.leftMargin: 5
                                    anchors.right: rightFileWrapper.left
                                    anchors.verticalCenter: cellSide.verticalCenter
                                    text: model.filename
                                    elide: Text.ElideRight
                                }

                                Item {
                                    id: rightFileWrapper
                                    width: delegateSide.inRemoveMode === false ? rightCloseFileButton.width : 0
                                    height: cellSide.height
                                    anchors.right: cellSide.right
                                    anchors.rightMargin: 10

                                    clip: true

                                    Behavior on width {
                                        NumberAnimation { duration: 100 }
                                    }

                                    SGWidgets.SGIconButton {
                                        id: rightCloseFileButton
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        iconSize: fileName.contentHeight - 2
                                        icon.source: "qrc:/sgimages/times.svg"
                                        iconColor: "#eeeeee"
                                        alternativeColorEnabled: true

                                        onClicked: {
                                            listViewSide.maybeRemoveIndex = index
                                        }
                                    }
                                }

                                Rectangle {
                                    id: horizontalDivider
                                    anchors.top: cellSide.bottom
                                    width: cellSide.width
                                    height: 1
                                    color: "lightgray"
                                }
                            }
                        }
                    }
                }

                Item {
                    id: markedLogsButton
                    width: parent.width + 10
                    height: columnFilterLabel.height

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                        opacity: 0.4
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            markedLogs.visible = !markedLogs.visible
                        }
                    }

                    Row {
                        id: markedLogsLabel
                        spacing: 6
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        SGWidgets.SGIcon {
                            width: height - 6
                            height: label.contentHeight + cellHeightSpacer
                            source: markedLogs.visible ? "qrc:/sgimages/chevron-down.svg" : "qrc:/sgimages/chevron-right.svg"
                        }

                        SGWidgets.SGText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: qsTr("Marks")
                        }
                    }
                }

                Column {
                    id: markedLogs
                    padding: 5

                    ListView {
                        id: listViewMarks
                        width: sidePanel.width
                        height: contentHeight
                        model: markedModel
                        interactive: false
                        clip: true

                        delegate: Item {
                            id: markDelegate
                            width: ListView.view.width
                            height: markTimestamp.height + horizontalDividerMark.height

                            MouseArea {
                                id: markDelegateMouseArea
                                anchors.fill: markDelegate
                                hoverEnabled: true

                                function positionView(view, index) {
                                    view.positionViewAtIndex(index, ListView.Center)
                                    view.currentIndex = index
                                }

                                onClicked: {
                                if (index < 0) {
                                    return
                                }
                                    var sourceIndex = markedModel.mapIndexToSource(index)
                                    if (sourceIndex < 0) {
                                        console.error(Logger.logviewerCategory, "Index out of scope.")
                                        return
                                    }
                                    positionView(primaryLogView, sourceIndex)
                                }

                                Rectangle {
                                    id: cellMark
                                    height: markTimestamp.height
                                    width: parent.width - 5
                                    color: markDelegateMouseArea.containsMouse ? "darkgray" : "#eeeeee"
                                }

                                SGWidgets.SGIcon {
                                    id: markIcon
                                    source: "qrc:/sgimages/bookmark.svg"
                                    height: cellMark.height - 5
                                    width: height - 5
                                    anchors.left: cellMark.left
                                    anchors.verticalCenter: cellMark.verticalCenter
                                    anchors.leftMargin: 3
                                    iconColor: markColor
                                }

                                SGWidgets.SGText {
                                    id: markTimestamp
                                    topPadding: 5
                                    bottomPadding: 5
                                    anchors.left: markIcon.right
                                    anchors.leftMargin: 15
                                    anchors.right: cellMark.right
                                    anchors.verticalCenter: cellMark.verticalCenter
                                    text: {
                                        if (timestampSimpleFormat) {
                                            return Qt.formatDateTime(model.timestamp, simpleTimestampFormat)
                                        } else {
                                            return CommonCPP.SGUtilsCpp.formatDateTimeWithOffsetFromUtc(model.timestamp, timestampFormat)
                                        }
                                    }
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    id: horizontalDividerMark
                                    anchors.top: cellMark.bottom
                                    width: cellMark.width
                                    height: 1
                                    color: "lightgray"
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            id: contentView
            Layout.minimumWidth: root.width/2

            SGWidgets.SGSplitView {
                anchors.fill: parent
                orientation: Qt.Vertical
                visible: fileLoaded

                LogListView {
                    id: primaryLogView
                    height: searchingMode ? parent.height/1.5 : parent.height
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Layout.minimumHeight: parent.height/2
                    Layout.fillHeight: true
                    model: logSortFilterModel
                    visible: fileLoaded && showMarks === false
                    focus: true

                    timestampColumnVisible: checkBoxTs.checked
                    pidColumnVisible: checkBoxPid.checked
                    tidColumnVisible: checkBoxTid.checked
                    levelColumnVisible: checkBoxLevel.checked
                    messageColumnVisible: checkBoxMessage.checked
                    sidePanelShown: logViewerMain.sidePanelShown
                    sidePanelWidth: logViewerMain.sidePanelWidth
                    messageWrapEnabled: logViewerMain.messageWrapEnabled
                    searchTagShown: false
                    highlightColor: searchInput.palette.highlight
                    startAnimation: secondaryLogView.activeFocus
                    timestampSimpleFormat: logViewerMain.timestampSimpleFormat
                    automaticScroll: logViewerMain.automaticScroll
                    markIconVisible: true
                    markColor: logViewerMain.markColor

                    KeyNavigation.tab: searchInput
                    KeyNavigation.backtab: secondaryLogView
                    KeyNavigation.priority: KeyNavigation.BeforeItem
                }

                Rectangle {
                    height: parent.height - primaryLogView.height
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Layout.minimumHeight: parent.height/4
                    border.color: TangoTheme.palette.butter1
                    border.width: 2
                    visible: searchingMode || showMarks

                    LogListView {
                        id: secondaryLogView
                        anchors.fill: parent
                        anchors.margins: 2
                        model: searchResultModel

                        timestampColumnVisible: checkBoxTs.checked
                        pidColumnVisible: checkBoxPid.checked
                        tidColumnVisible: checkBoxTid.checked
                        levelColumnVisible: checkBoxLevel.checked
                        messageColumnVisible: checkBoxMessage.checked
                        messageWrapEnabled: logViewerMain.messageWrapEnabled
                        sidePanelShown: logViewerMain.sidePanelShown
                        sidePanelWidth: logViewerMain.sidePanelWidth
                        searchTagShown: true
                        highlightColor: searchInput.palette.highlight
                        markColor: logViewerMain.markColor
                        timestampSimpleFormat: timestampSimpleFormatButton.checked
                        automaticScroll: logViewerMain.automaticScroll
                        markIconVisible: false
                        showMarks: logViewerMain.showMarks
                        searchingMode: logViewerMain.searchingMode

                        onDelegateSelected: {
                            var sourceIndex = searchResultModel.mapIndexToSource(index)
                            if (sourceIndex < 0) {
                                console.error(Logger.logviewerCategory, "Index out of range")
                                return
                            }

                            primaryLogView.positionViewAtIndex(sourceIndex, ListView.Center)
                            primaryLogView.currentIndex = sourceIndex
                        }

                        KeyNavigation.tab: primaryLogView
                        KeyNavigation.backtab: searchInput
                        KeyNavigation.priority: KeyNavigation.BeforeItem
                    }
                }
            }
        }
    }

    Rectangle {
        id: statusBar
        visible: fileLoaded
        anchors.top: logViewerMain.bottom
        anchors.left: logViewerMain.left
        anchors.right: logViewerMain.right
        height: statusBarText.contentHeight + 8
        color: "lightgrey"
        clip: true

        SGWidgets.SGText {
            id: statusBarText
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: statusBar.verticalCenter
            width: statusBar.width - statusBarText.x
            font.family: "monospace"
            text: {
                qsTr("Range: %1 - %2 | %3 %4").arg(CommonCPP.SGUtilsCpp.formatDateTimeWithOffsetFromUtc(logModel.oldestTimestamp, timestampFormat))
                .arg(CommonCPP.SGUtilsCpp.formatDateTimeWithOffsetFromUtc(logModel.newestTimestamp, timestampFormat))
                .arg(logViewerMain.linesCount)
                .arg((logViewerMain.linesCount == 1) ? "log" : "logs")
            }
            elide: Text.ElideRight
        }
    }

    DropArea {
        anchors {
            top: buttonRowRightButtons.bottom
            topMargin: 5
            left: parent.left
            right: parent.right
            bottom: statusBar.bottom
        }

        onEntered: {
            for (var i = 0 ; i < drag.urls.length; i++) {
                var url = CommonCPP.SGUtilsCpp.urlToLocalFile(drag.urls[i])
                if (CommonCPP.SGUtilsCpp.isFile(url)) {
                    drag.accept()
                }
            }
            showAreaIndicator(true)
        }

        onExited: {
            showAreaIndicator(false)
        }

        onDropped: {
            drop.accept()
            showAreaIndicator(false)
            loadFileTimer.urls = drop.urls
            loadFileTimer.start()
        }

        Timer {
            property variant urls

            id: loadFileTimer
            interval: 1

            onTriggered: {
                loadFiles(urls)
            }
        }

        function showAreaIndicator(status) {
            if (status) {
                dashedBorder.dashesSize = 3
                dropAreaColor.color = "darkgray"
                borderColor = "black"
                if (fileLoaded) {
                    showDropAreaIndicator = true
                }
            } else {
                dashedBorder.dashesSize = 2
                dropAreaColor.color = "#eeeeee"
                borderColor = "darkgray"
                if (fileLoaded) {
                    showDropAreaIndicator = false
                }
            }
        }

        Rectangle {
            id: dropAreaColor
            anchors.fill: parent
            color: "#eeeeee"
            opacity: dashedBorder.visible ? fileLoaded ? 0.85 : 1 : 0
            visible: dashedBorder.visible
        }

        Shape {
            id: dashedBorder
            anchors {
                fill: parent
            }
            visible: !fileLoaded || showDropAreaIndicator

            property int dashesSize: 2

            ShapePath {
                strokeColor: borderColor
                strokeWidth: dashedBorder.dashesSize
                strokeStyle: ShapePath.DashLine
                startX: dashedBorder.dashesSize/2
                startY: dashedBorder.dashesSize/2
                PathLine { x: dashedBorder.width - dashedBorder.dashesSize/2; y: dashedBorder.dashesSize/2 }
            }
            ShapePath {
                strokeColor: borderColor
                strokeWidth: dashedBorder.dashesSize
                strokeStyle: ShapePath.DashLine
                startX: dashedBorder.dashesSize/2
                startY: dashedBorder.dashesSize/2
                PathLine { x: dashedBorder.dashesSize/2; y: dashedBorder.height - dashedBorder.dashesSize/2 }
            }
            ShapePath {
                strokeColor: borderColor
                strokeWidth: dashedBorder.dashesSize
                strokeStyle: ShapePath.DashLine
                startX: dashedBorder.width - dashedBorder.dashesSize/2
                startY: dashedBorder.dashesSize/2
                PathLine { x: dashedBorder.width - dashedBorder.dashesSize/2; y: dashedBorder.height - dashedBorder.dashesSize/2 }
            }
            ShapePath {
                strokeColor: borderColor
                strokeWidth: dashedBorder.dashesSize
                strokeStyle: ShapePath.DashLine
                startX: dashedBorder.dashesSize/2
                startY: dashedBorder.height - dashedBorder.dashesSize/2
                PathLine { x: dashedBorder.width - dashedBorder.dashesSize/2; y: dashedBorder.height - dashedBorder.dashesSize/2 }
            }
        }

        SGWidgets.SGIcon {
            id: dropFileIcon
            source: "qrc:/sgimages/drop-file.svg"
            anchors.bottom: dropAreaText.top
            anchors.bottomMargin: 10
            anchors.horizontalCenter: dropAreaText.horizontalCenter
            width: dropAreaText.width/3
            height: width
            visible: dashedBorder.visible
        }

        SGWidgets.SGText {
            id: dropAreaText
            anchors.centerIn: parent
            text: fileLoaded === false ? qsTr("Add a file or drop it here.") : qsTr("Drop a file here.")
            fontSizeMultiplier: 2
            visible: dashedBorder.visible
        }
    }

    Keys.onPressed: {
        if ((event.key === Qt.Key_F) && (event.modifiers & Qt.ControlModifier)) {
            searchInput.forceActiveFocus()
        }
        if (event.key === Qt.Key_Escape) {
            listViewSide.maybeRemoveIndex = -1
        }
    }
}
