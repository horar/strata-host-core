import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.fonts 1.0 as StrataFonts
import tech.strata.logviewer.models 1.0 as LogViewModels

Item {
    id: logViewerMain

    property bool fileLoaded: false
    property string filePath
    property alias linesCount: logFilesModel.count
    property int cellWidthSpacer: 6
    property int cellHeightSpacer: 6

    LogViewModels.LogModel {
        id: logFilesModel
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            id:fileDialog
            folder: shortcuts.documents
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
            iconSize: 30
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
                iconSize: 30
                backgroundOnlyOnHovered: false

                onClicked:  {
                    if (SGWidgets.SGSettings.fontPixelSize <= 24 && SGWidgets.SGSettings.fontPixelSize > 8) {
                        SGWidgets.SGSettings.fontPixelSize --
                    }
                }
            }

            SGWidgets.SGIconButton {
                icon.source: "qrc:/images/uppercase-a.svg"
                backgroundOnlyOnHovered: false
                iconSize: 30

                onClicked:  {
                    if (SGWidgets.SGSettings.fontPixelSize < 24 && SGWidgets.SGSettings.fontPixelSize >= 8) {
                        SGWidgets.SGSettings.fontPixelSize ++
                    }
                }
            }
        }
    }

    SGWidgets.SGText {
        id: midtext
        anchors.centerIn: listLog
        text: qsTr("Press Open file to open a log file")
        fontSizeMultiplier: 2
        visible: fileLoaded == false
    }

    //fontMetrics.boundingRect(text) does not re-evaluate itself upon changing the font size
    TextMetrics {
        id: textMetricsTs
        font: timestampHeaderText.font
        text: "9999-99-99999:99:99.999+99:999"
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
        id: textMetricsMsg
        font: timestampHeaderText.font
        text: "9999-99-99999:99:99.999+99:999"
    }

    Rectangle {
        id: topBar
        anchors.fill: header
        visible: fileLoaded
        color: "black"
        opacity: 0.2
    }

    Row {
        id: header
        anchors {
            bottom: listLog.top
        }
        visible: fileLoaded

        Item {
            id: tsHeader
            height: timestampHeaderText.contentHeight + cellHeightSpacer
            width: textMetricsTs.boundingRect.width + cellWidthSpacer

            SGWidgets.SGText {
                id: timestampHeaderText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                font.family: StrataFonts.Fonts.inconsolata
                text: qsTr("Timestamp")
            }
        }

        Item {
            id: pidHeader
            height: pidHeaderText.contentHeight + cellHeightSpacer
            width: textMetricsPid.boundingRect.width + cellWidthSpacer

            SGWidgets.SGText {
                id: pidHeaderText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                font.family: StrataFonts.Fonts.inconsolata
                text: qsTr("PID")
            }
        }

        Item {
            id: tidHeader
            height: tidHeaderText.contentHeight + cellHeightSpacer
            width: textMetricsTid.boundingRect.width + cellWidthSpacer

            SGWidgets.SGText {
                id: tidHeaderText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                font.family: StrataFonts.Fonts.inconsolata
                text: qsTr("TID")
            }
        }

        Item {
            id: levelHeader
            height: levelHeaderText.contentHeight + cellHeightSpacer
            width: textMetricsLevel.boundingRect.width + cellWidthSpacer

            SGWidgets.SGText {
                id: levelHeaderText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                font.family: StrataFonts.Fonts.inconsolata
                text: qsTr("Level")
            }
        }
        Item {
            id: msgHeader
            height: levelHeaderText.contentHeight + 6
            width: listLog.width - levelHeader.x - levelHeader.width

            SGWidgets.SGText {
                id: messageHeaderText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                font.family: StrataFonts.Fonts.inconsolata
                text: qsTr("Message")
            }
        }
    }

    ListView {
        id: listLog
        spacing: 1
        anchors {
            top: buttonRow.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            topMargin: 40
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
                }

                SGWidgets.SGText {
                    id: pid
                    width:pidHeader.width;
                    font.family: StrataFonts.Fonts.inconsolata
                    text: model.pid
                }

                SGWidgets.SGText {
                    id: tid
                    width:tidHeader.width
                    font.family: StrataFonts.Fonts.inconsolata
                    text: model.tid
                }

                SGWidgets.SGText {
                    id: level
                    width:levelHeader.width
                    font.family: StrataFonts.Fonts.inconsolata
                    text: model.level
                }

                SGWidgets.SGText {
                    id: msg
                    width: msgHeader.width
                    font.family: StrataFonts.Fonts.inconsolata
                    text: model.message
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                }
            }
        }
    }
}
