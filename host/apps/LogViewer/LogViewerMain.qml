﻿import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Shapes 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.logviewer.models 1.0 as LogViewModels
import Qt.labs.settings 1.1 as QtLabsSettings

Item {
    id: logViewerMain
    focus: true

    property bool fileLoaded: false
    property bool messageWrapEnabled: true
    property alias linesCount: logFilesModel.count
    property alias fileModel: logFilesModel.fileModel
    property int cellHeightSpacer: 6
    property int defaultIconSize: 24
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
    property int searchResultCount: logFilesModelProxy.count
    property int statusBarHeight: statusBar.height
    property string borderColor: "darkgray"

    LogViewModels.LogModel {
        id: logFilesModel

        onRowsInserted: {
            if (automaticScroll) {
                scrollbackViewAtEndTimer.restart()
            }
        }

        onModelReset: {
            scrollbackViewAtEndTimer.restart()
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
                loadFile(fileUrls)
            }
        }
    }

    function getFilePath(callback) {
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(
                    logViewerMain,
                    fileDialogComponent)

        dialog.accepted.connect(function() {
            if (callback) {
                lastOpenedFolder = dialog.folder
                callback(dialog.fileUrl)
            }
            dialog.destroy()
        })

        dialog.rejected.connect(function() {
            dialog.destroy()
        })

        dialog.open();
    }

    function loadFile(path) {
        var errorStringList = []
        var pathList = []

        for (var i = 0; i < path.length; ++i) {
            var errorString = logFilesModel.followFile(CommonCPP.SGUtilsCpp.urlToLocalFile(path[i]))

            if (errorString.length > 0) {
                errorStringList.push(errorString)
                if (CommonCPP.SGUtilsCpp.fileName(path[i]) === "") {
                    pathList.push(CommonCPP.SGUtilsCpp.dirName(path[i]))
                } else {
                    pathList.push(CommonCPP.SGUtilsCpp.fileName(path[i]))
                }
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

    function generateHtmlList(firstList,secondList) {
        var text = "<ul>"
        for (var i = 0; i < firstList.length; ++i) {
            text += "<li>" + firstList[i] + " - " + secondList[i].charAt(0).toUpperCase() + secondList[i].slice(1) + "</li>"
        }
        text += "</ul>"
        return text
    }

    CommonCPP.SGSortFilterProxyModel {
        id: logFilesModelProxy
        sourceModel: logFilesModel
        filterPattern: searchInput.text
        filterPatternSyntax: regExpButton.checked ? CommonCPP.SGSortFilterProxyModel.RegExp : CommonCPP.SGSortFilterProxyModel.FixedString
        caseSensitive: caseSensButton.checked ? true : false
        filterRole: "message"
        sortRole: "timestamp"
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
                getFilePath(function(path) {})
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

            onTextChanged: {
                searchingMode = true
                primaryLogView.height = contentView.height/1.5
                if (searchInput.text == ""){
                    searchingMode = false
                    primaryLogView.height = contentView.height
                    secondaryLogView.currentIndex = -1
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
            iconSize: defaultIconSize/1.2
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
            iconSize: defaultIconSize/1.2
            backgroundOnlyOnHovered: false
            checkable: true
            enabled: fileLoaded
            padding: buttonPadding/2
            hintText: "Regular expression"
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
                            text: qsTr("Column Filter")
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
                        width: sidePanel.width - 5
                        height: contentHeight
                        model: fileModel
                        interactive: false
                        clip: true

                        delegate: Item {
                            id: delegateSide
                            width: fileName.width
                            height: fileName.height + horizontalDivider.height

                            MouseArea {
                                id: fileNameMouseArea
                                anchors.fill: delegateSide
                                hoverEnabled: true
                            }

                            ToolTip {
                                id: fileNameToolTip
                                text: model.filepath
                                visible: fileNameMouseArea.containsMouse
                                delay: 500
                                timeout: 4000
                                font.pixelSize: SGWidgets.SGSettings.fontPixelSize
                            }

                            Rectangle {
                                id: cellSide
                                height: fileName.height
                                width: sidePanel.width
                                color: "#eeeeee"
                            }

                            SGWidgets.SGIcon {
                                id: fileIcon
                                source: "qrc:/sgimages/file-blank.svg"
                                height: cellSide.height - 5
                                width: height - 5
                                anchors.left: cellSide.left
                                anchors.verticalCenter: cellSide.verticalCenter
                                anchors.leftMargin: 5
                            }

                            Rectangle {
                                id: horizontalDivider
                                anchors.top: cellSide.bottom
                                width: cellSide.width
                                height: 1
                                color: "lightgray"
                            }

                            SGWidgets.SGText {
                                id: fileName
                                topPadding: 5
                                bottomPadding: 5
                                rightPadding: 5
                                leftPadding: 3
                                anchors.left: fileIcon.right
                                anchors.verticalCenter: parent.verticalCenter
                                text: model.filename
                                width: sidePanel.width - fileIcon.width - 5
                                elide: Text.ElideRight
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
                    model: logFilesModel
                    visible: fileLoaded

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
                }

                Rectangle {
                    height: parent.height - primaryLogView.height
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: sidePanelShown ? 4 : 0
                    Layout.minimumHeight: parent.height/4
                    border.color: SGWidgets.SGColorsJS.TANGO_BUTTER1
                    border.width: 2
                    visible: searchingMode

                    LogListView {
                        id: secondaryLogView
                        anchors.fill: parent
                        anchors.leftMargin: sidePanelShown ? -2 : 2
                        anchors.margins: 2
                        model: logFilesModelProxy

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
                        timestampSimpleFormat: timestampSimpleFormatButton.checked
                        automaticScroll: logViewerMain.automaticScroll

                        onCurrentItemChanged: {
                            var sourceIndex = logFilesModelProxy.mapIndexToSource(index)
                            primaryLogView.positionViewAtIndex(sourceIndex, ListView.Center)
                            primaryLogView.currentIndex = sourceIndex
                        }
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
                if (logViewerMain.linesCount == 1) {
                    qsTr("Range: %1 - %2 | %3 log").arg(Qt.formatDateTime(logFilesModel.oldestTimestamp,
                                                                          "yyyy-MM-dd hh:mm:ss.zzz t")).arg(Qt.formatDateTime(logFilesModel.newestTimestamp,
                                                                                                                              "yyyy-MM-dd hh:mm:ss.zzz t")).arg(logViewerMain.linesCount)
                } else {
                    qsTr("Range: %1 - %2 | %3 logs").arg(Qt.formatDateTime(logFilesModel.oldestTimestamp,
                                                                           "yyyy-MM-dd hh:mm:ss.zzz t")).arg(Qt.formatDateTime(logFilesModel.newestTimestamp,
                                                                                                                               "yyyy-MM-dd hh:mm:ss.zzz t")).arg(logViewerMain.linesCount)
                }
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
                loadFile(urls)
            }
        }

        function showAreaIndicator(status) {
            if (status) {
                dashedBorder.dashesSize = 3
                dropAreaColor.color = "darkgray"
                borderColor = "black"
                if (fileLoaded) {
                    dashedBorder.visible = true
                    dropAreaText.visible = true
                }
            } else {
                dashedBorder.dashesSize = 2
                dropAreaColor.color = "#eeeeee"
                borderColor = "darkgray"
                if (fileLoaded) {
                    dashedBorder.visible = false
                    dropAreaText.visible = false
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
            visible: !fileLoaded

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
            visible: dashedBorder.visible ? fileLoaded === false ? true : false : false
        }
    }

    Keys.onPressed: {
        if ((event.key === Qt.Key_F) && (event.modifiers & Qt.ControlModifier)) {
            searchInput.forceActiveFocus()
        }
    }

    Keys.onTabPressed: {
        if (searchInput.activeFocus === true) {
            if (secondaryLogView.currentIndex === -1) {
                secondaryLogView.currentIndex = 0
            }
        }

        if (primaryLogView.activeFocus === true) {
            if (secondaryLogView.currentIndex === -1) {
                secondaryLogView.currentIndex = 0
            }
        }

        if (searchResultCount !== 0 && searchingMode) {
            secondaryLogView.forceActiveFocus()
        }
    }
}
