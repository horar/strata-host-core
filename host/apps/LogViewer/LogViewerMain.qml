import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.fonts 1.0 as StrataFonts
import tech.strata.logviewer.models 1.0 as LogViewModels
import Qt.labs.settings 1.1 as QtLabsSettings

Item {
    id: logViewerMain

    property bool fileLoaded: false
    property string filePath
    property alias linesCount: logFilesModel.count
    property int cellWidthSpacer: 6
    property int cellHeightSpacer: 6
    property int defaultIconSize: 30
    property int fontMinSize: 8
    property int fontMaxSize: 24
    property string lastOpenedFolder: ""
    property int checkBoxSpacer: 60
    property int handleSpacer: 5

    property bool visibleTs: true
    property bool visibleTid: true
    property bool visiblePid: true
    property bool visibleLvl: true
    property bool visibleMsg: true

    property int checkBoxTs: 2
    property int checkBoxPid: 2
    property int checkBoxTid: 2
    property int checkBoxLvl: 2
    property int checkBoxMsg: 2

    LogViewModels.LogModel {
        id: logFilesModel
    }

    QtLabsSettings.Settings {
        category: "app"

        property alias lastOpenedFolder: logViewerMain.lastOpenedFolder
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

    Row {
        id: buttonRow
        spacing: 10
        anchors {
            top: parent.top
            left: parent.left
        }

        SGWidgets.SGIconButton {
            icon.source: "qrc:/sgimages/folder-open.svg"
            iconSize: defaultIconSize
            backgroundOnlyOnHovered: false

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
            spacing: 1
            SGWidgets.SGIconButton {
                icon.source: "qrc:/images/uppercase-a-small.svg"
                iconSize: defaultIconSize
                backgroundOnlyOnHovered: false

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

                onClicked:  {
                    if (SGWidgets.SGSettings.fontPixelSize < fontMaxSize && SGWidgets.SGSettings.fontPixelSize >= fontMinSize) {
                        ++SGWidgets.SGSettings.fontPixelSize
                    }
                }
            }
        }
    }

    SGWidgets.SGText {
        id: midtext
        anchors.centerIn: logViewerMain
        text: qsTr("Press Open file to open a log file")
        fontSizeMultiplier: 2
        visible: fileLoaded == false
    }

    //fontMetrics.boundingRect(text) does not re-evaluate itself upon changing the font size
    TextMetrics {
        id: textMetricsTs
        font: timestampHeaderText.font
        text: "9999-99-99999:99:99.999+99:9999"
    }

    TextMetrics {
        id: textMetricsPid
        font: timestampHeaderText.font
        text: "9999999999"
    }

    TextMetrics {
        id: textMetricsTid
        font: timestampHeaderText.font
        text: "9999999999"
    }

    TextMetrics {
        id: textMetricsLevel
        font: timestampHeaderText.font
        text: "[ 99 ]"
    }

    TextMetrics {
        id: textMetricsSidePanel
        font: timestampHeaderText.font
        text: "Show/Hide All"
    }

    TextMetrics {
        id: textMetricsColumnFilter
        font: timestampHeaderText.font
        text: "Column Filter"
    }

    SGWidgets.SGSplitView {
        id: sidepanelSplitView
        anchors {
            top: buttonRow.bottom
            topMargin: 5
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        orientation: Qt.Horizontal
        visible: fileLoaded
        handleDelegate: Rectangle {
            implicitWidth: handleSpacer
            implicitHeight: handleSpacer
            color: "darkgray"
        }

        Item {
            id: sidepanel
            Layout.maximumWidth: textMetricsSidePanel.boundingRect.width + checkBoxSpacer

            Rectangle {
                anchors.fill: parent
                color: "lightgray"
            }

            SGWidgets.SGButton {
                id: columnFilterButton
                anchors.right: sidepanel.right
                width: textMetricsSidePanel.boundingRect.width + checkBoxSpacer
                height: textMetricsColumnFilter.boundingRect.height + cellHeightSpacer
                icon.source: columnFilterMenu.visible ? "qrc:/sgimages/chevron-down.svg" : "qrc:/sgimages/chevron-right.svg"
                iconSize: textMetricsColumnFilter.boundingRect.height
                text: qsTr("Column Filter")
                onClicked: {
                    if (columnFilterMenu.visible == false) { columnFilterMenu.visible = true }
                    else columnFilterMenu.visible = false
                }
            }

            Column {
                id: columnFilterMenu
                anchors.top: columnFilterButton.bottom
                anchors.right: sidepanel.right
                topPadding: 5
                leftPadding: 5
                rightPadding: 5
                visible: false
                ButtonGroup {
                    id: sidepanelGroup
                    exclusive: false
                    checkState: columnBox.checkState
                }
                SGWidgets.SGCheckBox {
                    id: columnBox
                    text: qsTr("Show/Hide All")
                    checkState: sidepanelGroup.checkState
                    font.family: StrataFonts.Fonts.inconsolata
                    nextCheckState: function() {
                        if (checkState == Qt.Checked) {
                            timestampHeaderText.visible = false
                            pidHeaderText.visible = false
                            tidHeaderText.visible = false
                            levelHeaderText.visible = false
                            messageHeaderText.visible = false
                            visibleTs = false
                            visibleLvl = false
                            visibleMsg = false
                            visibleTid = false
                            visiblePid = false
                            return Qt.Unchecked

                        } else { timestampHeaderText.visible = true
                            pidHeaderText.visible = true
                            tidHeaderText.visible = true
                            levelHeaderText.visible = true
                            messageHeaderText.visible = true
                            visibleTs = true
                            visibleLvl = true
                            visibleMsg = true
                            visiblePid = true
                            visibleTid = true
                        }
                        return Qt.Checked
                    }
                }

                SGWidgets.SGCheckBox {
                    id: chckTs
                    text: qsTr("Timestamp")
                    font.family: StrataFonts.Fonts.inconsolata
                    ButtonGroup.group: sidepanelGroup
                    checkState: checkBoxTs
                    nextCheckState: function() {
                        if (checkState == Qt.Checked) {
                            timestampHeaderText.visible = false
                            visibleTs = false
                            return Qt.Unchecked

                        } else timestampHeaderText.visible = true
                        visibleTs = true
                        return Qt.Checked
                    }
                }

                SGWidgets.SGCheckBox {
                    id: chckPid
                    text: qsTr("PID")
                    font.family: StrataFonts.Fonts.inconsolata
                    ButtonGroup.group: sidepanelGroup
                    checkState: checkBoxPid
                    nextCheckState: function() {
                        if (checkState == Qt.Checked) {
                            pidHeaderText.visible = false
                            visiblePid = false
                            return Qt.Unchecked

                        } else pidHeaderText.visible = true
                        visiblePid = true
                        return Qt.Checked
                    }
                }

                SGWidgets.SGCheckBox {
                    id: chckTid
                    text: qsTr("TID")
                    font.family: StrataFonts.Fonts.inconsolata
                    ButtonGroup.group: sidepanelGroup
                    checkState: checkBoxTid
                    nextCheckState: function() {
                        if (checkState == Qt.Checked) {
                            tidHeaderText.visible = false
                            visibleTid = false
                            return Qt.Unchecked

                        } else tidHeaderText.visible = true
                        visibleTid = true
                        return Qt.Checked
                    }
                }

                SGWidgets.SGCheckBox {
                    id: chckLvl
                    text: qsTr("Level")
                    font.family: StrataFonts.Fonts.inconsolata
                    ButtonGroup.group: sidepanelGroup
                    checkState: checkBoxLvl
                    nextCheckState: function() {
                        if (checkState == Qt.Checked) {
                            levelHeaderText.visible = false
                            visibleLvl = false
                            return Qt.Unchecked

                        } else levelHeaderText.visible = true
                        visibleLvl = true
                        return Qt.Checked
                    }
                }

                SGWidgets.SGCheckBox {
                    id: chckMsg
                    text: qsTr("Message")
                    font.family: StrataFonts.Fonts.inconsolata
                    ButtonGroup.group: sidepanelGroup
                    checkState: checkBoxMsg
                    nextCheckState: function() {
                        if (checkState == Qt.Checked) {
                            messageHeaderText.visible = false
                            visibleMsg = false
                            return Qt.Unchecked

                        } else messageHeaderText.visible = true
                        visibleMsg = true
                        return Qt.Checked
                    }
                }
            }
        }

        Item {
            id: contentView

            ListView {
                id: listLog
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                visible: fileLoaded
                model:logFilesModel
                clip: true

                ScrollBar.vertical: ScrollBar {
                    minimumSize: 0.1
                    policy: ScrollBar.AlwaysOn
                }
                delegate: Item {
                    width: parent.width
                    height: row.height

                    Rectangle {
                        id: cell
                        anchors.fill: parent
                        color: "white"
                    }

                    Row {
                        id: row

                        SGWidgets.SGText {
                            id: ts
                            width: tsHeader.width
                            font.family: StrataFonts.Fonts.inconsolata
                            text: model.timestamp
                            leftPadding: handleSpacer
                            visible: visibleTs
                        }

                        SGWidgets.SGText {
                            id: pid
                            width: pidHeader.width
                            font.family: StrataFonts.Fonts.inconsolata
                            text: model.pid
                            leftPadding: handleSpacer
                            visible: visiblePid
                        }

                        SGWidgets.SGText {
                            id: tid
                            width: tidHeader.width
                            font.family: StrataFonts.Fonts.inconsolata
                            text: model.tid
                            leftPadding: handleSpacer
                            visible: visibleTid
                        }

                        SGWidgets.SGText {
                            id: level
                            width: levelHeader.width
                            font.family: StrataFonts.Fonts.inconsolata
                            text: model.level
                            leftPadding: handleSpacer
                            visible: visibleLvl
                        }

                        SGWidgets.SGText {
                            id: msg
                            width: msgHeader.width - sidepanel.width
                            font.family: StrataFonts.Fonts.inconsolata
                            text: model.message
                            leftPadding: handleSpacer
                            visible: visibleMsg
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                    }
                }
            }

            Rectangle {
                id: topBar
                anchors {
                    top:header.top
                    bottom: header.bottom
                    left: header.left
                    right: listLog.right
                }
                visible: fileLoaded
                color: "black"
                opacity: 0.2
            }

            Row {
                id: header
                visible: fileLoaded

                Item {
                    id: tsHeader
                    height: timestampHeaderText.contentHeight + cellHeightSpacer
                    width: textMetricsTs.boundingRect.width + cellWidthSpacer
                    visible: visibleTs

                    SGWidgets.SGText {
                        id: timestampHeaderText
                        anchors {
                            left: tsHeader.left
                            verticalCenter: parent.verticalCenter
                        }
                        font.family: StrataFonts.Fonts.inconsolata
                        text: qsTr("Timestamp")
                        leftPadding: handleSpacer
                    }
                }

                Item {
                    id: pidHeader
                    height: pidHeaderText.contentHeight + cellHeightSpacer
                    width: textMetricsPid.boundingRect.width + cellWidthSpacer
                    visible: visiblePid

                    SGWidgets.SGText {
                        id: pidHeaderText
                        anchors {
                            left: pidHeader.left
                            verticalCenter: parent.verticalCenter
                        }
                        font.family: StrataFonts.Fonts.inconsolata
                        text: qsTr("PID")
                        leftPadding: handleSpacer
                    }
                }

                Item {
                    id: tidHeader
                    height: tidHeaderText.contentHeight + cellHeightSpacer
                    width: textMetricsTid.boundingRect.width + cellWidthSpacer
                    visible: visibleTid

                    SGWidgets.SGText {
                        id: tidHeaderText
                        anchors {
                            left: tidHeader.left
                            verticalCenter: parent.verticalCenter
                        }
                        font.family: StrataFonts.Fonts.inconsolata
                        text: qsTr("TID")
                        leftPadding: handleSpacer
                    }
                }

                Item {
                    id: levelHeader
                    height: levelHeaderText.contentHeight + cellHeightSpacer
                    width: textMetricsLevel.boundingRect.width + cellWidthSpacer
                    visible: visibleLvl

                    SGWidgets.SGText {
                        id: levelHeaderText
                        anchors {
                            left: levelHeader.left
                            verticalCenter: parent.verticalCenter
                        }
                        font.family: StrataFonts.Fonts.inconsolata
                        text: qsTr("Level")
                        leftPadding: handleSpacer
                    }
                }
                Item {
                    id: msgHeader
                    height: levelHeaderText.contentHeight + cellHeightSpacer
                    width: root.width - levelHeader.x - levelHeader.width - handleSpacer
                    visible: visibleMsg

                    SGWidgets.SGText {
                        id: messageHeaderText
                        anchors {
                            left: msgHeader.left
                            verticalCenter: parent.verticalCenter
                        }
                        font.family: StrataFonts.Fonts.inconsolata
                        text: qsTr("Message")
                        leftPadding: handleSpacer
                    }
                }
            }
        }
    }
}
