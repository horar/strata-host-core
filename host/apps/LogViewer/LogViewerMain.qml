import QtQuick 2.12
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.logviewer.models 1.0 as LogViewModels

Item {
    id: logViewerMain

    property bool fileLoaded: false
    property string filePath
    property alias numberOfSkippedLines: logFilesModel.numberOfSkippedLines
    property alias linesCount: logFilesModel.count

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

        SGWidgets.SGButton {
            SGWidgets.SGText {
                anchors.centerIn: parent
                text: qsTr("Open file")
                fontSizeMultiplier: 1
            }

            onClicked:  {
                getFilePath(function(path) {
                    filePath = path
                    fileLoaded = logFilesModel.populateModel(CommonCPP.SGUtilsCpp.urlToLocalFile(filePath))
                })
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

    FontMetrics {
        id: fontMetrics
        font: timestampHeaderText.font

    }

    Rectangle {
        id: topBar
        width: parent.width
        height: header.height
        visible: fileLoaded
        anchors {
            fill: header
        }

        color: "black"
        opacity: 0.1
    }

    Row {
        id: header
        visible: fileLoaded
        anchors {
            top: buttonRow.bottom
            topMargin: 15
        }

        Item {
            width: fontMetrics.boundingRect("9999-99-99 99:99:99.999").width + 6
            height: timestampHeaderText.contentHeight + 6
            SGWidgets.SGText {
                id: timestampHeaderText
                anchors.centerIn: parent
                text: "Timestamp"
            }
        }

        Item {
            width: fontMetrics.boundingRect("99999").width + 6
            height: pidHeaderText.contentHeight + 6
            SGWidgets.SGText {
                id: pidHeaderText
                anchors.centerIn: parent
                text: "PID"
            }
        }

        Item {
            width: fontMetrics.boundingRect("999999").width + 6
            height: tidHeaderText.contentHeight + 6
            SGWidgets.SGText {
                id: tidHeaderText
                anchors.centerIn: parent
                text: "TID"
            }
        }

        Item {
            width: fontMetrics.boundingRect("[M9M]").width + 6
            height: levelHeaderText.contentHeight + 6
            SGWidgets.SGText {
                id: levelHeaderText
                anchors.centerIn: parent
                text: "Level"
            }
        }
        Item {
            width: listLog.width - 315
            height: levelHeaderText.contentHeight + 6
            SGWidgets.SGText {
                id: messageHeaderText
                anchors.centerIn: parent
                text: "Message"
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
        delegate:

            Component {
            Item {
                width: parent.width - 15
                height: row.height
                Rectangle {
                    id: cell
                    width: parent.width + 15
                    height: parent.height
                }
                Row {
                    id: row
                    width: parent.width
                    spacing: 6
                    Item {
                        width: 5
                        height: 1
                    }
                    Text {
                        id: ts
                        width: fontMetrics.boundingRect("9999-99-99 99:99:99.999").width
                        text: model.timestamp
                        color: "blue"
                    }
                    Text {
                        id: pid
                        width:fontMetrics.boundingRect("99999").width
                        text: model.pid
                    }
                    Text {
                        id: tid
                        width:fontMetrics.boundingRect("999999").width
                        text: model.tid
                    }
                    Text {
                        id: tpe
                        width:fontMetrics.boundingRect("[M]").width
                        text: model.type
                    }
                    Text {
                        id: msg
                        width: listLog.width-320
                        text: model.message
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    }
                }
            }
        }
    }
}
