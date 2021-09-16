/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.flasherConnector 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.sci 1.0 as Sci
import tech.strata.logger 1.0

FocusScope {
    id: programDeviceView

    property int processingStatus: ProgramDeviceView.Setup
    property bool doBackup: Sci.Settings.backupFirmware

    property int backupProgress: 0
    property int programProgress: 0
    property int programBackupProgress: 0
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
            programProgress = total < 1 ? 0 : Math.floor(chunk / total * 100)
        }

        onFlasherBackupProgress: {
            backupProgress = total < 1 ? 0 : Math.floor(chunk / total * 100)
        }

        onFlasherRestoreProgress: {
            programBackupProgress = total < 1 ? 0 : Math.floor(chunk / total * 100)
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
                } else if (state === FlasherConnector.NoFirmware) {
                    backupNode.nodeState = StatusNode.SucceedWithWarning
                    backupProgress = -1;
                } else if (state === FlasherConnector.BadFirmware) {
                    backupNode.nodeState = StatusNode.SucceedWithWarning
                    backupNode.subText = "Warning: " + errorString
                }
            } else if (operation === FlasherConnector.Flash) {
                if (state === FlasherConnector.Started) {
                    processingStatus = ProgramDeviceView.ProgramInProgress
                    programNode.nodeState = StatusNode.NotSet
                } else if (state === FlasherConnector.Finished) {
                    programNode.nodeState = StatusNode.Succeed
                } else if (state === FlasherConnector.Failed
                           || state === FlasherConnector.BadFirmware) {
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
                } else if (state === FlasherConnector.Failed
                           || state === FlasherConnector.BadFirmware) {
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

        SGWidgets.SGFilePicker {
            id: firmwarePathEdit
            contextMenuEnabled: true
            width: content.width
            anchors {
                top: title.bottom
                topMargin: baseSpacing
            }

            label: qsTr("Firmware data file")
            inputValidation: true
            focus: true
            enabled: programDeviceView.editable
            suggestionModel: Sci.Settings.firmwarePathList

            filePath: {
                if (Sci.Settings.firmwarePathList.length > 0) {
                    return Sci.Settings.firmwarePathList[0]
                }

                return ""
            }

            dialogLabel: "Select Firmware Binary"
            dialogSelectExisting: true
            dialogNameFilters: ["Binary files (*.bin)","All files (*)"]

            function inputValidationErrorMsg() {
                if (filePath.length === 0) {
                    return qsTr("Firmware data file is required")
                } else if (!CommonCpp.SGUtilsCpp.isFile(filePath)) {
                    return qsTr("Firmware data file path does not refer to a file")
                }

                return ""
            }

            function textRoleValue(index) {
                if (index < 0 || index >= Sci.Settings.firmwarePathList.length) {
                    return
                }

                return Sci.Settings.firmwarePathList[index]
            }

            function removeAt(index) {
                if (index < 0 || index >= Sci.Settings.firmwarePathList.length) {
                    return
                }

                Sci.Settings.firmwarePathList.splice(index, 1)
                Sci.Settings.firmwarePathList = Sci.Settings.firmwarePathList
            }
        }

        SGWidgets.SGCheckBox {
            id: backupCheckbox
            anchors {
                top: firmwarePathEdit.bottom
            }

            enabled: programDeviceView.editable
            leftPadding: 0
            text: "Restore original firmware if programming fails"
            onCheckStateChanged: {
                programDeviceView.doBackup = checked
                Sci.Settings.backupFirmware = checked
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
                        if (backupProgress < 0) {
                            t += " (no firmware to backup)"
                        } else {
                            t += " (" + backupProgress + "% completed)"
                        }
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
                        t += " (" + programProgress + "% completed)"
                    }
                    return t
                }
                highlight: processingStatus === ProgramDeviceView.ProgramInProgress
            }

            StatusNode {
                id: programBackupNode
                text:  "Restore (" + programBackupProgress + "% completed)"
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
                        updateFirmwarePathList(firmwarePathEdit.filePath)

                        startProgramProcess(firmwarePathEdit.filePath)
                    }
                }
            }
        }
    }

    function startProgramProcess(firmwarePath) {
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

        backupProgress = 0
        programProgress = 0
        programBackupProgress = 0

        var ok = model.platform.programDevice(firmwarePath, doBackup)
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

    function closeView() {
        StackView.view.pop();
    }

    function updateFirmwarePathList(path) {
        var index = Sci.Settings.firmwarePathList.indexOf(path)
        if (index >= 0) {
            Sci.Settings.firmwarePathList.splice(index, 1)
        }

        Sci.Settings.firmwarePathList.splice(0, 0, path)

        if (Sci.Settings.firmwarePathList.length > Sci.Settings.maxFirmwarePathList) {
            Sci.Settings.firmwarePathList = Sci.Settings.firmwarePathList.slice(0, Sci.Settings.maxFirmwarePathList)
        }

        //to trigger change in qml
        Sci.Settings.firmwarePathList = Sci.Settings.firmwarePathList
    }
}
