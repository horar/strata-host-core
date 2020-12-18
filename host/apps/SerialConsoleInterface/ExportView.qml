import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.logger 1.0
import QtQuick.Dialogs 1.3
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.fonts 1.0
import tech.strata.theme 1.0

FocusScope {
    id: exportView

    property string exportFilePath
    property string autoExportFilePath
    property int baseSpacing: 10

    InfoPopup {
        id: infoPopup
    }

    FocusScope {
        id: content
        anchors {
            fill: parent
            margins: baseSpacing
        }

        focus: true

        Column {
            id: exportWrapper
            spacing: baseSpacing

            SGWidgets.SGText {
                text: "Scrollback Export"
                fontSizeMultiplier: 2.0
                font.bold: true
            }

            SGWidgets.SGFileSelector {
                id: exportPathSelector
                width: content.width
                hasHelperText: false
                filePath: model.platform.scrollbackModel.exportFilePath
                label: "Output File"
                dialogLabel: "Select Export File"
                dialogSelectExisting: false
                dialogDefaultSuffix: "txt"
                focus: true
            }

            SGWidgets.SGTag {
                id: exportErrorTag

                font.bold: true
                textColor: "white"
                color: TangoTheme.palette.error
            }

            SGWidgets.SGButton {
                text: "Export"

                onClicked: {
                    exportErrorTag.text = ""
                    var errorString = model.platform.scrollbackModel.exportToFile(exportPathSelector.filePath)
                    if (errorString.length > 0) {
                        exportErrorTag.text = errorString
                        infoPopup.showFailed("Export Failed")
                        console.error(Logger.sciCategory, "failed to export content into", exportPathSelector.filePath)

                    } else {
                        infoPopup.showSuccess("Export Done")
                        console.log(Logger.sciCategory, "content exported into", exportPathSelector.filePath)
                    }
                }
            }
        }

        Rectangle {
            id: divider
            anchors {
                top: exportWrapper.bottom
                topMargin: baseSpacing
            }

            width: parent.width
            height: 1
            color: "black"
            opacity: 0.4
        }

        Item {
            id: autoExportWrapper
            anchors {
                top: divider.bottom
                topMargin: baseSpacing
            }

            width: childrenRect.width
            height: childrenRect.height


            SGWidgets.SGText {
                id: autoExportTitle
                text: "Continuous Scrollback Export"
                fontSizeMultiplier: 2.0
                font.bold: true
            }

            SGWidgets.SGTag {
                anchors {
                    left: autoExportTitle.right
                    leftMargin: 10
                    verticalCenter: autoExportTitle.verticalCenter
                }

                text: "ACTIVE"
                font.bold: true
                textColor: "white"
                color: TangoTheme.palette.plum1
                visible: model.platform.scrollbackModel.autoExportIsActive
            }

            SGWidgets.SGText {
                id: autoExportSubTitle
                anchors {
                    top: autoExportTitle.bottom
                    topMargin: 2
                }
                text: "Messages are appended into file automatically"
            }


            SGWidgets.SGFileSelector {
                id: autoExportPathSelector
                width: content.width
                anchors {
                    top: autoExportSubTitle.bottom
                    topMargin: baseSpacing
                }

                hasHelperText: false
                filePath: model.platform.scrollbackModel.autoExportFilePath
                label: "Output File"
                enabled: model.platform.scrollbackModel.autoExportIsActive === false

                dialogLabel: "Select Export File"
                dialogSelectExisting: false
                dialogDefaultSuffix: "txt"
            }

            SGWidgets.SGTag {
                id: autoExportErrorTag
                anchors {
                    top: autoExportPathSelector.bottom
                    topMargin: baseSpacing
                }

                text: model.platform.scrollbackModel.autoExportErrorString
                font.bold: true
                textColor: "white"
                color: TangoTheme.palette.error
            }

            SGWidgets.SGButton {
                anchors {
                    top: autoExportErrorTag.bottom
                    topMargin: baseSpacing
                }

                text: model.platform.scrollbackModel.autoExportIsActive ? "Stop" : "Start"
                onClicked: {
                    if (model.platform.scrollbackModel.autoExportIsActive) {
                        model.platform.scrollbackModel.stopAutoExport()
                    } else {
                        model.platform.scrollbackModel.startAutoExport(autoExportPathSelector.filePath)
                    }
                }
            }
        }

        SGWidgets.SGButton {
            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            text: "Back"
            icon.source: "qrc:/sgimages/chevron-left.svg"
            onClicked: {
                closeView()
            }
        }
    }

    Component {
        id: fileDialogComponent
        FileDialog {
            title: "Select File"
            //"file:" scheme has length of 5
            folder: folderRequested.length > 5 ? folderRequested : shortcuts.documents

            property string folderRequested
        }
    }

    function closeView() {
        model.platform.scrollbackModel.clearAutoExportError()
        StackView.view.pop();
    }
}
