import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.flasherConnector 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.sci 1.0 as Sci
import tech.strata.logger 1.0
import Qt.labs.platform 1.1

FocusScope {
    id: saveFirmwareView

    property int processingStatus: SaveFirmwareView.Setup

    property int backupProgress: 0
    property int baseSpacing: 16

    property bool editable: processingStatus === SaveFirmwareView.Setup
                            || processingStatus === SaveFirmwareView.BackupSucceed
                            || processingStatus === SaveFirmwareView.BackupFailed

    enum ProcessingStatus {
        Setup,
        Preparation,
        FirmwareBackup,
        BackupSucceed,
        BackupFailed
    }

    Connections {
        target: model.platform

        onFlasherBackupProgress: {
            backupProgress = total < 1 ? 0 : Math.floor(chunk / total * 100)
        }

        onFlasherOperationStateChanged: {
            if (operation === FlasherConnector.Preparation ) {
                if (state === FlasherConnector.Started) {
                    processingStatus = SaveFirmwareView.Preparation
                    preparationNode.nodeState = StatusNode.NotSet
                } else if (state === FlasherConnector.Finished) {
                    preparationNode.nodeState = StatusNode.Succeed
                } else if (state === FlasherConnector.Failed) {
                    preparationNode.nodeState = StatusNode.Failed
                    preparationNode.subText = "Error: " + errorString
                }
            } else if (operation === FlasherConnector.Backup) {
                if (state === FlasherConnector.Started) {
                    processingStatus = SaveFirmwareView.FirmwareBackup
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
            } else {
                console.warn(Logger.sciCategory, "Unknown state for firmware backup")
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

            text: "Save firmware from device"
            fontSizeMultiplier: 2.0
            font.bold: true
        }

        SGWidgets.SGFilePicker {
            id: saveFirmwarePathEdit
            contextMenuEnabled: true
            width: content.width
            anchors {
                top: title.bottom
                topMargin: baseSpacing
            }

            label: qsTr("Firmware binary file path")
            inputValidation: true
            focus: true
            enabled: saveFirmwareView.editable

            filePath: {
                let fileName = "application"
                if (model.platform.verboseName.length > 0 && model.platform.verboseName !== "Bootloader") {
                    fileName = model.platform.verboseName.replace(/\s+/g,"_")
                }
                if (model.platform.appVersion.length > 0) {
                    fileName = fileName + "_v" + model.platform.appVersion
                }
                fileName = fileName + "_" + currentTimestamp() + ".bin"

                let destination = Sci.Settings.lastSavedFirmwarePath
                if (destination.length === 0) {
                    destination = CommonCpp.SGUtilsCpp.urlToLocalFile(StandardPaths.writableLocation(StandardPaths.DocumentsLocation))
                }

                return CommonCpp.SGUtilsCpp.joinFilePath(destination, fileName)
            }

            dialogLabel: "Select path for firmware binary"
            dialogSelectExisting: false
            dialogDefaultSuffix: "bin"
            dialogNameFilters: ["Binary files (*.bin)","All files (*)"]

            function inputValidationErrorMsg() {
                if (filePath.length === 0) {
                    return qsTr("Path for firmware binary file is required")
                } else if (CommonCpp.SGUtilsCpp.isRelative(filePath)) {
                    return qsTr("Absolute path for firmware binary file is required")
                } else if (CommonCpp.SGUtilsCpp.isFile(filePath)) {
                    return qsTr("Selected file exists, it will be overwritten")
                }

                return ""
            }
        }

        Column {
            id: statusColumn
            anchors {
                top: saveFirmwarePathEdit.bottom
                topMargin: baseSpacing
            }

            StatusNode {
                id: setupNode
                text: "Setup"
                isFirst: true
                highlight: processingStatus === SaveFirmwareView.Setup
            }

            StatusNode {
                id: preparationNode
                text: "Preparation"

                highlight: processingStatus === SaveFirmwareView.Preparation
            }

            StatusNode {
                id: backupNode
                text: {
                    var t = "Save firmware"
                    if (processingStatus !== SaveFirmwareView.Setup) {
                        if (backupProgress < 0) {
                            t += " (no firmware to save)"
                        } else {
                            t += " (" + backupProgress + "% completed)"
                        }
                    }
                    return t
                }
                highlight: processingStatus === SaveFirmwareView.FirmwareBackup
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
                highlight: processingStatus === SaveFirmwareView.BackupSucceed
                           || processingStatus === SaveFirmwareView.BackupFailed
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
                enabled: saveFirmwareView.editable
                onClicked: {
                    closeView()
                }
            }

            SGWidgets.SGButton {
                id: saveFirmwareButton
                text: "Save firmware"
                icon.source: "qrc:/images/chip-download.svg"
                enabled: saveFirmwareView.editable
                         && model.platform.status === Sci.SciPlatform.Ready
                onClicked: {
                    startBackupProcess(saveFirmwarePathEdit.filePath)
                }
             }
         }
     }

     function startBackupProcess(firmwarePath) {
         processingStatus = SaveFirmwareView.Setup

         setupNode.nodeState = StatusNode.NotSet
         preparationNode.nodeState = StatusNode.NotSet
         backupNode.nodeState = StatusNode.NotSet
         finishedNode.nodeState = StatusNode.NotSet

         setupNode.subText = ""
         preparationNode.subText = ""
         backupNode.subText = ""
         finishedNode.subText = ""

         backupProgress = 0

         var errorString = model.platform.saveDeviceFirmware(firmwarePath)
         if (errorString.length === 0) {
             setupNode.nodeState = StatusNode.Succeed
             Sci.Settings.lastSavedFirmwarePath = CommonCpp.SGUtilsCpp.parentDirectoryPath(firmwarePath)
         } else {
             setupNode.nodeState = StatusNode.Failed
             setupNode.subText = "Operation cannot start: " + errorString
             setFinalState(FlasherConnector.Failed)
         }
     }

     function setFinalState(result) {
         if (result === FlasherConnector.Success) {
             processingStatus = SaveFirmwareView.BackupSucceed
             finishedNode.nodeState = StatusNode.Succeed
             finishedNode.subText = "The device firmware is saved."
         } else if (result === FlasherConnector.Unsuccess) {
             processingStatus = SaveFirmwareView.BackupSucceed
             finishedNode.nodeState = StatusNode.SucceedWithWarning
             finishedNode.subText = "The saved file is not a valid firmware."
         } else {
             // FlasherConnector.Failure
             processingStatus = SaveFirmwareView.BackupFailed
             finishedNode.nodeState = StatusNode.Failed
             finishedNode.subText = "Firmware was not saved successfully."
         }
     }

     function closeView() {
         StackView.view.pop();
     }

     function currentTimestamp() {
         let timestamp = ""
         let date = new Date()
         timestamp += date.getFullYear()
         let val = date.getMonth() + 1
         timestamp += (val <= 9) ? "0" + val : val
         val = date.getDate()
         timestamp += (val <= 9) ? "0" + val : val
         timestamp += "_"
         val = date.getHours()
         timestamp += (val <= 9) ? "0" + val : val
         val = date.getMinutes()
         timestamp += (val <= 9) ? "0" + val : val
         val = date.getSeconds()
         timestamp += (val <= 9) ? "0" + val : val
         return timestamp
     }
}
