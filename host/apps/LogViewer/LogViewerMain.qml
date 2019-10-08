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
    property int cellWidthSpacer: 20
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

        SGWidgets.SGButton {
            SGWidgets.SGText {
                anchors.centerIn: parent
                text: qsTr("Open file")
                fontSizeMultiplier: 1
            }

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
        anchors {
            fill: header
        }
        visible: fileLoaded
        color: "black"
        opacity: 0.1
    }

    Row {
        id: header
        anchors {
            top: buttonRow.bottom
            topMargin: 15
        }
        visible: fileLoaded
        Item {
            id: tsHeader
            width: fontMetrics.boundingRect("9999-99-99999:99:99.999+99:99").width + cellWidthSpacer
            height: timestampHeaderText.contentHeight + cellHeightSpacer
            SGWidgets.SGText {
                id: timestampHeaderText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                text: qsTr("Timestamp")
            }
        }

        Item {
            id: pidHeader
            width: fontMetrics.boundingRect("9999999999").width + cellWidthSpacer
            height: pidHeaderText.contentHeight + cellHeightSpacer

            SGWidgets.SGText {
                id: pidHeaderText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                text: qsTr("PID")
            }
        }

        Item {
            id: tidHeader
            width: fontMetrics.boundingRect("9999999999").width + cellWidthSpacer
            height: tidHeaderText.contentHeight + cellHeightSpacer

            SGWidgets.SGText {
                id: tidHeaderText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                text: qsTr("TID")
            }
        }

        Item {
            id: levelHeader
            width: fontMetrics.boundingRect("[ 9 ]").width + cellWidthSpacer
            height: levelHeaderText.contentHeight + cellHeightSpacer

            SGWidgets.SGText {
                id: levelHeaderText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
                text: qsTr("Level")
            }
        }
        Item {
            id: msgHeader
            width: listLog.width - levelHeader.x - levelHeader.width
            height: levelHeaderText.contentHeight + 6

            SGWidgets.SGText {
                id: messageHeaderText
                anchors.centerIn: parent
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
