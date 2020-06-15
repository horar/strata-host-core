import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.flasherConnector 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.sci 1.0 as Sci
import tech.strata.logger 1.0

FocusScope {
    id: programDeviceView

    property string firmwareBinaryPath
    property int processingStatus: ProgramDeviceView.Setup
    property bool doBackup: true

    property int backupChunks: 0
    property real programProgress: 0.0
    property real programBackupProgress: 0.0
    property int baseSpacing: 16

    property bool editable: processingStatus === ProgramDeviceView.Setup
                            || processingStatus === ProgramDeviceView.ProgramSucceed
                            || processingStatus === ProgramDeviceView.ProgramFailed

    enum ProcessingStatus {
        Setup,
        Preparation,
        FirmwareBackup,
        ProgramInProgress,
        ProgramBackupInProgress,
        ProgramSucceed,
        ProgramFailed
    }

    Connections {
        target: model.platform

        onFlasherProgramProgress: {
            programProgress = chunk / total
        }

        onFlasherBackupProgress: {
            backupChunks = chunk;
        }

        onFlasherRestoreProgress: {
            programBackupProgress = chunk / total
        }

        onFlasherOperationStateChanged: {
            if (operation === FlasherConnector.Preparation ) {
                if (state === FlasherConnector.Started) {
                    processingStatus = ProgramDeviceView.Preparation
                    preparationNode.nodeState = StatusNode.NotSet
                } else if (state === FlasherConnector.Finished) {
                    preparationNode.nodeState = StatusNode.Succeed
                } else if (state === FlasherConnector.Failed) {
                    preparationNode.nodeState = StatusNode.Failed
                    preparationNode.subText = "Error: " + errorString
                }
            } else if (operation === FlasherConnector.BackupBeforeFlash) {
                if (state === FlasherConnector.Started) {
                    processingStatus = ProgramDeviceView.FirmwareBackup
                    backupNode.nodeState = StatusNode.NotSet
                } else if (state === FlasherConnector.Finished) {
                    backupNode.nodeState = StatusNode.Succeed
                } else if (state === FlasherConnector.Failed) {
                    backupNode.nodeState = StatusNode.Failed
                    backupNode.subText = "Error: " + errorString
                }
            } else if (operation === FlasherConnector.Flash) {
                if (state === FlasherConnector.Started) {
                    processingStatus = ProgramDeviceView.ProgramInProgress
                    programNode.nodeState = StatusNode.NotSet
                } else if (state === FlasherConnector.Finished) {
                    programNode.nodeState = StatusNode.Succeed
                } else if (state === FlasherConnector.Failed) {
                    programNode.nodeState = StatusNode.Failed
                    programNode.subText = "Error: " + errorString
                }
            } else if (operation === FlasherConnector.RestoreFromBackup) {
                if (state === FlasherConnector.Started) {
                    processingStatus = ProgramDeviceView.ProgramBackupInProgress
                    programBackupNode.nodeState = StatusNode.NotSet
                    programBackupNode.visible = true
                } else if (state === FlasherConnector.Finished) {
                    programBackupNode.nodeState = StatusNode.Succeed
                } else if (state === FlasherConnector.Failed) {
                    programBackupNode.nodeState = StatusNode.Failed
                    programBackupNode.subText = "Error: " + errorString
                }
            } else {
                console.warn(Logger.sciCategory, "unknown state")
            }
        }

        onFlasherFinished: {
            setFinalState(result)
        }
    }

    FocusScope {
        id: content
        anchors {
            fill: parent
            margins: baseSpacing
        }

        focus: true

        SGWidgets.SGText {
            id: title
            anchors {
                left: parent.left
            }

            text: "Program New Firmware"
            fontSizeMultiplier: 2.0
            font.bold: true
        }

        Row {
            id: firmwareRow
            anchors {
                top: title.bottom
                topMargin: baseSpacing
            }

            spacing: baseSpacing
            SGWidgets.SGTextFieldEditor {
                id: firmwarePathEdit

                label: qsTr("Firmware data file")
                itemWidth: content.width - selectButton.width - baseSpacing
                inputValidation: true
                enabled: programDeviceView.editable
                placeholderText: "Select path..."
                focus: true
                text: firmwareBinaryPath
                onTextChanged: {
                    firmwareBinaryPath = text
                }

                Binding {
                    target: firmwarePathEdit
                    property: "text"
                    value: firmwareBinaryPath
                }

                function inputValidationErrorMsg() {
                    if (text.length === 0) {
                        return qsTr("Firmware data file is required")
                    } else if (!CommonCpp.SGUtilsCpp.isFile(text)) {
                        return qsTr("Firmware data file path does not refer to a file")
                    }

                    return ""
                }
            }

            SGWidgets.SGButton {
                id: selectButton
                y: firmwarePathEdit.itemY + (firmwarePathEdit.item.height - height) / 2

                enabled: programDeviceView.editable
                text: "Select"
                onClicked: {
                    selectFirmwareBinary()
                }
            }
        }

        SGWidgets.SGCheckBox {
            id: backupCheckbox
            anchors {
                top: firmwareRow.bottom
            }

            leftPadding: 0
            text: "Backup firmware before programming"
            onCheckStateChanged: {
                programDeviceView.doBackup = checked
            }

            Binding {
                target: backupCheckbox
                property: "checked"
                value: programDeviceView.doBackup
            }
        }

        Column {
            id: statusColumn
            anchors {
                top: backupCheckbox.bottom
                topMargin: baseSpacing
            }

            StatusNode {
                id: setupNode
                text: "Setup"
                isFirst: true
                highlight: processingStatus === ProgramDeviceView.Setup
            }

            StatusNode {
                id: preparationNode
                text: "Preparation"

                highlight: processingStatus === ProgramDeviceView.Preparation
            }

            StatusNode {
                id: backupNode
                visible: doBackup
                text: {
                    var t = "Backup"
                    if (processingStatus !== ProgramDeviceView.Setup) {
                        t += " (" + backupChunks + " chunk" + (backupChunks == 1 ? "" : "s")  + " completed)"
                    }
                    return t
                }
                highlight: processingStatus === ProgramDeviceView.FirmwareBackup
            }

            StatusNode {
                id: programNode
                text:  {
                    var t = "Program"
                    if (processingStatus !== ProgramDeviceView.Setup) {
                        t += " (" + Math.floor(programProgress * 100) + "% completed)"
                    }
                    return t
                }
                highlight: processingStatus === ProgramDeviceView.ProgramInProgress
            }

            StatusNode {
                id: programBackupNode
                text:  "Restore (" + Math.floor(programBackupProgress * 100) + "% completed)"
                highlight: processingStatus === ProgramDeviceView.ProgramBackupInProgress
                visible: false
            }

            StatusNode {
                id: finishedNode
                text: {
                    if (nodeState === StatusNode.Failed) {
                        return "Failed"
                    }

                    "Done"
                }
                isFinal: true
                highlight: processingStatus === ProgramDeviceView.ProgramSucceed
                           || processingStatus === ProgramDeviceView.ProgramFailed
            }
        }

        Row {
            spacing: baseSpacing
            anchors {
                top: statusColumn.bottom
                topMargin: 2*baseSpacing
            }
            SGWidgets.SGButton {
                text: "Back"
                icon.source: "qrc:/sgimages/chevron-left.svg"
                enabled: programDeviceView.editable
                onClicked: {
                    closeView()
                }
            }

            SGWidgets.SGButton {
                id: programButton
                text: "Program"
                icon.source: "qrc:/sgimages/chip-flash.svg"
                enabled: programDeviceView.editable
                         && (model.platform.status === Sci.SciPlatform.Ready
                             || model.platform.status === Sci.SciPlatform.NotRecognized)
                onClicked: {
                    var error = firmwarePathEdit.inputValidationErrorMsg()
                    if (error.length > 0) {
                        SGWidgets.SGDialogJS.showMessageDialog(
                                    programDeviceView,
                                    SGWidgets.SGMessageDialog.Error,
                                    "Firmware file not set",
                                    error)
                    } else {
                        startProgramProcess()
                    }
                }
            }
        }
    }

    function startProgramProcess() {
        processingStatus = ProgramDeviceView.Setup

        setupNode.nodeState = StatusNode.NotSet
        preparationNode.nodeState = StatusNode.NotSet
        backupNode.nodeState = StatusNode.NotSet
        programNode.nodeState = StatusNode.NotSet
        programBackupNode.nodeState = StatusNode.NotSet
        finishedNode.nodeState = StatusNode.NotSet

        setupNode.subText = ""
        preparationNode.subText = ""
        backupNode.subText = ""
        programNode.subText = ""
        programBackupNode.subText = ""
        finishedNode.subText = ""

        programBackupNode.visible = false

        backupChunks = 0
        programProgress = 0.0
        programBackupProgress = 0.0

        var ok = model.platform.programDevice(firmwareBinaryPath, doBackup)
        if (ok) {
            setupNode.nodeState = StatusNode.Succeed
        } else {
            setupNode.nodeState = StatusNode.Failed
            setupNode.subText = "Operation cannot start"
            setFinalState(FlasherConnector.Unsuccess)
        }
    }

    function setFinalState(result) {
        if (result === FlasherConnector.Success) {
            processingStatus = ProgramDeviceView.ProgramSucceed
            finishedNode.nodeState = StatusNode.Succeed
            finishedNode.subText = "New firmware is ready."
        } else if (result === FlasherConnector.Unsuccess) {
            processingStatus = ProgramDeviceView.ProgramFailed
            finishedNode.nodeState = StatusNode.Failed
            finishedNode.subText = "New firmware was not programmed, but original firmware is available."
        } else if (result === FlasherConnector.Failure) {
            processingStatus = ProgramDeviceView.ProgramFailed
            finishedNode.nodeState = StatusNode.Failed
            finishedNode.subText = "Please reconnect the board and program it again."
        }
    }

    function selectFirmwareBinary() {
        var folder = firmwareBinaryPath.length > 0 ? firmwareBinaryPath : Sci.Settings.lastSelectedFirmware
        var dialog = SGWidgets.SGDialogJS.createDialogFromComponent(
                    programDeviceView,
                    fileDialogComponent,
                    {
                        "title": "Select Firmware Binary",
                        "nameFilters": ["Binary files (*.bin)","All files (*)"],
                        "folderRequested": CommonCpp.SGUtilsCpp.pathToUrl(CommonCpp.SGUtilsCpp.fileAbsolutePath(folder)),
                    })

        dialog.accepted.connect(function() {
            firmwareBinaryPath = CommonCpp.SGUtilsCpp.urlToLocalFile(dialog.fileUrl)
            Sci.Settings.lastSelectedFirmware = firmwareBinaryPath
            dialog.destroy()
        })

        dialog.rejected.connect(function() {
            dialog.destroy()
        })

        dialog.open();
    }

    function closeView() {
        StackView.view.pop();
    }
}
