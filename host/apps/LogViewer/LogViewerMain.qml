import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.fonts 1.0 as StrataFonts
import tech.strata.logviewer.models 1.0 as LogViewModels
import Qt.labs.settings 1.1 as QtLabsSettings

Item {
    id: logViewerMain

    property bool fileLoaded: false
    property bool messageWrapEnabled: true
    property string filePath
    property alias linesCount: logFilesModel.count
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

    LogViewModels.LogModel {
        id: logFilesModel
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
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            id:fileDialog
            folder: lastOpenedFolder.length > 0 ? lastOpenedFolder : shortcuts.documents
            selectMultiple: false
            selectFolder: false
            nameFilters: ["Log files (*.log)","All files (*)"]
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

    CommonCPP.SGSortFilterProxyModel {
        id: logFilesModelProxy
        sourceModel: logFilesModel
        filterPattern: searchInput.text
        filterPatternSyntax: regExpButton.checked ? CommonCPP.SGSortFilterProxyModel.RegExp : CommonCPP.SGSortFilterProxyModel.FixedString
        caseSensitive: caseSensButton.checked ? true : false
        filterRole: "message"
        sortRole: "rowIndex"
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
            icon.source: "qrc:/sgimages/folder-open.svg"
            iconSize: defaultIconSize
            backgroundOnlyOnHovered: false
            padding: buttonPadding
            hintText: "Open file"

            onClicked:  {
                getFilePath(function(path) {
                    filePath = path
                    var errorString = logFilesModel.populateModel(CommonCPP.SGUtilsCpp.urlToLocalFile(filePath))
                    fileLoaded = true
                    if (errorString.length > 0) {
                        fileLoaded = false
                        SGWidgets.SGDialogJS.showMessageDialog(
                                    root,
                                    SGWidgets.SGMessageDialog.Error,
                                    qsTr("File not opened"),
                                    "Cannot open file with path\n\n" + CommonCPP.SGUtilsCpp.urlToLocalFile(filePath)  + "\n\n" + errorString)
                        filePath = ""
                    }
                })
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
                    if (SGWidgets.SGSettings.fontPixelSize <= fontMaxSize && SGWidgets.SGSettings.fontPixelSize > fontMinSize) {
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
                    if (SGWidgets.SGSettings.fontPixelSize < fontMaxSize && SGWidgets.SGSettings.fontPixelSize >= fontMinSize) {
                        ++SGWidgets.SGSettings.fontPixelSize
                    }
                }
            }
        }

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
            focus: false
            leftIconSource: "qrc:/sgimages/zoom.svg"

            onTextChanged: {
                searchingMode = true
                originalModelWrapper.height = contentView.height/1.5
                if (searchInput.text == ""){
                    searchingMode = false
                    originalModelWrapper.height = contentView.height
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

    SGWidgets.SGText {
        id: midtext
        anchors.centerIn: logViewerMain
        text: qsTr("Press Open file to open a log file")
        fontSizeMultiplier: 2
        visible: fileLoaded == false
    }

    SGWidgets.SGSplitView {
        id: sidePanelSplitView
        anchors {
            top: buttonRowRightButtons.bottom
            topMargin: 5
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        orientation: Qt.Horizontal
        visible: fileLoaded

        onResizingChanged: {
            sidePanelWidth = sidePanel.width
        }

        Item {
            id: sidePanel
            anchors.right: contentView.left
            anchors.rightMargin: sidePanelShown ? 4 : 0
            width: sidePanelWidth
            clip: true
            visible: sidePanelShown
            Layout.minimumWidth: 150

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
                anchors.top: columnFilterButton.bottom
                anchors.left: sidePanel.left
                topPadding: 5
                leftPadding: 5
                rightPadding: 5

                SGWidgets.SGCheckBox {
                    id: checkBoxTs
                    text: qsTr("Timestamp")
                    font.family: StrataFonts.Fonts.inconsolata
                    checked: timestampColumnVisible
                }

                SGWidgets.SGCheckBox {
                    id: checkBoxPid
                    text: qsTr("PID")
                    font.family: StrataFonts.Fonts.inconsolata
                    checked: pidColumnVisible
                }

                SGWidgets.SGCheckBox {
                    id: checkBoxTid
                    text: qsTr("TID")
                    font.family: StrataFonts.Fonts.inconsolata
                    checked: tidColumnVisible
                }

                SGWidgets.SGCheckBox {
                    id: checkBoxLevel
                    text: qsTr("Level")
                    font.family: StrataFonts.Fonts.inconsolata
                    checked: levelColumnVisible
                }

                SGWidgets.SGCheckBox {
                    id: checkBoxMessage
                    text: qsTr("Message")
                    font.family: StrataFonts.Fonts.inconsolata
                    checked: true
                    enabled: !checked
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
                    id: originalModelWrapper
                    height: searchingMode ? parent.height/1.5 : parent.height
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
                    startAnimation: proxyModelWrapper.activeFocus
                }

                Rectangle {
                    height: parent.height - originalModelWrapper.height
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: sidePanelShown ? 4 : 0
                    Layout.minimumHeight: parent.height/4
                    border.color: SGWidgets.SGColorsJS.TANGO_BUTTER1
                    border.width: 2
                    visible: searchingMode

                    LogListView {
                        id: proxyModelWrapper
                        anchors.fill: parent
                        anchors.leftMargin: sidePanelShown ? -2 : 2
                        anchors.margins: 2
                        model: logFilesModelProxy
                        visible: searchingMode

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

                        onCurrentItemChanged: {
                            var sourceIndex = logFilesModelProxy.mapIndexToSource(index)
                            originalModelWrapper.positionViewAtIndex(sourceIndex, ListView.Center)
                            originalModelWrapper.currentIndex = sourceIndex
                        }
                    }
                }
            }
        }
    }
}
