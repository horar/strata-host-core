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
            topMargin: 20
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

    Rectangle {
        anchors.fill: listLog
        color: "black"
        opacity: 0.15
    }

    Rectangle {
        id: topBar
        width: parent.width
        height: 20
        anchors {
            top: buttonRow.bottom
            left: parent.left
            right: parent.right
            topMargin: 20
        }
        visible: fileLoaded
        color: "black"
        opacity: 0.65

        Row {
            SGWidgets.SGText {
                id: topBarText
                width: parent.width
                color: "white"
                text: "              Timestamp                      PID               TID          Level     Message"
            }
        }
    }

    ListView {
        id: listLog
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
        delegate: SGWidgets.SGText {
            id: content
            width: listLog.width
            text: "   " + model.timestamp + "   " + model.pid + "   " + model.tid + "   " + model.type + "   " + model.message
            elide: Text.ElideRight
        }
    }
}
