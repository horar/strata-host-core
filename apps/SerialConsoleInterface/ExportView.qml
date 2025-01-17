/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    property int baseSpacing: 16

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

            SGWidgets.SGFilePicker {
                id: exportPathPicker
                contextMenuEnabled: true
                width: content.width
                filePath: model.platform.scrollbackModel.exportFilePath
                label: "Output File"
                inputValidation: true
                dialogLabel: "Export to file"
                dialogSelectExisting: false
                dialogDefaultSuffix: "log"
                dialogNameFilters: ["Log files (*.log)", "Text Files (*.txt)", "All files (*)"]
                focus: true

                function inputValidationErrorMsg() {
                    if (filePath.length === 0) {
                        return qsTr("Output file is required")
                    } else if (CommonCpp.SGUtilsCpp.containsForbiddenCharacters(CommonCpp.SGUtilsCpp.fileName(filePath))) {
                        return qsTr("A filename cannot contain any of the following characters: " + CommonCpp.SGUtilsCpp.joinForbiddenCharacters())
                    }

                    return ""
                }
            }

            SGWidgets.SGTag {
                id: exportErrorTag
                font.bold: true
                textColor: "white"
                mask: "A"
                color: TangoTheme.palette.error
                sizeByMask: text.length === 0
            }

            SGWidgets.SGButton {
                text: "Export"

                onClicked: {
                    var error = exportPathPicker.inputValidationErrorMsg()
                    if (error.length > 0) {
                        SGWidgets.SGDialogJS.showMessageDialog(
                                    exportView,
                                    SGWidgets.SGMessageDialog.Error,
                                    "Export Failed",
                                    error)
                    } else {
                        exportErrorTag.text = ""
                        var errorString = model.platform.scrollbackModel.exportToFile(exportPathPicker.filePath)
                        if (errorString.length > 0) {
                            exportErrorTag.text = errorString
                            infoPopup.showFailed("Export Failed")
                            console.error(Logger.sciCategory, "failed to export content into", exportPathPicker.filePath)
                        } else {
                            infoPopup.showSuccess("Export Done")
                            console.log(Logger.sciCategory, "content exported into", exportPathPicker.filePath)
                        }
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
                color: TangoTheme.palette.chameleon2
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


            SGWidgets.SGFilePicker {
                id: autoExportPathPicker
                contextMenuEnabled: true
                width: content.width
                anchors {
                    top: autoExportSubTitle.bottom
                    topMargin: baseSpacing
                }

                filePath: model.platform.scrollbackModel.autoExportFilePath
                label: "Output File"
                inputValidation: true
                enabled: model.platform.scrollbackModel.autoExportIsActive === false

                dialogLabel: "Export to file"
                dialogSelectExisting: false
                dialogDefaultSuffix: "log"
                dialogNameFilters: ["Log files (*.log)", "Text Files (*.txt)", "All files (*)"]

                function inputValidationErrorMsg() {
                    if (filePath.length === 0) {
                        return qsTr("Output file is required")
                    } else if (CommonCpp.SGUtilsCpp.containsForbiddenCharacters(CommonCpp.SGUtilsCpp.fileName(filePath))) {
                        return qsTr("A filename cannot contain any of the following characters: " + CommonCpp.SGUtilsCpp.joinForbiddenCharacters())
                    }

                    return ""
                }
            }

            SGWidgets.SGTag {
                id: autoExportErrorTag
                anchors {
                    top: autoExportPathPicker.bottom
                    topMargin: baseSpacing
                }

                text: {
                    if (model.platform.scrollbackModel.autoExportErrorString) {
                        return "Export Failed: " + model.platform.scrollbackModel.autoExportErrorString
                    }

                    return ""
                }

                font.bold: true
                textColor: "white"
                mask: "A"
                color: TangoTheme.palette.error
                sizeByMask: text.length === 0

            }

            SGWidgets.SGButton {
                id: startExportButton
                anchors {
                    top: autoExportErrorTag.bottom
                    topMargin: baseSpacing
                }

                text: model.platform.scrollbackModel.autoExportIsActive ? "Stop" : "Start"
                onClicked: {
                    var error = autoExportPathPicker.inputValidationErrorMsg()
                    if (error.length > 0) {
                        SGWidgets.SGDialogJS.showMessageDialog(
                                    exportView,
                                    SGWidgets.SGMessageDialog.Error,
                                    "Continuous Export Failed",
                                    error)
                    }

                    else if (model.platform.scrollbackModel.autoExportIsActive) {
                        model.platform.scrollbackModel.stopAutoExport()
                    } else {
                        model.platform.scrollbackModel.startAutoExport(autoExportPathPicker.filePath)
                    }
                }
            }

            SGWidgets.SGButton {
                anchors {
                    top: startExportButton.top
                    left: startExportButton.right
                    leftMargin: 6
                }

                text: "Clear Error"
                visible: model.platform.scrollbackModel.autoExportErrorString.length > 0
                onClicked: model.platform.scrollbackModel.clearAutoExportError()
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
        StackView.view.pop();
    }
}
